"""User models"""
import uuid
from datetime import datetime
from typing import Optional
from sqlalchemy import (
    Boolean,
    Column,
    String,
    Integer,
    DateTime,
    Text,
    Enum as SQLEnum,
    ForeignKey,
    CheckConstraint,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import enum

from shared.database import Base


class UserRole(str, enum.Enum):
    """User roles"""
    STUDENT = "student"
    PARENT = "parent"
    ADMIN = "admin"


class User(Base):
    """User model"""
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=True)  # Nullable for OAuth users
    role = Column(SQLEnum(UserRole), nullable=False, index=True)

    # Profile
    full_name = Column(String(100))
    ucl_id = Column(String(50), unique=True, index=True)
    department = Column(String(100))
    programme = Column(String(200))
    year_of_study = Column(Integer)
    profile_picture_url = Column(Text)
    phone_number = Column(String(20))

    # Additional data
    emergency_contact = Column(JSONB)  # {"name": "...", "phone": "...", "relationship": "..."}
    preferences = Column(JSONB, default={})  # User preferences

    # Status
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login_at = Column(DateTime)

    # Relationships
    student_links = relationship(
        "StudentParentLink",
        foreign_keys="StudentParentLink.student_id",
        back_populates="student",
        cascade="all, delete-orphan"
    )
    parent_links = relationship(
        "StudentParentLink",
        foreign_keys="StudentParentLink.parent_id",
        back_populates="parent",
        cascade="all, delete-orphan"
    )
    enrollments = relationship("Enrollment", back_populates="student", cascade="all, delete-orphan")
    emails = relationship("Email", back_populates="user", cascade="all, delete-orphan")
    chat_sessions = relationship("ChatSession", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"


class StudentParentLink(Base):
    """Student-Parent relationship"""
    __tablename__ = "student_parent_links"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    parent_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    relationship_type = Column(String(50))  # 'father', 'mother', 'guardian'

    # Permissions
    permissions = Column(JSONB, default={
        "view_grades": True,
        "view_attendance": True,
        "view_health": False,
        "view_emails": False,
    })

    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    student = relationship("User", foreign_keys=[student_id], back_populates="student_links")
    parent = relationship("User", foreign_keys=[parent_id], back_populates="parent_links")

    __table_args__ = (
        CheckConstraint(
            "student_id != parent_id",
            name="different_student_parent"
        ),
    )

    def __repr__(self):
        return f"<StudentParentLink(student={self.student_id}, parent={self.parent_id})>"
