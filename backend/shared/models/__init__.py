"""Database models"""
from .user import User, UserRole, StudentParentLink
from .course import (
    Course,
    Enrollment,
    EnrollmentStatus,
    TimetableEvent,
    Assignment,
    AssignmentSubmission,
    SubmissionStatus,
)
from .email import Email
from .activity import UCLActivity, ActivityParticipation, ParticipationStatus
from .health import (
    MedicalRecord,
    Prescription,
    HealthMetric,
    MedicalAppointment,
    AppointmentStatus,
)
from .chat import (
    ChatSession,
    ChatMessage,
    MessageRole,
    UserFeedback,
    FeedbackType,
    KnowledgeDocument,
)
from .notification import Notification

__all__ = [
    # User
    "User",
    "UserRole",
    "StudentParentLink",
    # Course
    "Course",
    "Enrollment",
    "EnrollmentStatus",
    "TimetableEvent",
    "Assignment",
    "AssignmentSubmission",
    "SubmissionStatus",
    # Email
    "Email",
    # Activity
    "UCLActivity",
    "ActivityParticipation",
    "ParticipationStatus",
    # Health
    "MedicalRecord",
    "Prescription",
    "HealthMetric",
    "MedicalAppointment",
    "AppointmentStatus",
    # Chat
    "ChatSession",
    "ChatMessage",
    "MessageRole",
    "UserFeedback",
    "FeedbackType",
    "KnowledgeDocument",
    # Notification
    "Notification",
]
