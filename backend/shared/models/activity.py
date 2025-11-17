"""Activity and event models"""
import uuid
from datetime import datetime
from decimal import Decimal
from sqlalchemy import (
    Column,
    String,
    DateTime,
    Text,
    Boolean,
    Integer,
    Numeric,
    ForeignKey,
    Index,
    Enum as SQLEnum,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import enum

from shared.database import Base


class UCLActivity(Base):
    """UCL campus activities"""
    __tablename__ = "ucl_activities"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(300), nullable=False)
    description = Column(Text)
    activity_type = Column(String(50), index=True)  # 'academic', 'cultural', 'sport', 'workshop', 'social'

    # Time and location
    start_time = Column(DateTime, nullable=False, index=True)
    end_time = Column(DateTime, nullable=False)
    location = Column(String(200))
    building = Column(String(100))
    room_number = Column(String(50))

    # Organizer and registration
    organizer = Column(String(200))
    capacity = Column(Integer)
    registration_url = Column(Text)
    price = Column(Numeric(10, 2), default=Decimal("0.00"))

    # Additional metadata
    tags = Column(JSONB, default=[])
    target_audience = Column(JSONB)  # ["undergraduates", "postgraduates", "staff"]
    is_free = Column(Boolean, default=True)
    requires_registration = Column(Boolean, default=False)

    # Media
    image_url = Column(Text)
    source_url = Column(Text)  # UCL website link

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    participations = relationship("ActivityParticipation", back_populates="activity", cascade="all, delete-orphan")

    __table_args__ = (
        Index("idx_start_time", "start_time"),
        Index("idx_type", "activity_type"),
    )

    def __repr__(self):
        return f"<UCLActivity(title={self.title}, type={self.activity_type})>"


class ParticipationStatus(str, enum.Enum):
    """Activity participation status"""
    INTERESTED = "interested"
    REGISTERED = "registered"
    ATTENDED = "attended"
    CANCELLED = "cancelled"


class ActivityParticipation(Base):
    """User activity participation"""
    __tablename__ = "activity_participations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    activity_id = Column(UUID(as_uuid=True), ForeignKey("ucl_activities.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    status = Column(SQLEnum(ParticipationStatus), default=ParticipationStatus.INTERESTED)
    registered_at = Column(DateTime, default=datetime.utcnow)
    attended_at = Column(DateTime)

    # Feedback
    feedback = Column(Text)
    rating = Column(Integer)  # 1-5

    # Relationships
    activity = relationship("UCLActivity", back_populates="participations")

    def __repr__(self):
        return f"<ActivityParticipation(activity={self.activity_id}, user={self.user_id})>"
