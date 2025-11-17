"""
Advanced Retrieval System
Hybrid retrieval with re-ranking and fusion
"""
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
import numpy as np
from collections import defaultdict

from .vector_store import qdrant_store
from ..embeddings.text_encoder import embedding_service


@dataclass
class RetrievedDocument:
    """Retrieved document with metadata"""
    id: str
    text: str
    score: float
    metadata: Dict[str, Any]
    source: str  # 'vector', 'keyword', 'hybrid'


class HybridRetriever:
    """
    Hybrid retrieval combining vector and keyword search
    """

    def __init__(
        self,
        vector_weight: float = 0.7,
        keyword_weight: float = 0.3,
        top_k: int = 10,
    ):
        """
        Args:
            vector_weight: Weight for vector search
            keyword_weight: Weight for keyword search
            top_k: Number of documents to retrieve
        """
        self.vector_weight = vector_weight
        self.keyword_weight = keyword_weight
        self.top_k = top_k

    async def retrieve(
        self,
        query: str,
        filters: Optional[Dict[str, Any]] = None,
        top_k: Optional[int] = None,
    ) -> List[RetrievedDocument]:
        """
        Hybrid retrieval

        Args:
            query: Query text
            filters: Metadata filters
            top_k: Override default top_k

        Returns:
            List of retrieved documents sorted by score
        """
        top_k = top_k or self.top_k

        # Generate query embedding
        query_embedding = await embedding_service.embed_query(query)

        # Hybrid search
        results = await qdrant_store.hybrid_search(
            query_vector=query_embedding,
            query_text=query,
            limit=top_k,
            filters=filters,
            vector_weight=self.vector_weight,
            text_weight=self.keyword_weight,
        )

        # Convert to RetrievedDocument
        documents = []
        for doc_id, score, payload in results:
            doc = RetrievedDocument(
                id=doc_id,
                text=payload.get("text", ""),
                score=score,
                metadata=payload.get("metadata", {}),
                source="hybrid"
            )
            documents.append(doc)

        return documents


class CrossEncoderReranker:
    """
    Re-ranker using cross-encoder model
    More accurate but slower than bi-encoder
    """

    def __init__(self, model_name: str = "cross-encoder/ms-marco-MiniLM-L-6-v2"):
        """
        Args:
            model_name: Cross-encoder model name
        """
        try:
            from sentence_transformers import CrossEncoder
            self.model = CrossEncoder(model_name)
            self.available = True
        except Exception as e:
            print(f"CrossEncoder not available: {e}")
            self.available = False

    async def rerank(
        self,
        query: str,
        documents: List[RetrievedDocument],
        top_k: Optional[int] = None,
    ) -> List[RetrievedDocument]:
        """
        Re-rank documents using cross-encoder

        Args:
            query: Query text
            documents: Retrieved documents
            top_k: Number of documents to return

        Returns:
            Re-ranked documents
        """
        if not self.available or not documents:
            return documents

        # Prepare pairs for cross-encoder
        pairs = [[query, doc.text] for doc in documents]

        # Get relevance scores
        scores = self.model.predict(pairs)

        # Update document scores
        for doc, score in zip(documents, scores):
            doc.score = float(score)

        # Sort by new scores
        documents.sort(key=lambda x: x.score, reverse=True)

        # Return top-k
        if top_k:
            return documents[:top_k]
        return documents


class ReciprocaRankFusion:
    """
    Reciprocal Rank Fusion (RRF)
    Combines multiple ranked lists effectively
    """

    def __init__(self, k: int = 60):
        """
        Args:
            k: Constant for RRF formula (default 60 from paper)
        """
        self.k = k

    def fuse(
        self,
        ranked_lists: List[List[RetrievedDocument]],
        top_k: int = 10,
    ) -> List[RetrievedDocument]:
        """
        Fuse multiple ranked lists using RRF

        Args:
            ranked_lists: List of ranked document lists
            top_k: Number of documents to return

        Returns:
            Fused ranked list
        """
        # Calculate RRF scores
        doc_scores = defaultdict(float)
        doc_objects = {}

        for ranked_list in ranked_lists:
            for rank, doc in enumerate(ranked_list, start=1):
                # RRF score: 1 / (k + rank)
                doc_scores[doc.id] += 1.0 / (self.k + rank)
                doc_objects[doc.id] = doc

        # Sort by RRF score
        sorted_ids = sorted(doc_scores.items(), key=lambda x: x[1], reverse=True)

        # Build result
        result = []
        for doc_id, score in sorted_ids[:top_k]:
            doc = doc_objects[doc_id]
            doc.score = score
            result.append(doc)

        return result


