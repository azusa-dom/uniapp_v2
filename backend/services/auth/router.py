"""
Authentication API routes
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from shared.database import get_db
from shared.utils import decode_token
from .schemas import (
    UserRegister,
    UserLogin,
    TokenResponse,
    UserResponse,
    UserUpdate,
    PasswordChange,
)
from .service import AuthService

router = APIRouter(prefix="/auth", tags=["Authentication"])
security = HTTPBearer()


async def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    """Dependency to get current user ID from JWT token"""
    token = credentials.credentials
    payload = decode_token(token)

    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload"
        )

    return user_id


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserRegister,
    db: AsyncSession = Depends(get_db)
):
    """Register a new user"""
    user = await AuthService.register_user(user_data, db)
    return user


@router.post("/login", response_model=TokenResponse)
async def login(
    login_data: UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """Login and get access tokens"""
    return await AuthService.login(login_data, db)


@router.get("/me", response_model=UserResponse)
async def get_me(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get current user information"""
    user = await AuthService.get_current_user(user_id, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user


@router.patch("/me", response_model=UserResponse)
async def update_me(
    update_data: UserUpdate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Update current user information"""
    return await AuthService.update_user(user_id, update_data, db)


@router.post("/change-password", status_code=status.HTTP_200_OK)
async def change_password(
    password_data: PasswordChange,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Change user password"""
    await AuthService.change_password(
        user_id,
        password_data.current_password,
        password_data.new_password,
        db
    )
    return {"message": "Password changed successfully"}


@router.post("/logout")
async def logout(user_id: str = Depends(get_current_user_id)):
    """Logout user (client should discard token)"""
    # In a production system, you might want to blacklist the token
    return {"message": "Logged out successfully"}
