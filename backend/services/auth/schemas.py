"""
Authentication schemas (Pydantic models)
"""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, validator
from shared.models.user import UserRole


class UserRegister(BaseModel):
    """User registration schema"""
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str = Field(..., min_length=1, max_length=100)
    role: UserRole
    ucl_id: Optional[str] = None

    @validator("password")
    def validate_password(cls, v):
        """Validate password strength"""
        from shared.utils import validate_password_strength
        is_valid, error = validate_password_strength(v)
        if not is_valid:
            raise ValueError(error)
        return v


class UserLogin(BaseModel):
    """User login schema"""
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    """Token response schema"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class UserResponse(BaseModel):
    """User response schema"""
    id: str
    email: str
    full_name: Optional[str]
    role: UserRole
    ucl_id: Optional[str]
    department: Optional[str]
    programme: Optional[str]
    year_of_study: Optional[int]
    profile_picture_url: Optional[str]
    is_active: bool
    is_verified: bool
    created_at: datetime

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    """User update schema"""
    full_name: Optional[str] = None
    department: Optional[str] = None
    programme: Optional[str] = None
    year_of_study: Optional[int] = None
    phone_number: Optional[str] = None
    emergency_contact: Optional[dict] = None
    preferences: Optional[dict] = None


class PasswordChange(BaseModel):
    """Password change schema"""
    current_password: str
    new_password: str = Field(..., min_length=8)

    @validator("new_password")
    def validate_new_password(cls, v):
        """Validate new password strength"""
        from shared.utils import validate_password_strength
        is_valid, error = validate_password_strength(v)
        if not is_valid:
            raise ValueError(error)
        return v
