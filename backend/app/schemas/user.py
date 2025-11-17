"""
User schemas for request/response validation.
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from app.models.user import UserRole


class UserBase(BaseModel):
    """Base user schema."""
    email: EmailStr
    full_name: str
    role: UserRole


class UserCreate(UserBase):
    """Schema for creating a new user."""
    password: str = Field(..., min_length=8)
    ucl_id: Optional[str] = None
    phone: Optional[str] = None
    department: Optional[str] = None
    program: Optional[str] = None
    year_of_study: Optional[int] = None


class UserLogin(BaseModel):
    """Schema for user login."""
    email: EmailStr
    password: str


class UserResponse(UserBase):
    """Schema for user response."""
    id: int
    ucl_id: Optional[str] = None
    is_active: bool
    is_verified: bool
    phone: Optional[str] = None
    department: Optional[str] = None
    program: Optional[str] = None
    year_of_study: Optional[int] = None
    created_at: datetime
    last_login: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """Schema for updating user profile."""
    full_name: Optional[str] = None
    phone: Optional[str] = None
    department: Optional[str] = None
    program: Optional[str] = None
    year_of_study: Optional[int] = None


class Token(BaseModel):
    """Schema for authentication tokens."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Schema for token payload data."""
    user_id: int
    email: str
    role: UserRole


class ParentStudentLinkCreate(BaseModel):
    """Schema for creating parent-student link."""
    student_email: EmailStr
    relationship_type: str = "guardian"


class ParentStudentLinkResponse(BaseModel):
    """Schema for parent-student link response."""
    id: int
    parent_id: int
    student_id: int
    relationship_type: str
    verified: bool
    created_at: datetime

    class Config:
        from_attributes = True
