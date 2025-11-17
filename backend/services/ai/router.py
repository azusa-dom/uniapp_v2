"""
AI Service Router
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
import uuid

from shared.database import get_db
from shared.models.chat import ChatSession, ChatMessage, MessageRole
from services.auth import get_current_user_id
from .llm.deepseek import deepseek_client

router = APIRouter(prefix="/ai", tags=["AI"])


class ChatRequest(BaseModel):
    """Chat request schema"""
    message: str
    session_id: Optional[str] = None
    stream: bool = False


class ChatResponse(BaseModel):
    """Chat response schema"""
    session_id: str
    message: str
    role: str = "assistant"


@router.post("/chat", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """
    Chat with AI assistant

    Args:
        request: Chat request with message and optional session_id
        user_id: Current user ID
        db: Database session

    Returns:
        AI response
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
            title=request.message[:50]  # Use first 50 chars as title
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

    # Get conversation history (last 8 messages)
    from sqlalchemy import select
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session.id)
        .order_by(ChatMessage.created_at.desc())
        .limit(8)
    )
    history = list(reversed(result.scalars().all()))

    # Build messages for LLM
    system_prompt = """You are UniApp's bilingual study assistant for UCL students.
Respond in polished Simplified Chinese, stay concise, and focus on actionable guidance
for classes, assignments, health and campus life."""

    messages = [{"role": "system", "content": system_prompt}]
    for msg in history:
        messages.append({
            "role": msg.role.value,
            "content": msg.content
        })
    messages.append({"role": "user", "content": request.message})

    # Get AI response
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
        model_used="deepseek-chat"
    )
    db.add(ai_message)
    await db.commit()

    return ChatResponse(
        session_id=str(session.id),
        message=ai_response
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
