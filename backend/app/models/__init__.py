"""Database models."""
from .user import User, UserRole, ParentStudentLink
from .email import Email, EmailCategory
from .academic import Course, Assignment, Grade
from .activity import Activity, ActivityType
from .ai_conversation import Conversation, Message

__all__ = [
    "User",
    "UserRole",
    "ParentStudentLink",
    "Email",
    "EmailCategory",
    "Course",
    "Assignment",
    "Grade",
    "Activity",
    "ActivityType",
    "Conversation",
    "Message",
]
