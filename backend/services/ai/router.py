"""
AI Service Router
Enhanced with RAG capabilities
"""
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from shared.database import get_db
from shared.models.chat import ChatSession, ChatMessage, MessageRole
from services.auth import get_current_user_id
from .llm.deepseek import deepseek_client
from .rag.pipeline import rag_pipeline, knowledge_base_manager
from .rag.vector_store import qdrant_store

router = APIRouter(prefix="/ai", tags=["AI"])


class ChatRequest(BaseModel):
    """Chat request schema"""
    message: str
    session_id: Optional[str] = None
    stream: bool = False
    use_rag: bool = True  # Enable RAG by default
    rag_method: str = Field(default="hybrid", description="'standard', 'agent', or 'hybrid'")
    top_k: int = Field(default=5, ge=1, le=20, description="Number of documents to retrieve")


class ChatResponse(BaseModel):
    """Chat response schema"""
    session_id: str
    message: str
    role: str = "assistant"
    sources: Optional[List[Dict[str, Any]]] = None
    confidence: Optional[float] = None
    agent_type: Optional[str] = None


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


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Chat with AI assistant (with optional RAG)

    Args:
        request: Chat request with message and optional session_id
        user_id: Current user ID
        db: Database session

    Returns:
        AI response with optional sources from RAG
    """
    # Get or create session
    if request.session_id:
        session = await db.get(ChatSession, uuid.UUID(request.session_id))
        if not session or str(session.user_id) != user_id:
            raise HTTPException(status_code=404, detail="Session not found")
    else:
        session = ChatSession(
            id=uuid.uuid4(),
            user_id=uuid.UUID(user_id),
            title=request.message[:50]
        )
        db.add(session)
        await db.flush()

    # Save user message
    user_message = ChatMessage(
        id=uuid.uuid4(),
        session_id=session.id,
        role=MessageRole.USER,
        content=request.message
    )
    db.add(user_message)

    # Get conversation history
    from sqlalchemy import select
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session.id)
        .order_by(ChatMessage.created_at.desc())
        .limit(8)
    )
    history = list(reversed(result.scalars().all()))
    conversation_history = [
        {"role": msg.role.value, "content": msg.content}
        for msg in history
    ]

    sources = None
    confidence = None
    agent_type = None

    # Use RAG if enabled
    if request.use_rag:
        try:
            # Query RAG pipeline
            rag_result = await rag_pipeline.query(
                query=request.message,
                user_id=user_id,
                conversation_history=conversation_history,
                top_k=request.top_k,
                method=request.rag_method,
            )

            ai_response = rag_result.generated_answer.answer
            sources = [
                {
                    "text": doc.text,
                    "score": doc.score,
                    "metadata": doc.metadata
                }
                for doc in rag_result.retrieved_documents[:3]  # Top 3 sources
            ]
            confidence = rag_result.generated_answer.confidence

            if rag_result.agent_response:
                agent_type = rag_result.agent_response.agent_type.value

        except Exception as e:
            print(f"RAG failed, falling back to standard chat: {e}")
            # Fallback to standard chat
            request.use_rag = False

    # Standard chat (if RAG disabled or failed)
    if not request.use_rag:
        system_prompt = """You are UniApp's bilingual study assistant for UCL students.
Respond in polished Simplified Chinese, stay concise, and focus on actionable guidance
for classes, assignments, health and campus life."""

        messages = [{"role": "system", "content": system_prompt}]
        messages.extend(conversation_history)
        messages.append({"role": "user", "content": request.message})

        ai_response = await deepseek_client.chat_completion(
            messages=messages,
            temperature=0.7,
            max_tokens=800
        )

    # Save AI message
    ai_message = ChatMessage(
        id=uuid.uuid4(),
        session_id=session.id,
        role=MessageRole.ASSISTANT,
        content=ai_response,
        model_used="deepseek-chat-rag" if request.use_rag else "deepseek-chat"
    )
    db.add(ai_message)
    await db.commit()

    return ChatResponse(
        session_id=str(session.id),
        message=ai_response,
        sources=sources,
        confidence=confidence,
        agent_type=agent_type,
    )


@router.get("/sessions")
async def get_sessions(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get user's chat sessions"""
    from sqlalchemy import select
    result = await db.execute(
        select(ChatSession)
        .where(ChatSession.user_id == uuid.UUID(user_id))
        .where(ChatSession.is_archived == False)
        .order_by(ChatSession.updated_at.desc())
    )
    sessions = result.scalars().all()

    return {
        "sessions": [
            {
                "id": str(s.id),
                "title": s.title,
                "created_at": s.created_at.isoformat(),
                "updated_at": s.updated_at.isoformat()
            }
            for s in sessions
        ]
    }


@router.get("/sessions/{session_id}/messages")
async def get_messages(
    session_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get messages in a session"""
    session = await db.get(ChatSession, uuid.UUID(session_id))
    if not session or str(session.user_id) != user_id:
        raise HTTPException(status_code=404, detail="Session not found")

    from sqlalchemy import select
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session.id)
        .order_by(ChatMessage.created_at)
    )
    messages = result.scalars().all()

    return {
        "messages": [
            {
                "id": str(m.id),
                "role": m.role.value,
                "content": m.content,
                "created_at": m.created_at.isoformat()
            }
            for m in messages
        ]
    }


@router.delete("/sessions/{session_id}")
async def delete_session(
    session_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Delete a chat session"""
    session = await db.get(ChatSession, uuid.UUID(session_id))
    if not session or str(session.user_id) != user_id:
        raise HTTPException(status_code=404, detail="Session not found")

    await db.delete(session)
    await db.commit()

    return {"message": "Session deleted successfully"}
