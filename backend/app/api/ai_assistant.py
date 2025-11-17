"""
AI Assistant endpoints for chat and intelligent responses.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Dict, Any
from pydantic import BaseModel

from app.api.auth import get_current_active_user
from app.models.user import User
from app.models.ai_conversation import Conversation, Message
from app.models.academic import Course, Assignment
from app.models.activity import Activity
from app.models.email import Email
from app.database import get_db
from app.services.ai_assistant_service import AIAssistantService
from datetime import datetime, timedelta

router = APIRouter()


class ChatMessage(BaseModel):
    """Chat message schema."""
    message: str
    conversation_id: Optional[int] = None


async def gather_ucl_data(user: User, db: AsyncSession) -> Dict[str, Any]:
    """Gather relevant UCL data for AI context."""
    ucl_data = {}

    # Get courses
    result = await db.execute(
        select(Course).where(Course.student_id == user.id)
    )
    courses = result.scalars().all()
    ucl_data["courses"] = [
        {
            "course_name": c.course_name,
            "course_code": c.course_code,
            "current_grade": c.current_grade,
            "instructor_name": c.instructor_name
        }
        for c in courses
    ]

    # Get upcoming assignments
    now = datetime.utcnow()
    course_ids = [c.id for c in courses]
    if course_ids:
        result = await db.execute(
            select(Assignment).where(
                Assignment.course_id.in_(course_ids),
                Assignment.due_date >= now,
                Assignment.submitted == False
            ).order_by(Assignment.due_date).limit(10)
        )
        assignments = result.scalars().all()
        ucl_data["assignments"] = [
            {
                "name": a.name,
                "due_date": a.due_date.isoformat() if a.due_date else None,
                "weight": a.weight
            }
            for a in assignments
        ]

    # Get upcoming activities
    week_from_now = now + timedelta(days=7)
    result = await db.execute(
        select(Activity).where(
            Activity.start_time >= now,
            Activity.start_time <= week_from_now
        ).order_by(Activity.start_time).limit(10)
    )
    activities = result.scalars().all()
    ucl_data["activities"] = [
        {
            "title": a.title,
            "start_time": a.start_time.isoformat(),
            "location": a.location,
            "activity_type": a.activity_type.value
        }
        for a in activities
    ]

    # Get recent urgent emails
    result = await db.execute(
        select(Email).where(
            Email.user_id == user.id,
            Email.category == "urgent"
        ).order_by(Email.received_at.desc()).limit(5)
    )
    emails = result.scalars().all()
    ucl_data["emails"] = [
        {
            "subject": e.subject,
            "sender_name": e.sender_name,
            "excerpt": e.excerpt
        }
        for e in emails
    ]

    return ucl_data


@router.post("/chat")
async def chat_with_assistant(
    chat_message: ChatMessage,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Chat with AI assistant."""
    # Get or create conversation
    conversation = None
    if chat_message.conversation_id:
        result = await db.execute(
            select(Conversation).where(
                Conversation.id == chat_message.conversation_id,
                Conversation.user_id == current_user.id
            )
        )
        conversation = result.scalar_one_or_none()

    if not conversation:
        conversation = Conversation(
            user_id=current_user.id,
            is_active=True
        )
        db.add(conversation)
        await db.flush()

    # Get conversation history
    result = await db.execute(
        select(Message).where(
            Message.conversation_id == conversation.id
        ).order_by(Message.created_at)
    )
    history_messages = result.scalars().all()

    conversation_history = [
        {"role": msg.role, "content": msg.content}
        for msg in history_messages
    ]

    # Gather UCL data for context
    ucl_data = await gather_ucl_data(current_user, db)

    # Prepare user context
    user_context = {
        "full_name": current_user.full_name,
        "program": current_user.program,
        "department": current_user.department,
        "year_of_study": current_user.year_of_study
    }

    # Generate AI response
    async with AIAssistantService() as ai_service:
        try:
            response_data = await ai_service.generate_response(
                user_message=chat_message.message,
                user_context=user_context,
                ucl_data=ucl_data,
                conversation_history=conversation_history
            )

            # Save user message
            user_message = Message(
                conversation_id=conversation.id,
                role="user",
                content=chat_message.message
            )
            db.add(user_message)

            # Save assistant response
            assistant_message = Message(
                conversation_id=conversation.id,
                role="assistant",
                content=response_data["response"],
                context_data=str(response_data.get("context_data", "")),
                sources=str(response_data.get("sources", [])),
                model=response_data.get("model"),
                tokens_used=response_data.get("tokens_used"),
                processing_time=response_data.get("processing_time")
            )
            db.add(assistant_message)

            # Update conversation
            conversation.message_count += 2
            conversation.updated_at = datetime.utcnow()

            await db.commit()
            await db.refresh(assistant_message)

            return {
                "conversation_id": conversation.id,
                "response": response_data["response"],
                "model": response_data.get("model"),
                "processing_time": response_data.get("processing_time"),
                "sources": response_data.get("sources", [])
            }

        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Error generating AI response: {str(e)}"
            )


@router.get("/conversations")
async def get_conversations(
    limit: int = 20,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's conversation history."""
    result = await db.execute(
        select(Conversation).where(
            Conversation.user_id == current_user.id
        ).order_by(Conversation.updated_at.desc()).limit(limit)
    )
    conversations = result.scalars().all()

    return [
        {
            "id": conv.id,
            "title": conv.title,
            "message_count": conv.message_count,
            "created_at": conv.created_at.isoformat(),
            "updated_at": conv.updated_at.isoformat() if conv.updated_at else None
        }
        for conv in conversations
    ]


@router.get("/conversations/{conversation_id}/messages")
async def get_conversation_messages(
    conversation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get messages for a specific conversation."""
    # Verify conversation belongs to user
    result = await db.execute(
        select(Conversation).where(
            Conversation.id == conversation_id,
            Conversation.user_id == current_user.id
        )
    )
    conversation = result.scalar_one_or_none()

    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Get messages
    result = await db.execute(
        select(Message).where(
            Message.conversation_id == conversation_id
        ).order_by(Message.created_at)
    )
    messages = result.scalars().all()

    return [
        {
            "id": msg.id,
            "role": msg.role,
            "content": msg.content,
            "created_at": msg.created_at.isoformat()
        }
        for msg in messages
    ]


@router.delete("/conversations/{conversation_id}")
async def delete_conversation(
    conversation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Delete a conversation."""
    result = await db.execute(
        select(Conversation).where(
            Conversation.id == conversation_id,
            Conversation.user_id == current_user.id
        )
    )
    conversation = result.scalar_one_or_none()

    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    await db.delete(conversation)
    await db.commit()

    return {"success": True, "message": "Conversation deleted"}
