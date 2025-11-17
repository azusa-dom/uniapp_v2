"""
Academic models for courses, assignments, and grades.
"""
from sqlalchemy import Column, String, Integer, Float, DateTime, Boolean, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Course(Base):
    """Course model for student modules."""
    __tablename__ = "courses"

    id = Column(Integer, primary_key=True, index=True)
    student_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)

    # Course information
    course_code = Column(String(50), nullable=False, index=True)
    course_name = Column(String(255), nullable=False)
    department = Column(String(100), nullable=True)
    credits = Column(Integer, default=15)
    semester = Column(String(50), nullable=True)
    academic_year = Column(String(20), nullable=True)

    # Instructor info
    instructor_name = Column(String(255), nullable=True)
    instructor_email = Column(String(255), nullable=True)

    # Moodle integration
    moodle_course_id = Column(String(100), nullable=True, index=True)

    # Grade information
    current_grade = Column(Float, nullable=True)
    module_average = Column(Float, nullable=True)
    grade_breakdown = Column(JSON, nullable=True)  # Component grades

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    student = relationship("User", back_populates="courses")
    assignments = relationship("Assignment", back_populates="course", cascade="all, delete-orphan")
    grades = relationship("Grade", back_populates="course", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Course {self.course_code}: {self.course_name}>"


class Assignment(Base):
    """Assignment model for coursework."""
    __tablename__ = "assignments"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"), nullable=False)

    # Assignment details
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    assignment_type = Column(String(50), nullable=True)  # essay, exam, project, etc.
    weight = Column(Float, nullable=True)  # Percentage weight in final grade

    # Dates
    assigned_date = Column(DateTime(timezone=True), nullable=True)
    due_date = Column(DateTime(timezone=True), nullable=True)
    submission_date = Column(DateTime(timezone=True), nullable=True)

    # Submission
    submitted = Column(Boolean, default=False)
    submission_url = Column(String(500), nullable=True)
    submission_status = Column(String(50), default="pending")  # pending, submitted, graded

    # Grading
    grade = Column(Float, nullable=True)
    max_grade = Column(Float, default=100.0)
    feedback = Column(Text, nullable=True)

    # Moodle integration
    moodle_assignment_id = Column(String(100), nullable=True, index=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    course = relationship("Course", back_populates="assignments")

    def __repr__(self):
        return f"<Assignment {self.name}>"


class Grade(Base):
    """Grade model for academic performance tracking."""
    __tablename__ = "grades"

    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id", ondelete="CASCADE"), nullable=False)

    # Grade component
    component_name = Column(String(255), nullable=False)
    component_type = Column(String(50), nullable=True)  # exam, coursework, participation
    weight = Column(Float, nullable=False)  # Percentage weight

    # Score
    score = Column(Float, nullable=True)
    max_score = Column(Float, default=100.0)
    grade_letter = Column(String(5), nullable=True)  # A, B+, etc.

    # Metadata
    graded_date = Column(DateTime(timezone=True), nullable=True)
    comments = Column(Text, nullable=True)

    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    course = relationship("Course", back_populates="grades")

    def __repr__(self):
        return f"<Grade {self.component_name}: {self.score}/{self.max_score}>"
