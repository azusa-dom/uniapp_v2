"""Notification models"""
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
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from shared.database import Base


class Notification(Base):
    """User notifications"""
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    title = Column(String(200), nullable=False)
    body = Column(Text)
    type = Column(String(50))  # 'assignment', 'grade', 'email', 'event', 'system'
    priority = Column(String(20), default="normal")  # 'low', 'normal', 'high', 'urgent'

    # Related object
    related_id = Column(UUID(as_uuid=True))  # ID of related object
    related_type = Column(String(50))  # Type of related object

    is_read = Column(Boolean, default=False, index=True)
    sent_at = Column(DateTime, default=datetime.utcnow, index=True)
    read_at = Column(DateTime)

    # Relationships
    user = relationship("User", back_populates="notifications")

    __table_args__ = (
        Index("idx_user_sent", "user_id", "sent_at"),
    )

    def __repr__(self):
        return f"<Notification(title={self.title}, user={self.user_id})>"
