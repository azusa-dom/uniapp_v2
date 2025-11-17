"""Email models"""
import uuid
from datetime import datetime
from sqlalchemy import (
    Column,
    String,
    DateTime,
    Text,
    Boolean,
    ForeignKey,
    Index,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship

from shared.database import Base


class Email(Base):
    """Email model"""
    __tablename__ = "emails"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    message_id = Column(String(255), unique=True)  # IMAP message ID
    thread_id = Column(String(255), index=True)
    folder = Column(String(100), default="INBOX")

    # Email metadata
    sender_name = Column(String(200))
    sender_email = Column(String(255), nullable=False)
    recipients = Column(JSONB)  # [{"name": "...", "email": "..."}]
    subject = Column(String(500))

    # Content
    body_text = Column(Text)
    body_html = Column(Text)
    snippet = Column(Text)  # First 200 characters

    # AI-generated content
    ai_summary = Column(Text)
    ai_translation = Column(Text)

    # Categorization
    category = Column(String(50), index=True)  # 'urgent', 'academic', 'events', 'library', 'personal'
    priority = Column(String(20), default="normal")  # 'low', 'normal', 'high', 'urgent'

    # Attachments
    has_attachments = Column(Boolean, default=False)
    attachments = Column(JSONB)  # [{"filename": "...", "size": ..., "url": "..."}]

    # Status
    received_at = Column(DateTime, nullable=False, index=True)
    is_read = Column(Boolean, default=False, index=True)
    is_starred = Column(Boolean, default=False)
    is_archived = Column(Boolean, default=False)
    labels = Column(JSONB, default=[])

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="emails")

    __table_args__ = (
        Index("idx_user_received", "user_id", "received_at"),
        Index("idx_category", "category"),
        Index("idx_is_read", "is_read"),
    )

    def __repr__(self):
        return f"<Email(subject={self.subject}, from={self.sender_email})>"
