"""Course and grade models"""
import uuid
from datetime import datetime, date
from decimal import Decimal
from sqlalchemy import (
    Column,
    String,
    Integer,
    DateTime,
    Date,
    Text,
    Boolean,
    Numeric,
    ForeignKey,
    Enum as SQLEnum,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import enum

from shared.database import Base


class Course(Base):
    """Course model"""
    __tablename__ = "courses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_code = Column(String(50), unique=True, nullable=False, index=True)
    course_name = Column(String(200), nullable=False)
    department = Column(String(100))
    credits = Column(Integer)
    level = Column(String(20))  # 'undergraduate', 'postgraduate'
    description = Column(Text)
    syllabus_url = Column(Text)
    moodle_id = Column(String(100))
    year = Column(String(10))  # '2024/2025'
    term = Column(String(20))  # 'Term 1', 'Term 2', 'Term 3'
    instructor = Column(JSONB)  # {"name": "Dr. Smith", "email": "..."}
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    enrollments = relationship("Enrollment", back_populates="course", cascade="all, delete-orphan")
    timetable_events = relationship("TimetableEvent", back_populates="course", cascade="all, delete-orphan")
    assignments = relationship("Assignment", back_populates="course", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Course(code={self.course_code}, name={self.course_name})>"


class EnrollmentStatus(str, enum.Enum):
    """Enrollment status"""
    ACTIVE = "active"
    COMPLETED = "completed"
    DROPPED = "dropped"


class Enrollment(Base):
    """Student course enrollment"""
    __tablename__ = "enrollments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"), nullable=False)
    enrolled_at = Column(DateTime, default=datetime.utcnow)
    status = Column(SQLEnum(EnrollmentStatus), default=EnrollmentStatus.ACTIVE)
    final_grade = Column(String(10))  # 'A', 'B+', etc.
    grade_percentage = Column(Numeric(5, 2))  # 0.00 - 100.00

    # Relationships
    student = relationship("User", back_populates="enrollments")
    course = relationship("Course", back_populates="enrollments")
    submissions = relationship("AssignmentSubmission", back_populates="enrollment", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Enrollment(student={self.student_id}, course={self.course_id})>"


class TimetableEvent(Base):
    """Course timetable events"""
    __tablename__ = "timetable_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"))
    event_type = Column(String(50))  # 'lecture', 'tutorial', 'lab', 'seminar'
    title = Column(String(200))
    description = Column(Text)
    location = Column(String(200))
    building = Column(String(100))
    room_number = Column(String(50))
    start_time = Column(DateTime, nullable=False, index=True)
    end_time = Column(DateTime, nullable=False)
    recurrence_rule = Column(Text)  # iCalendar RRULE format
    instructor = Column(JSONB)
    ucl_api_data = Column(JSONB)  # Raw UCL API data
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    course = relationship("Course", back_populates="timetable_events")

    def __repr__(self):
        return f"<TimetableEvent(title={self.title}, start={self.start_time})>"


class Assignment(Base):
    """Course assignments"""
    __tablename__ = "assignments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id = Column(UUID(as_uuid=True), ForeignKey("courses.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    type = Column(String(50))  # 'essay', 'problem_set', 'project', 'exam'
    total_points = Column(Numeric(5, 2))
    weight_percentage = Column(Numeric(5, 2))
    due_date = Column(DateTime, index=True)
    submission_url = Column(Text)
    requirements = Column(JSONB)
    rubric = Column(JSONB)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    course = relationship("Course", back_populates="assignments")
    submissions = relationship("AssignmentSubmission", back_populates="assignment", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Assignment(title={self.title}, due={self.due_date})>"


class SubmissionStatus(str, enum.Enum):
    """Assignment submission status"""
    PENDING = "pending"
    SUBMITTED = "submitted"
    GRADED = "graded"


class AssignmentSubmission(Base):
    """Student assignment submissions"""
    __tablename__ = "assignment_submissions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    assignment_id = Column(UUID(as_uuid=True), ForeignKey("assignments.id", ondelete="CASCADE"), nullable=False)
    enrollment_id = Column(UUID(as_uuid=True), ForeignKey("enrollments.id", ondelete="CASCADE"), nullable=False)
    submitted_at = Column(DateTime)
    grade = Column(Numeric(5, 2))
    feedback = Column(Text)
    files = Column(JSONB)  # [{"filename": "...", "url": "..."}]
    status = Column(SQLEnum(SubmissionStatus), default=SubmissionStatus.PENDING)
    late_submission = Column(Boolean, default=False)

    # Relationships
    assignment = relationship("Assignment", back_populates="submissions")
    enrollment = relationship("Enrollment", back_populates="submissions")

    def __repr__(self):
        return f"<AssignmentSubmission(assignment={self.assignment_id}, status={self.status})>"
