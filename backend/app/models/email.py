"""
Email models for synced emails.
"""
from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text, Enum, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum


class EmailCategory(str, enum.Enum):
    """Email category enumeration."""
    URGENT = "urgent"
    ACADEMIC = "academic"
    EVENTS = "events"
    ADMINISTRATIVE = "administrative"
    PERSONAL = "personal"
    OTHER = "other"


class Email(Base):
    """Email model for synced UCL emails."""
    __tablename__ = "emails"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Email metadata
    message_id = Column(String(500), unique=True, index=True, nullable=False)
    subject = Column(String(500), nullable=False)
    sender = Column(String(255), nullable=False)
    sender_name = Column(String(255), nullable=True)
    recipients = Column(Text, nullable=True)  # JSON array of recipients
    cc = Column(Text, nullable=True)  # JSON array
    bcc = Column(Text, nullable=True)  # JSON array

    # Content
    body_text = Column(Text, nullable=True)
    body_html = Column(Text, nullable=True)
    excerpt = Column(Text, nullable=True)  # First 200 chars

    # AI-generated content
    ai_summary = Column(Text, nullable=True)  # JSON array of summary points
    ai_translation = Column(Text, nullable=True)  # Chinese translation
    category = Column(Enum(EmailCategory), default=EmailCategory.OTHER)

    # Flags
    is_read = Column(Boolean, default=False)
    is_starred = Column(Boolean, default=False)
    has_attachments = Column(Boolean, default=False)

    # Timestamps
    received_at = Column(DateTime(timezone=True), nullable=False)
    synced_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="emails")

    def __repr__(self):
        return f"<Email {self.subject} from {self.sender}>"
