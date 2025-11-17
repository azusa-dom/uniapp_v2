"""
Qdrant Vector Database Client
High-performance vector search with metadata filtering
"""
from typing import List, Dict, Any, Optional, Tuple
from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance,
    VectorParams,
    PointStruct,
    Filter,
    FieldCondition,
    MatchValue,
    SearchRequest,
    ScoredPoint,
)
from qdrant_client.http import models
import uuid
from datetime import datetime

from shared.config import settings


class QdrantVectorStore:
    """Qdrant vector database client with advanced features"""

    def __init__(self):
        self.client = QdrantClient(
            url=settings.qdrant_url,
            api_key=settings.qdrant_api_key,
            timeout=60,
        )
        self.collection_name = settings.qdrant_collection_name

    async def create_collection(
        self,
        collection_name: Optional[str] = None,
        vector_size: int = 1024,
        distance: Distance = Distance.COSINE,
        on_disk: bool = False,
    ) -> bool:
        """
        Create a new collection

        Args:
            collection_name: Collection name (defaults to config)
            vector_size: Dimension of vectors (1024 for bge-m3)
            distance: Distance metric (COSINE, EUCLID, DOT)
            on_disk: Store vectors on disk (for large collections)

        Returns:
            True if created successfully
        """
        collection_name = collection_name or self.collection_name

        try:
            self.client.create_collection(
                collection_name=collection_name,
                vectors_config=VectorParams(
                    size=vector_size,
                    distance=distance,
                    on_disk=on_disk,
                ),
                optimizers_config=models.OptimizersConfigDiff(
                    indexing_threshold=10000,  # Start indexing after 10k vectors
                ),
                hnsw_config=models.HnswConfigDiff(
                    m=16,  # Number of edges per node
                    ef_construct=100,  # Size of dynamic candidate list
                    full_scan_threshold=10000,
                ),
            )
            return True
        except Exception as e:
            # Collection might already exist
            return False

    async def upsert_documents(
        self,
        documents: List[Dict[str, Any]],
        embeddings: List[List[float]],
        collection_name: Optional[str] = None,
    ) -> List[str]:
        """
        Insert or update documents with embeddings

        Args:
            documents: List of document metadata
            embeddings: List of embedding vectors
            collection_name: Target collection

        Returns:
            List of document IDs
        """
        collection_name = collection_name or self.collection_name

        points = []
        doc_ids = []

        for doc, embedding in zip(documents, embeddings):
            doc_id = doc.get("id") or str(uuid.uuid4())
            doc_ids.append(doc_id)

            point = PointStruct(
                id=doc_id,
                vector=embedding,
                payload={
                    "text": doc.get("text", ""),
                    "title": doc.get("title", ""),
                    "source": doc.get("source", ""),
                    "source_id": doc.get("source_id", ""),
                    "document_type": doc.get("document_type", "general"),
                    "metadata": doc.get("metadata", {}),
                    "timestamp": doc.get("timestamp", datetime.utcnow().isoformat()),
                    "chunk_index": doc.get("chunk_index", 0),
                    "total_chunks": doc.get("total_chunks", 1),
                }
            )
            points.append(point)

        # Batch upload
        self.client.upsert(
            collection_name=collection_name,
            points=points,
            wait=True,
        )

        return doc_ids

    async def search(
        self,
        query_vector: List[float],
        limit: int = 10,
        filters: Optional[Dict[str, Any]] = None,
        collection_name: Optional[str] = None,
        score_threshold: float = 0.0,
    ) -> List[Tuple[str, float, Dict[str, Any]]]:
        """
        Vector similarity search with optional filtering

        Args:
            query_vector: Query embedding vector
            limit: Maximum number of results
            filters: Metadata filters
            collection_name: Target collection
            score_threshold: Minimum similarity score

        Returns:
            List of (doc_id, score, payload) tuples
        """
        collection_name = collection_name or self.collection_name

        # Build filter
        query_filter = None
        if filters:
            conditions = []
            for key, value in filters.items():
                conditions.append(
                    FieldCondition(
                        key=key,
                        match=MatchValue(value=value)
                    )
                )
            if conditions:
                query_filter = Filter(must=conditions)

        # Search
        results = self.client.search(
            collection_name=collection_name,
            query_vector=query_vector,
            limit=limit,
            query_filter=query_filter,
            score_threshold=score_threshold,
            with_payload=True,
            with_vectors=False,
        )

        return [
            (str(result.id), result.score, result.payload)
            for result in results
        ]

    async def hybrid_search(
        self,
        query_vector: List[float],
        query_text: str,
        limit: int = 10,
        filters: Optional[Dict[str, Any]] = None,
        collection_name: Optional[str] = None,
        vector_weight: float = 0.7,
        text_weight: float = 0.3,
    ) -> List[Tuple[str, float, Dict[str, Any]]]:
        """
        Hybrid search combining vector similarity and text matching

        Args:
            query_vector: Query embedding
            query_text: Query text for keyword matching
            limit: Maximum results
            filters: Metadata filters
            collection_name: Target collection
            vector_weight: Weight for vector search (0-1)
            text_weight: Weight for text search (0-1)

        Returns:
            List of (doc_id, score, payload) tuples
        """
        collection_name = collection_name or self.collection_name

        # Vector search
        vector_results = await self.search(
            query_vector=query_vector,
            limit=limit * 2,  # Get more candidates
            filters=filters,
            collection_name=collection_name,
        )

        # Text search (keyword matching in payload)
        # For production, consider using full-text search index
        text_results = self.client.scroll(
            collection_name=collection_name,
            limit=limit * 2,
            with_payload=True,
            with_vectors=False,
        )[0]

        # Combine scores
        results_dict = {}

        # Add vector search results
        for doc_id, score, payload in vector_results:
            results_dict[doc_id] = {
                "score": score * vector_weight,
                "payload": payload,
            }

        # Add text search results
        keywords = query_text.lower().split()
        for point in text_results:
            doc_id = str(point.id)
            text = point.payload.get("text", "").lower()
            title = point.payload.get("title", "").lower()

            # Simple keyword matching
            text_score = sum(1 for kw in keywords if kw in text or kw in title) / len(keywords)

            if doc_id in results_dict:
                results_dict[doc_id]["score"] += text_score * text_weight
            else:
                results_dict[doc_id] = {
                    "score": text_score * text_weight,
                    "payload": point.payload,
                }

        # Sort by combined score
        sorted_results = sorted(
            results_dict.items(),
            key=lambda x: x[1]["score"],
            reverse=True
        )[:limit]

        return [
            (doc_id, data["score"], data["payload"])
            for doc_id, data in sorted_results
        ]

    async def delete_documents(
        self,
        doc_ids: List[str],
        collection_name: Optional[str] = None,
    ) -> bool:
        """Delete documents by IDs"""
        collection_name = collection_name or self.collection_name

        self.client.delete(
            collection_name=collection_name,
            points_selector=models.PointIdsList(
                points=doc_ids,
            ),
        )
        return True

    async def get_collection_info(
        self,
        collection_name: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Get collection statistics"""
        collection_name = collection_name or self.collection_name

        info = self.client.get_collection(collection_name)
        return {
            "vectors_count": info.vectors_count,
            "indexed_vectors_count": info.indexed_vectors_count,
            "points_count": info.points_count,
            "status": info.status,
            "config": {
                "vector_size": info.config.params.vectors.size,
                "distance": info.config.params.vectors.distance,
            }
        }

    async def scroll_documents(
        self,
        limit: int = 100,
        offset: Optional[str] = None,
        filters: Optional[Dict[str, Any]] = None,
        collection_name: Optional[str] = None,
    ) -> Tuple[List[Dict[str, Any]], Optional[str]]:
        """
        Scroll through documents

        Args:
            limit: Number of documents to return
            offset: Pagination offset
            filters: Metadata filters
            collection_name: Target collection

        Returns:
            (documents, next_offset) tuple
        """
        collection_name = collection_name or self.collection_name

        query_filter = None
        if filters:
            conditions = []
            for key, value in filters.items():
                conditions.append(
                    FieldCondition(key=key, match=MatchValue(value=value))
                )
            if conditions:
                query_filter = Filter(must=conditions)

        results, next_offset = self.client.scroll(
            collection_name=collection_name,
            limit=limit,
            offset=offset,
            scroll_filter=query_filter,
            with_payload=True,
            with_vectors=False,
        )

        documents = [
            {
                "id": str(point.id),
                **point.payload
            }
            for point in results
        ]

        return documents, next_offset


# Global instance
qdrant_store = QdrantVectorStore()
