"""
RAG-specific API endpoints
Separate from chat for direct RAG queries and knowledge base management
"""
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, BackgroundTasks
from pydantic import BaseModel, Field

from services.auth import get_current_user_id
from .rag.pipeline import rag_pipeline, knowledge_base_manager
from .rag.vector_store import qdrant_store

router = APIRouter(prefix="/ai/rag", tags=["RAG"])


class RAGQueryRequest(BaseModel):
    """RAG query request"""
    query: str
    top_k: int = Field(default=5, ge=1, le=20)
    filters: Optional[Dict[str, Any]] = None
    method: str = Field(default="hybrid", description="'standard', 'agent', or 'hybrid'")
    enable_reranking: bool = True
    enable_diversity: bool = False


class RAGQueryResponse(BaseModel):
    """RAG query response"""
    answer: str
    sources: List[Dict[str, Any]]
    confidence: float
    retrieval_time_ms: float
    generation_time_ms: float
    total_time_ms: float
    method: str
    agent_type: Optional[str] = None


class IndexDocumentRequest(BaseModel):
    """Index document request"""
    text: str
    metadata: Dict[str, Any]
    document_type: str = "general"


class BatchIndexRequest(BaseModel):
    """Batch index request"""
    documents: List[Dict[str, Any]]


@router.post("/query", response_model=RAGQueryResponse)
async def rag_query(
    request: RAGQueryRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Direct RAG query (without chat history)

    Args:
        request: RAG query request
        user_id: Current user ID

    Returns:
        RAG response with sources
    """
    try:
        result = await rag_pipeline.query(
            query=request.query,
            user_id=user_id,
            top_k=request.top_k,
            method=request.method,
        )

        # Convert dataclasses to dicts
        sources = [
            {
                "id": doc.id,
                "text": doc.text,
                "score": doc.score,
                "metadata": doc.metadata,
                "source": doc.source,
            }
            for doc in result.retrieved_documents
        ]

        return RAGQueryResponse(
            answer=result.generated_answer.answer,
            sources=sources,
            confidence=result.generated_answer.confidence,
            retrieval_time_ms=result.retrieval_time_ms,
            generation_time_ms=result.generation_time_ms,
            total_time_ms=result.total_time_ms,
            method=result.method,
            agent_type=result.agent_response.agent_type.value if result.agent_response else None,
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"RAG query failed: {str(e)}")


@router.post("/index")
async def index_document(
    request: IndexDocumentRequest,
    user_id: str = Depends(get_current_user_id),
    background_tasks: BackgroundTasks = None,
):
    """
    Index a single document into knowledge base

    Args:
        request: Document to index
        user_id: Current user ID
        background_tasks: Background tasks

    Returns:
        Document ID
    """
    try:
        doc_id = await knowledge_base_manager.index_document(
            text=request.text,
            metadata=request.metadata,
            document_type=request.document_type,
        )

        return {
            "message": "Document indexed successfully",
            "document_id": doc_id,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Indexing failed: {str(e)}")


@router.post("/index/batch")
async def batch_index(
    request: BatchIndexRequest,
    user_id: str = Depends(get_current_user_id),
):
    """
    Index multiple documents in batch

    Args:
        request: Batch of documents
        user_id: Current user ID

    Returns:
        List of document IDs
    """
    try:
        doc_ids = await knowledge_base_manager.index_batch(request.documents)

        return {
            "message": f"Indexed {len(doc_ids)} documents successfully",
            "document_ids": doc_ids,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch indexing failed: {str(e)}")


@router.delete("/documents/{doc_id}")
async def delete_document(
    doc_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete document from knowledge base"""
    try:
        success = await knowledge_base_manager.delete_document(doc_id)

        if success:
            return {"message": "Document deleted successfully"}
        else:
            raise HTTPException(status_code=404, detail="Document not found")

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Deletion failed: {str(e)}")


@router.get("/documents")
async def list_documents(
    limit: int = Query(default=100, le=1000),
    offset: Optional[str] = None,
    filters: Optional[Dict[str, Any]] = None,
    user_id: str = Depends(get_current_user_id),
):
    """
    List documents in knowledge base

    Args:
        limit: Maximum number of documents
        offset: Pagination offset
        filters: Metadata filters
        user_id: Current user ID

    Returns:
        List of documents
    """
    try:
        documents, next_offset = await qdrant_store.scroll_documents(
            limit=limit,
            offset=offset,
            filters=filters,
        )

        return {
            "documents": documents,
            "count": len(documents),
            "next_offset": next_offset,
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list documents: {str(e)}")


@router.get("/stats")
async def get_stats(
    user_id: str = Depends(get_current_user_id),
):
    """
    Get knowledge base statistics

    Returns:
        Statistics about the knowledge base
    """
    try:
        stats = await knowledge_base_manager.get_stats()
        return stats

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get stats: {str(e)}")


@router.post("/search")
async def semantic_search(
    query: str = Query(..., min_length=1),
    top_k: int = Query(default=10, ge=1, le=50),
    filters: Optional[Dict[str, Any]] = None,
    user_id: str = Depends(get_current_user_id),
):
    """
    Semantic search in knowledge base (without generation)

    Args:
        query: Search query
        top_k: Number of results
        filters: Metadata filters
        user_id: Current user ID

    Returns:
        Search results
    """
    try:
        from .embeddings.text_encoder import embedding_service

        # Generate query embedding
        query_embedding = await embedding_service.embed_query(query)

        # Search
        results = await qdrant_store.search(
            query_vector=query_embedding,
            limit=top_k,
            filters=filters,
        )

        documents = [
            {
                "id": doc_id,
                "score": score,
                **payload
            }
            for doc_id, score, payload in results
        ]

        return {
            "query": query,
            "results": documents,
            "count": len(documents),
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")


@router.post("/init-collection")
async def initialize_collection(
    vector_size: int = Query(default=1024, description="Embedding dimension"),
    user_id: str = Depends(get_current_user_id),
):
    """
    Initialize Qdrant collection (admin only)

    Args:
        vector_size: Vector dimension (1024 for bge-m3)
        user_id: Current user ID

    Returns:
        Success message
    """
    try:
        success = await qdrant_store.create_collection(
            vector_size=vector_size,
        )

        if success:
            return {"message": "Collection initialized successfully"}
        else:
            return {"message": "Collection already exists"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Initialization failed: {str(e)}")
