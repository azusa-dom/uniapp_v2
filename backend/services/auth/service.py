"""
Authentication service business logic
"""
from typing import Optional
from datetime import datetime
import uuid
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status

from shared.models.user import User, UserRole
from shared.utils import hash_password, verify_password, create_access_token, create_refresh_token
from .schemas import UserRegister, UserLogin, TokenResponse, UserUpdate


class AuthService:
    """Authentication service"""

    @staticmethod
    async def register_user(
        user_data: UserRegister,
        db: AsyncSession
    ) -> User:
        """
        Register a new user

        Args:
            user_data: User registration data
            db: Database session

        Returns:
            Created user

        Raises:
            HTTPException: If email already exists
        """
        # Check if user already exists
        result = await db.execute(
            select(User).where(User.email == user_data.email)
        )
        existing_user = result.scalar_one_or_none()

        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )

        # Create new user
        hashed_password = hash_password(user_data.password)
        user = User(
            id=uuid.uuid4(),
            email=user_data.email,
            password_hash=hashed_password,
            full_name=user_data.full_name,
            role=user_data.role,
            ucl_id=user_data.ucl_id,
            is_active=True,
            is_verified=False,
        )

        db.add(user)
        await db.commit()
        await db.refresh(user)

        return user

    @staticmethod
    async def login(
        login_data: UserLogin,
        db: AsyncSession
    ) -> TokenResponse:
        """
        Authenticate user and generate tokens

        Args:
            login_data: Login credentials
            db: Database session

        Returns:
            Access and refresh tokens

        Raises:
            HTTPException: If credentials are invalid
        """
        # Find user by email
        result = await db.execute(
            select(User).where(User.email == login_data.email)
        )
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # Verify password
        if not verify_password(login_data.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # Check if user is active
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is inactive"
            )

        # Update last login
        user.last_login_at = datetime.utcnow()
        await db.commit()

        # Generate tokens
        token_data = {
            "sub": str(user.id),
            "email": user.email,
            "role": user.role.value,
        }

        access_token = create_access_token(token_data)
        refresh_token = create_refresh_token(token_data)

        from shared.config import settings
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.jwt_access_token_expire_minutes * 60
        )

    @staticmethod
    async def get_current_user(
        user_id: str,
        db: AsyncSession
    ) -> Optional[User]:
        """
        Get user by ID

        Args:
            user_id: User ID
            db: Database session

        Returns:
            User or None if not found
        """
        result = await db.execute(
            select(User).where(User.id == uuid.UUID(user_id))
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def update_user(
        user_id: str,
        update_data: UserUpdate,
        db: AsyncSession
    ) -> User:
        """
        Update user information

        Args:
            user_id: User ID
            update_data: Update data
            db: Database session

        Returns:
            Updated user

        Raises:
            HTTPException: If user not found
        """
        result = await db.execute(
            select(User).where(User.id == uuid.UUID(user_id))
        )
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Update fields
        for field, value in update_data.dict(exclude_unset=True).items():
            setattr(user, field, value)

        user.updated_at = datetime.utcnow()
        await db.commit()
        await db.refresh(user)

        return user

    @staticmethod
    async def change_password(
        user_id: str,
        current_password: str,
        new_password: str,
        db: AsyncSession
    ) -> bool:
        """
        Change user password

        Args:
            user_id: User ID
            current_password: Current password
            new_password: New password
            db: Database session

        Returns:
            True if successful

        Raises:
            HTTPException: If current password is incorrect
        """
        result = await db.execute(
            select(User).where(User.id == uuid.UUID(user_id))
        )
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Verify current password
        if not verify_password(current_password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Current password is incorrect"
            )

        # Update password
        user.password_hash = hash_password(new_password)
        user.updated_at = datetime.utcnow()
        await db.commit()

        return True
