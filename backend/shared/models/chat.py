"""AI chat models"""
import uuid
from datetime import datetime
from sqlalchemy import (
    Column,
    String,
    DateTime,
    Text,
    Boolean,
    Integer,
    ForeignKey,
    Enum as SQLEnum,
    Index,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import enum

from shared.database import Base


class ChatSession(Base):
    """AI chat sessions"""
    __tablename__ = "chat_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(200))
    is_archived = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", back_populates="chat_sessions")
    messages = relationship("ChatMessage", back_populates="session", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<ChatSession(id={self.id}, title={self.title})>"


class MessageRole(str, enum.Enum):
    """Chat message roles"""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class ChatMessage(Base):
    """Chat messages"""
    __tablename__ = "chat_messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("chat_sessions.id", ondelete="CASCADE"), nullable=False)

    role = Column(SQLEnum(MessageRole), nullable=False)
    content = Column(Text, nullable=False)

    # Metadata
    metadata = Column(JSONB)  # Store retrieval results, citations, etc.
    model_used = Column(String(50))  # 'deepseek-v3', 'gpt-4o'
    tokens_used = Column(Integer)
    latency_ms = Column(Integer)

    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    # Relationships
    session = relationship("ChatSession", back_populates="messages")
    feedbacks = relationship("UserFeedback", back_populates="message", cascade="all, delete-orphan")

    __table_args__ = (
        Index("idx_session_created", "session_id", "created_at"),
    )

    def __repr__(self):
        return f"<ChatMessage(role={self.role}, session={self.session_id})>"


class FeedbackType(str, enum.Enum):
    """Feedback types"""
    THUMBS_UP = "thumbs_up"
    THUMBS_DOWN = "thumbs_down"
    REPORT = "report"


class UserFeedback(Base):
    """User feedback on AI responses"""
    __tablename__ = "user_feedback"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    message_id = Column(UUID(as_uuid=True), ForeignKey("chat_messages.id", ondelete="CASCADE"))

    feedback_type = Column(SQLEnum(FeedbackType), nullable=False)
    comment = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    message = relationship("ChatMessage", back_populates="feedbacks")

    def __repr__(self):
        return f"<UserFeedback(type={self.feedback_type}, message={self.message_id})>"


class KnowledgeDocument(Base):
    """Knowledge base documents"""
    __tablename__ = "knowledge_documents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(500))
    content = Column(Text, nullable=False)

    document_type = Column(String(50), index=True)  # 'ucl_api', 'email', 'moodle', 'web_crawl', 'pdf'
    source_url = Column(Text)
    source_id = Column(String(255), index=True)  # Original source ID

    metadata = Column(JSONB)  # Additional metadata
    embedding_id = Column(String(255))  # Qdrant vector ID

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    __table_args__ = (
        Index("idx_type", "document_type"),
        Index("idx_source", "source_id"),
    )

    def __repr__(self):
        return f"<KnowledgeDocument(type={self.document_type}, title={self.title})>"
