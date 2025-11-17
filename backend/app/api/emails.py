"""
Email endpoints for syncing and managing UCL emails.
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from typing import List
from datetime import datetime

from app.api.auth import get_current_active_user
from app.models.user import User
from app.models.email import Email, EmailCategory
from app.database import get_db
from app.services.email_service import EmailService
from app.services.ai_assistant_service import AIAssistantService

router = APIRouter()


async def sync_emails_task(user_id: int, user_email: str, user_password: str, db: AsyncSession):
    """Background task to sync emails."""
    try:
        email_service = EmailService(user_email, user_password)
        emails = await email_service.fetch_recent_emails(limit=50)

        for email_data in emails:
            # Check if email already exists
            result = await db.execute(
                select(Email).where(Email.message_id == email_data["message_id"])
            )
            if result.scalar_one_or_none():
                continue

            # Create new email record
            new_email = Email(
                user_id=user_id,
                message_id=email_data["message_id"],
                subject=email_data["subject"],
                sender=email_data["sender"],
                sender_name=email_data.get("sender_name"),
                body_text=email_data.get("body_text"),
                body_html=email_data.get("body_html"),
                excerpt=email_data.get("excerpt"),
                category=EmailCategory(email_data.get("category", "other")),
                received_at=email_data["received_at"],
                is_read=email_data.get("is_read", False)
            )

            db.add(new_email)

        await db.commit()

        email_service.disconnect()

    except Exception as e:
        print(f"Error syncing emails: {e}")
        await db.rollback()


@router.post("/sync")
async def sync_emails(
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Sync emails from UCL Outlook (requires user credentials stored)."""
    # In production, you would get the password from encrypted storage
    # For now, we'll return a message
    return {
        "message": "Email sync initiated. This would normally sync emails in the background.",
        "note": "In production, this requires OAuth2 setup with Microsoft Exchange"
    }


@router.get("/", response_model=List[dict])
async def get_emails(
    category: Optional[str] = None,
    is_read: Optional[bool] = None,
    limit: int = 50,
    offset: int = 0,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get user's emails with optional filters."""
    query = select(Email).where(Email.user_id == current_user.id)

    if category:
        query = query.where(Email.category == EmailCategory(category))
    if is_read is not None:
        query = query.where(Email.is_read == is_read)

    query = query.order_by(desc(Email.received_at)).limit(limit).offset(offset)

    result = await db.execute(query)
    emails = result.scalars().all()

    return [
        {
            "id": email.id,
            "subject": email.subject,
            "sender": email.sender,
            "sender_name": email.sender_name,
            "excerpt": email.excerpt,
            "category": email.category.value,
            "is_read": email.is_read,
            "is_starred": email.is_starred,
            "received_at": email.received_at.isoformat(),
            "ai_summary": email.ai_summary
        }
        for email in emails
    ]


@router.get("/{email_id}")
async def get_email_detail(
    email_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get detailed email content."""
    result = await db.execute(
        select(Email).where(
            Email.id == email_id,
            Email.user_id == current_user.id
        )
    )
    email = result.scalar_one_or_none()

    if not email:
        raise HTTPException(status_code=404, detail="Email not found")

    # Mark as read
    email.is_read = True
    await db.commit()

    return {
        "id": email.id,
        "subject": email.subject,
        "sender": email.sender,
        "sender_name": email.sender_name,
        "body_text": email.body_text,
        "body_html": email.body_html,
        "category": email.category.value,
        "ai_summary": email.ai_summary,
        "ai_translation": email.ai_translation,
        "received_at": email.received_at.isoformat()
    }


@router.post("/{email_id}/summarize")
async def generate_email_summary(
    email_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Generate AI summary and translation for email."""
    result = await db.execute(
        select(Email).where(
            Email.id == email_id,
            Email.user_id == current_user.id
        )
    )
    email = result.scalar_one_or_none()

    if not email:
        raise HTTPException(status_code=404, detail="Email not found")

    # Generate summary using AI
    async with AIAssistantService() as ai_service:
        summary_data = await ai_service.generate_email_summary(
            email.body_text or email.body_html or ""
        )

        if summary_data["success"]:
            email.ai_summary = summary_data["summary"]
            await db.commit()

    return {
        "ai_summary": email.ai_summary,
        "success": summary_data["success"]
    }


@router.patch("/{email_id}/mark-read")
async def mark_email_read(
    email_id: int,
    is_read: bool,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Mark email as read/unread."""
    result = await db.execute(
        select(Email).where(
            Email.id == email_id,
            Email.user_id == current_user.id
        )
    )
    email = result.scalar_one_or_none()

    if not email:
        raise HTTPException(status_code=404, detail="Email not found")

    email.is_read = is_read
    await db.commit()

    return {"success": True, "is_read": email.is_read}
