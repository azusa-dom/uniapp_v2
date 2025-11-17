"""
User models for students and parents.
"""
from sqlalchemy import Column, String, Integer, DateTime, Boolean, Enum, ForeignKey, Table
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
import enum


class UserRole(str, enum.Enum):
    """User role enumeration."""
    STUDENT = "student"
    PARENT = "parent"
    ADMIN = "admin"


class User(Base):
    """User model for both students and parents."""
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    role = Column(Enum(UserRole), nullable=False)
    ucl_id = Column(String(50), unique=True, index=True, nullable=True)  # For students
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)

    # Profile fields
    phone = Column(String(20), nullable=True)
    department = Column(String(100), nullable=True)  # For students
    program = Column(String(200), nullable=True)  # For students
    year_of_study = Column(Integer, nullable=True)  # For students

    # OAuth tokens (encrypted)
    ucl_access_token = Column(String(500), nullable=True)
    ucl_refresh_token = Column(String(500), nullable=True)
    moodle_token = Column(String(500), nullable=True)
    email_access_token = Column(String(500), nullable=True)

    # Relationships
    emails = relationship("Email", back_populates="user", cascade="all, delete-orphan")
    courses = relationship("Course", back_populates="student", cascade="all, delete-orphan")
    activities = relationship("Activity", back_populates="user", cascade="all, delete-orphan")
    conversations = relationship("Conversation", back_populates="user", cascade="all, delete-orphan")

    # Parent-Student relationships
    parents = relationship(
        "ParentStudentLink",
        foreign_keys="ParentStudentLink.student_id",
        back_populates="student",
        cascade="all, delete-orphan"
    )
    children = relationship(
        "ParentStudentLink",
        foreign_keys="ParentStudentLink.parent_id",
        back_populates="parent",
        cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<User {self.email} ({self.role})>"


class ParentStudentLink(Base):
    """Link table for parent-student relationships."""
    __tablename__ = "parent_student_links"

    id = Column(Integer, primary_key=True, index=True)
    parent_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    student_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    relationship_type = Column(String(50), default="guardian")  # guardian, parent, etc.
    verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    parent = relationship("User", foreign_keys=[parent_id], back_populates="children")
    student = relationship("User", foreign_keys=[student_id], back_populates="parents")

    def __repr__(self):
        return f"<ParentStudentLink parent={self.parent_id} student={self.student_id}>"
