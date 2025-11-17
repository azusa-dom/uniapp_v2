"""
Text Embedding Service
Support multiple embedding models: BGE-M3, OpenAI, etc.
"""
from typing import List, Optional, Union
from abc import ABC, abstractmethod
import numpy as np
from sentence_transformers import SentenceTransformer
import openai
from shared.config import settings


class BaseEmbedder(ABC):
    """Base class for embedding models"""

    @abstractmethod
    async def embed_text(self, text: str) -> List[float]:
        """Embed single text"""
        pass

    @abstractmethod
    async def embed_batch(self, texts: List[str]) -> List[List[float]]:
        """Embed multiple texts"""
        pass

    @property
    @abstractmethod
    def dimension(self) -> int:
        """Embedding dimension"""
        pass


class BGEEmbedder(BaseEmbedder):
    """
    BGE-M3 Embedder
    - Multilingual support (Chinese + English)
    - 1024 dimensions
    - State-of-the-art performance
    """

    def __init__(self, model_name: str = "BAAI/bge-m3"):
        self.model_name = model_name
        self.model = SentenceTransformer(model_name)
        self._dimension = 1024

    async def embed_text(self, text: str) -> List[float]:
        """Embed single text"""
        # Add instruction prefix for better retrieval
        text = f"Represent this text for retrieval: {text}"
        embedding = self.model.encode(text, normalize_embeddings=True)
        return embedding.tolist()

    async def embed_batch(self, texts: List[str], batch_size: int = 32) -> List[List[float]]:
        """Embed multiple texts with batching"""
        # Add instruction prefix
        texts = [f"Represent this text for retrieval: {text}" for text in texts]

        embeddings = self.model.encode(
            texts,
            batch_size=batch_size,
            normalize_embeddings=True,
            show_progress_bar=len(texts) > 100,
        )
        return embeddings.tolist()

    @property
    def dimension(self) -> int:
        return self._dimension


class OpenAIEmbedder(BaseEmbedder):
    """
    OpenAI Embeddings
    - text-embedding-3-large: 3072 dimensions
    - text-embedding-3-small: 1536 dimensions
    """

    def __init__(self, model: str = "text-embedding-3-small"):
        self.model = model
        self._dimension = 1536 if "small" in model else 3072
        openai.api_key = settings.openai_api_key

    async def embed_text(self, text: str) -> List[float]:
        """Embed single text"""
        response = await openai.embeddings.create(
            model=self.model,
            input=text,
        )
        return response.data[0].embedding

    async def embed_batch(self, texts: List[str]) -> List[List[float]]:
        """Embed multiple texts"""
        response = await openai.embeddings.create(
            model=self.model,
            input=texts,
        )
        return [item.embedding for item in response.data]

    @property
    def dimension(self) -> int:
        return self._dimension


class HybridEmbedder(BaseEmbedder):
    """
    Hybrid embedder combining multiple models
    Useful for multi-aspect retrieval
    """

    def __init__(self, embedders: List[BaseEmbedder], weights: Optional[List[float]] = None):
        self.embedders = embedders
        self.weights = weights or [1.0 / len(embedders)] * len(embedders)
        self._dimension = sum(e.dimension for e in embedders)

    async def embed_text(self, text: str) -> List[float]:
        """Embed with all models and concatenate"""
        embeddings = []
        for embedder, weight in zip(self.embedders, self.weights):
            emb = await embedder.embed_text(text)
            embeddings.extend([v * weight for v in emb])
        return embeddings

    async def embed_batch(self, texts: List[str]) -> List[List[float]]:
        """Embed batch with all models"""
        all_embeddings = []
        for embedder, weight in zip(self.embedders, self.weights):
            emb_batch = await embedder.embed_batch(texts)
            all_embeddings.append([[v * weight for v in emb] for emb in emb_batch])

        # Concatenate embeddings for each text
        result = []
        for i in range(len(texts)):
            combined = []
            for emb_batch in all_embeddings:
                combined.extend(emb_batch[i])
            result.append(combined)

        return result

    @property
    def dimension(self) -> int:
        return self._dimension


class EmbeddingService:
    """
    Unified embedding service
    Manages multiple embedders and provides caching
    """

    def __init__(self, default_model: str = "bge-m3"):
        self.embedders = {}
        self.default_model = default_model
        self._initialize_embedders()

    def _initialize_embedders(self):
        """Initialize available embedders"""
        # BGE-M3 (default, multilingual)
        try:
            self.embedders["bge-m3"] = BGEEmbedder("BAAI/bge-m3")
        except Exception as e:
            print(f"Failed to load BGE-M3: {e}")

        # BGE-Large-EN (English only, higher quality)
        try:
            self.embedders["bge-large-en"] = BGEEmbedder("BAAI/bge-large-en-v1.5")
        except Exception as e:
            print(f"Failed to load BGE-Large-EN: {e}")

        # OpenAI (if API key available)
        if settings.openai_api_key:
            try:
                self.embedders["openai-small"] = OpenAIEmbedder("text-embedding-3-small")
                self.embedders["openai-large"] = OpenAIEmbedder("text-embedding-3-large")
            except Exception as e:
                print(f"Failed to load OpenAI embedders: {e}")

    def get_embedder(self, model: Optional[str] = None) -> BaseEmbedder:
        """Get embedder by name"""
        model = model or self.default_model
        if model not in self.embedders:
            raise ValueError(f"Embedder '{model}' not available. Available: {list(self.embedders.keys())}")
        return self.embedders[model]

    async def embed_text(
        self,
        text: str,
        model: Optional[str] = None,
        use_cache: bool = True,
    ) -> List[float]:
        """
        Embed single text

        Args:
            text: Input text
            model: Embedding model name
            use_cache: Whether to use Redis cache

        Returns:
            Embedding vector
        """
        embedder = self.get_embedder(model)

        # Check cache
        if use_cache:
            from shared.database import redis_client
            cache_key = f"embedding:{model or self.default_model}:{hash(text)}"
            cached = await redis_client.get(cache_key)
            if cached:
                import json
                return json.loads(cached)

        # Generate embedding
        embedding = await embedder.embed_text(text)

        # Cache result
        if use_cache:
            import json
            await redis_client.set(
                cache_key,
                json.dumps(embedding),
                expire=86400  # 24 hours
            )

        return embedding

    async def embed_batch(
        self,
        texts: List[str],
        model: Optional[str] = None,
        batch_size: int = 32,
    ) -> List[List[float]]:
        """
        Embed multiple texts

        Args:
            texts: List of input texts
            model: Embedding model name
            batch_size: Batch size for processing

        Returns:
            List of embedding vectors
        """
        embedder = self.get_embedder(model)
        return await embedder.embed_batch(texts)

    async def embed_query(
        self,
        query: str,
        model: Optional[str] = None,
    ) -> List[float]:
        """
        Embed query text (optimized for retrieval)

        Args:
            query: Query text
            model: Embedding model name

        Returns:
            Query embedding
        """
        # For BGE models, queries should have "Represent this sentence for searching" prefix
        # This is handled internally in BGEEmbedder
        return await self.embed_text(query, model)

    @property
    def available_models(self) -> List[str]:
        """List available embedding models"""
        return list(self.embedders.keys())

    def get_dimension(self, model: Optional[str] = None) -> int:
        """Get embedding dimension for a model"""
        embedder = self.get_embedder(model)
        return embedder.dimension


# Global instance
embedding_service = EmbeddingService(default_model="bge-m3")
