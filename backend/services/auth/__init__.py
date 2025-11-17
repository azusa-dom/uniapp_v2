"""Authentication service"""
from .router import router, get_current_user_id
from .service import AuthService
from .schemas import UserRegister, UserLogin, TokenResponse, UserResponse

__all__ = [
    "router",
    "get_current_user_id",
    "AuthService",
    "UserRegister",
    "UserLogin",
    "TokenResponse",
    "UserResponse",
]
