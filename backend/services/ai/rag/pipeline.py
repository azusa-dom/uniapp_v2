"""
Complete RAG Pipeline
Integrates all components: retrieval, re-ranking, generation, agents
"""
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, asdict

from .query_processor import query_processor, ProcessedQuery
from .retriever import advanced_retriever, RetrievedDocument
from .generator import rag_generator, GeneratedAnswer
from ..agents.base_agent import agent_orchestrator, AgentContext, AgentResponse
from ..embeddings.text_encoder import embedding_service
from .vector_store import qdrant_store


@dataclass
class RAGResult:
    """Complete RAG result"""
    # Input
    original_query: str
    processed_query: ProcessedQuery

    # Retrieval
    retrieved_documents: List[RetrievedDocument]
    retrieval_time_ms: float

    # Generation
    generated_answer: GeneratedAnswer
    generation_time_ms: float

    # Agent (if used)
    agent_response: Optional[AgentResponse]

    # Metadata
    total_time_ms: float
    method: str  # 'standard', 'agent', 'hybrid'


class RAGPipeline:
    """
    Complete RAG Pipeline
    """

    def __init__(self):
        self.use_query_understanding = True
        self.use_reranking = True
        self.use_diversity = False
        self.use_agents = True

    async def query(
        self,
        query: str,
        user_id: str,
        conversation_history: Optional[List[Dict[str, str]]] = None,
        user_profile: Optional[Dict[str, Any]] = None,
        top_k: int = 5,
        method: str = "hybrid",  # 'standard', 'agent', 'hybrid'
    ) -> RAGResult:
        """
        Complete RAG query pipeline

        Args:
            query: User query
            user_id: User ID
            conversation_history: Previous conversation
            user_profile: User profile data
            top_k: Number of documents to retrieve
            method: RAG method ('standard', 'agent', 'hybrid')

        Returns:
            RAGResult with complete information
        """
        import time

        start_time = time.time()

        # Step 1: Query Understanding
        if self.use_query_understanding:
            processed_query = await query_processor.process(query)
            filters = processed_query.filters
        else:
            processed_query = None
            filters = None

        # Step 2: Retrieval
        retrieval_start = time.time()

        retrieved_docs = await advanced_retriever.retrieve(
            query=query,
            filters=filters,
            top_k=top_k,
            enable_reranking=self.use_reranking,
            enable_diversity=self.use_diversity,
        )

        retrieval_time = (time.time() - retrieval_start) * 1000  # ms

        # Step 3: Generation
        generation_start = time.time()

        if method == "agent" or (method == "hybrid" and self.use_agents):
            # Use Agent-based generation
            agent_response = await self._agent_generate(
                query=query,
                user_id=user_id,
                retrieved_docs=retrieved_docs,
                conversation_history=conversation_history or [],
                user_profile=user_profile or {},
            )

            # Convert to GeneratedAnswer format
            generated_answer = GeneratedAnswer(
                answer=agent_response.answer,
                sources=[asdict(doc) for doc in retrieved_docs],
                confidence=agent_response.confidence,
                context_used=[doc.text for doc in retrieved_docs],
                tokens_used=len(agent_response.answer.split()) * 2,
            )
        else:
            # Standard RAG generation
            generated_answer = await rag_generator.generate(
                query=query,
                retrieved_docs=retrieved_docs,
                temperature=0.3,
            )
            agent_response = None

        generation_time = (time.time() - generation_start) * 1000  # ms

        total_time = (time.time() - start_time) * 1000  # ms

        return RAGResult(
            original_query=query,
            processed_query=processed_query,
            retrieved_documents=retrieved_docs,
            retrieval_time_ms=retrieval_time,
            generated_answer=generated_answer,
            generation_time_ms=generation_time,
            agent_response=agent_response,
            total_time_ms=total_time,
            method=method,
        )

    async def _agent_generate(
        self,
        query: str,
        user_id: str,
        retrieved_docs: List[RetrievedDocument],
        conversation_history: List[Dict[str, str]],
        user_profile: Dict[str, Any],
    ) -> AgentResponse:
        """Generate response using agent system"""
        context = AgentContext(
            query=query,
            user_id=user_id,
            conversation_history=conversation_history,
            user_profile=user_profile,
            retrieved_documents=[asdict(doc) for doc in retrieved_docs],
        )

        response = await agent_orchestrator.route(context)
        return response

    async def batch_query(
        self,
        queries: List[str],
        user_id: str,
        **kwargs
    ) -> List[RAGResult]:
        """
        Process multiple queries in batch

        Args:
            queries: List of queries
            user_id: User ID
            **kwargs: Additional arguments for query()

        Returns:
            List of RAGResult objects
        """
        results = []
        for query in queries:
            result = await self.query(query, user_id, **kwargs)
            results.append(result)

        return results

    async def stream_query(
        self,
        query: str,
        user_id: str,
        **kwargs
    ):
        """
        Stream RAG query results (for real-time response)

        Args:
            query: User query
            user_id: User ID
            **kwargs: Additional arguments

        Yields:
            Chunks of the response
        """
        # TODO: Implement streaming
        # This would require LLM streaming support
        result = await self.query(query, user_id, **kwargs)
        yield result.generated_answer.answer


