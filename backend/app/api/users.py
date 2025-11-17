"""
User management endpoints.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.database import get_db
from app.models.user import User, ParentStudentLink, UserRole
from app.schemas.user import UserResponse, UserUpdate, ParentStudentLinkCreate, ParentStudentLinkResponse
from app.api.auth import get_current_active_user

router = APIRouter()


@router.get("/profile", response_model=UserResponse)
async def get_user_profile(
    current_user: User = Depends(get_current_active_user)
):
    """Get current user profile."""
    return current_user


@router.put("/profile", response_model=UserResponse)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Update current user profile."""
    # Update user fields
    if user_update.full_name is not None:
        current_user.full_name = user_update.full_name
    if user_update.phone is not None:
        current_user.phone = user_update.phone
    if user_update.department is not None:
        current_user.department = user_update.department
    if user_update.program is not None:
        current_user.program = user_update.program
    if user_update.year_of_study is not None:
        current_user.year_of_study = user_update.year_of_study

    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.post("/link-student", response_model=ParentStudentLinkResponse)
async def link_student_to_parent(
    link_data: ParentStudentLinkCreate,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Link a student to a parent account."""
    # Verify current user is a parent
    if current_user.role != UserRole.PARENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only parents can link students"
        )

    # Find student by email
    result = await db.execute(
        select(User).where(
            User.email == link_data.student_email,
            User.role == UserRole.STUDENT
        )
    )
    student = result.scalar_one_or_none()

    if not student:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student not found"
        )

    # Check if link already exists
    result = await db.execute(
        select(ParentStudentLink).where(
            ParentStudentLink.parent_id == current_user.id,
            ParentStudentLink.student_id == student.id
        )
    )
    if result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Student already linked"
        )

    # Create link
    link = ParentStudentLink(
        parent_id=current_user.id,
        student_id=student.id,
        relationship_type=link_data.relationship_type
    )
    db.add(link)
    await db.commit()
    await db.refresh(link)

    return link


@router.get("/students", response_model=List[UserResponse])
async def get_linked_students(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get all students linked to current parent."""
    if current_user.role != UserRole.PARENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only parents can access this endpoint"
        )

    # Get student IDs linked to parent
    result = await db.execute(
        select(ParentStudentLink.student_id).where(
            ParentStudentLink.parent_id == current_user.id
        )
    )
    student_ids = [row[0] for row in result.all()]

    if not student_ids:
        return []

    # Get student details
    result = await db.execute(
        select(User).where(User.id.in_(student_ids))
    )
    students = result.scalars().all()

    return students


@router.get("/parents", response_model=List[UserResponse])
async def get_linked_parents(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get all parents linked to current student."""
    if current_user.role != UserRole.STUDENT:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can access this endpoint"
        )

    # Get parent IDs linked to student
    result = await db.execute(
        select(ParentStudentLink.parent_id).where(
            ParentStudentLink.student_id == current_user.id
        )
    )
    parent_ids = [row[0] for row in result.all()]

    if not parent_ids:
        return []

    # Get parent details
    result = await db.execute(
        select(User).where(User.id.in_(parent_ids))
    )
    parents = result.scalars().all()

    return parents