class DiversityReranker:
    """
    Re-ranker that promotes diversity in results
    Reduces redundancy using MMR (Maximal Marginal Relevance)
    """

    def __init__(self, lambda_param: float = 0.5):
        """
        Args:
            lambda_param: Balance between relevance and diversity (0-1)
                         1 = only relevance, 0 = only diversity
        """
        self.lambda_param = lambda_param

    async def rerank(
        self,
        documents: List[RetrievedDocument],
        top_k: int = 10,
    ) -> List[RetrievedDocument]:
        """
        Re-rank using MMR

        Args:
            documents: Retrieved documents
            top_k: Number of documents to return

        Returns:
            Diversified ranked list
        """
        if len(documents) <= top_k:
            return documents

        # Get embeddings for all documents
        texts = [doc.text for doc in documents]
        embeddings = await embedding_service.embed_batch(texts)

        # Convert to numpy arrays
        embeddings = np.array(embeddings)

        # Initialize
        selected_indices = []
        unselected_indices = list(range(len(documents)))

        # Select first document (highest relevance)
        first_idx = 0
        selected_indices.append(first_idx)
        unselected_indices.remove(first_idx)

        # Iteratively select documents
        while len(selected_indices) < top_k and unselected_indices:
            best_score = float('-inf')
            best_idx = None

            for idx in unselected_indices:
                # Relevance score (original score)
                relevance = documents[idx].score

                # Diversity score (min similarity to selected documents)
                if selected_indices:
                    similarities = [
                        self._cosine_similarity(embeddings[idx], embeddings[sel_idx])
                        for sel_idx in selected_indices
                    ]
                    max_similarity = max(similarities)
                else:
                    max_similarity = 0

                # MMR score
                mmr_score = self.lambda_param * relevance - (1 - self.lambda_param) * max_similarity

                if mmr_score > best_score:
                    best_score = mmr_score
                    best_idx = idx

            if best_idx is not None:
                selected_indices.append(best_idx)
                unselected_indices.remove(best_idx)

        # Return selected documents
        return [documents[idx] for idx in selected_indices]

    def _cosine_similarity(self, a: np.ndarray, b: np.ndarray) -> float:
        """Calculate cosine similarity between two vectors"""
        return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))


class AdvancedRetriever:
    """
    Advanced retrieval system combining multiple strategies
    """

    def __init__(self):
        self.hybrid_retriever = HybridRetriever(
            vector_weight=0.7,
            keyword_weight=0.3,
            top_k=20,  # Retrieve more candidates for re-ranking
        )
        self.cross_encoder_reranker = CrossEncoderReranker()
        self.diversity_reranker = DiversityReranker(lambda_param=0.7)
        self.rrf_fusion = ReciprocaRankFusion(k=60)

    async def retrieve(
        self,
        query: str,
        filters: Optional[Dict[str, Any]] = None,
        top_k: int = 10,
        enable_reranking: bool = True,
        enable_diversity: bool = False,
    ) -> List[RetrievedDocument]:
        """
        Advanced retrieval with optional re-ranking and diversity

        Args:
            query: Query text
            filters: Metadata filters
            top_k: Number of final documents
            enable_reranking: Use cross-encoder re-ranking
            enable_diversity: Apply diversity re-ranking

        Returns:
            Retrieved and re-ranked documents
        """
        # Initial hybrid retrieval
        documents = await self.hybrid_retriever.retrieve(
            query=query,
            filters=filters,
            top_k=top_k * 2 if enable_reranking else top_k,
        )

        if not documents:
            return []

        # Cross-encoder re-ranking
        if enable_reranking:
            documents = await self.cross_encoder_reranker.rerank(
                query=query,
                documents=documents,
                top_k=top_k * 2 if enable_diversity else top_k,
            )

        # Diversity re-ranking
        if enable_diversity:
            documents = await self.diversity_reranker.rerank(
                documents=documents,
                top_k=top_k,
            )

        return documents[:top_k]

    async def multi_query_retrieve(
        self,
        queries: List[str],
        filters: Optional[Dict[str, Any]] = None,
        top_k: int = 10,
    ) -> List[RetrievedDocument]:
        """
        Retrieve using multiple query variations and fuse results

        Args:
            queries: List of query variations
            filters: Metadata filters
            top_k: Number of final documents

        Returns:
            Fused results from all queries
        """
        # Retrieve for each query
        all_results = []
        for query in queries:
            results = await self.hybrid_retriever.retrieve(
                query=query,
                filters=filters,
                top_k=top_k * 2,
            )
            all_results.append(results)

        # Fuse results using RRF
        fused_results = self.rrf_fusion.fuse(all_results, top_k=top_k)

        return fused_results


# Global instance
advanced_retriever = AdvancedRetriever()