class KnowledgeBaseManager:
    """
    Manage knowledge base: indexing, updating, deleting
    """

    def __init__(self):
        self.pipeline = RAGPipeline()

    async def index_document(
        self,
        text: str,
        metadata: Dict[str, Any],
        document_type: str = "general",
    ) -> str:
        """
        Index a single document

        Args:
            text: Document text
            metadata: Document metadata
            document_type: Type of document

        Returns:
            Document ID
        """
        from .document_processor import document_processor

        # Process document
        chunks = document_processor.process_document(
            text=text,
            document_type=document_type,
            metadata=metadata,
        )

        # Generate embeddings
        texts = [chunk["text"] for chunk in chunks]
        embeddings = await embedding_service.embed_batch(texts)

        # Prepare documents for insertion
        documents = []
        for chunk, embedding in zip(chunks, embeddings):
            doc = {
                "text": chunk["text"],
                "metadata": chunk["metadata"],
                "chunk_index": chunk["chunk_index"],
                "total_chunks": chunk["total_chunks"],
                "document_type": document_type,
                "source": metadata.get("source", ""),
                "source_id": metadata.get("source_id", ""),
            }
            documents.append(doc)

        # Insert into vector store
        doc_ids = await qdrant_store.upsert_documents(
            documents=documents,
            embeddings=embeddings,
        )

        return doc_ids[0] if doc_ids else ""

    async def index_batch(
        self,
        documents: List[Dict[str, Any]],
    ) -> List[str]:
        """
        Index multiple documents

        Args:
            documents: List of documents with 'text', 'metadata', 'document_type'

        Returns:
            List of document IDs
        """
        all_doc_ids = []

        for doc in documents:
            doc_id = await self.index_document(
                text=doc["text"],
                metadata=doc.get("metadata", {}),
                document_type=doc.get("document_type", "general"),
            )
            all_doc_ids.append(doc_id)

        return all_doc_ids

    async def delete_document(self, doc_id: str) -> bool:
        """Delete document by ID"""
        return await qdrant_store.delete_documents([doc_id])

    async def update_document(
        self,
        doc_id: str,
        text: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> bool:
        """
        Update document

        Args:
            doc_id: Document ID
            text: New text (if updating)
            metadata: New metadata (if updating)

        Returns:
            True if successful
        """
        # For now, delete and re-index
        # TODO: Implement in-place update
        if text:
            await self.delete_document(doc_id)
            await self.index_document(text, metadata or {})

        return True

    async def get_stats(self) -> Dict[str, Any]:
        """Get knowledge base statistics"""
        info = await qdrant_store.get_collection_info()
        return {
            "total_documents": info["points_count"],
            "indexed_vectors": info["indexed_vectors_count"],
            "vector_dimension": info["config"]["vector_size"],
            "distance_metric": info["config"]["distance"],
        }


# Global instances
rag_pipeline = RAGPipeline()
knowledge_base_manager = KnowledgeBaseManager()
