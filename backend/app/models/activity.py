"""
Activity models for UCL campus events and activities.
"""
from sqlalchemy import Column, String, Integer, DateTime, Boolean, Text, Enum, ForeignKey, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum


class ActivityType(str, enum.Enum):
    """Activity type enumeration."""
    ACADEMIC = "academic"
    CULTURAL = "cultural"
    SPORT = "sport"
    SOCIAL = "social"
    CAREER = "career"
    LECTURE = "lecture"
    SEMINAR = "seminar"
    WORKSHOP = "workshop"
    OTHER = "other"


class Activity(Base):
    """Activity model for UCL events and activities."""
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)

    # Activity details
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    activity_type = Column(Enum(ActivityType), default=ActivityType.OTHER)

    # Location
    location = Column(String(255), nullable=True)
    room = Column(String(100), nullable=True)
    building = Column(String(100), nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)

    # Time
    start_time = Column(DateTime(timezone=True), nullable=False)
    end_time = Column(DateTime(timezone=True), nullable=False)
    timezone = Column(String(50), default="Europe/London")

    # Registration
    registration_required = Column(Boolean, default=False)
    registration_url = Column(String(500), nullable=True)
    max_participants = Column(Integer, nullable=True)
    is_registered = Column(Boolean, default=False)

    # Pricing
    is_free = Column(Boolean, default=True)
    price = Column(Float, nullable=True)
    currency = Column(String(10), default="GBP")

    # Organizer
    organizer = Column(String(255), nullable=True)
    contact_email = Column(String(255), nullable=True)
    contact_phone = Column(String(50), nullable=True)

    # UCL API data
    ucl_activity_id = Column(String(100), nullable=True, unique=True, index=True)
    source = Column(String(50), default="ucl_api")  # ucl_api, manual, moodle

    # Recommendation
    is_recommended = Column(Boolean, default=False)
    recommendation_score = Column(Float, nullable=True)
    recommendation_reason = Column(Text, nullable=True)

    # Flags
    is_bookmarked = Column(Boolean, default=False)
    is_attended = Column(Boolean, default=False)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="activities")

    def __repr__(self):
        return f"<Activity {self.title} at {self.start_time}>"
