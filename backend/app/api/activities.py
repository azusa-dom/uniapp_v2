"""
Activities endpoints for UCL campus events and personalized recommendations.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc
from typing import List, Optional
from datetime import datetime, timedelta

from app.api.auth import get_current_active_user
from app.models.user import User
from app.models.activity import Activity, ActivityType
from app.database import get_db

router = APIRouter()


@router.get("/")
async def get_activities(
    activity_type: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    limit: int = 50,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get activities with optional filters."""
    query = select(Activity)

    filters = []
    if activity_type:
        filters.append(Activity.activity_type == ActivityType(activity_type))

    if start_date:
        start_dt = datetime.fromisoformat(start_date)
        filters.append(Activity.start_time >= start_dt)

    if end_date:
        end_dt = datetime.fromisoformat(end_date)
        filters.append(Activity.end_time <= end_dt)

    if filters:
        query = query.where(and_(*filters))

    query = query.order_by(Activity.start_time).limit(limit)

    result = await db.execute(query)
    activities = result.scalars().all()

    return [
        {
            "id": activity.id,
            "title": activity.title,
            "description": activity.description,
            "activity_type": activity.activity_type.value,
            "location": activity.location,
            "start_time": activity.start_time.isoformat(),
            "end_time": activity.end_time.isoformat(),
            "is_free": activity.is_free,
            "price": activity.price,
            "registration_required": activity.registration_required,
            "is_recommended": activity.is_recommended
        }
        for activity in activities
    ]


@router.get("/recommended")
async def get_recommended_activities(
    limit: int = 10,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get personalized recommended activities for current user."""
    # Simple recommendation: academic/lecture/seminar types for students
    # In production, this would use more sophisticated ML-based recommendations

    now = datetime.utcnow()
    recommended_types = [ActivityType.ACADEMIC, ActivityType.LECTURE, ActivityType.SEMINAR, ActivityType.CAREER]

    result = await db.execute(
        select(Activity).where(
            and_(
                Activity.activity_type.in_(recommended_types),
                Activity.start_time >= now,
                Activity.is_recommended == True
            )
        ).order_by(desc(Activity.recommendation_score)).limit(limit)
    )
    activities = result.scalars().all()

    return [
        {
            "id": activity.id,
            "title": activity.title,
            "description": activity.description,
            "activity_type": activity.activity_type.value,
            "location": activity.location,
            "start_time": activity.start_time.isoformat(),
            "end_time": activity.end_time.isoformat(),
            "recommendation_score": activity.recommendation_score,
            "recommendation_reason": activity.recommendation_reason
        }
        for activity in activities
    ]


@router.get("/upcoming")
async def get_upcoming_activities(
    days: int = 7,
    limit: int = 20,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get upcoming activities for the next N days."""
    now = datetime.utcnow()
    end_date = now + timedelta(days=days)

    result = await db.execute(
        select(Activity).where(
            and_(
                Activity.start_time >= now,
                Activity.start_time <= end_date
            )
        ).order_by(Activity.start_time).limit(limit)
    )
    activities = result.scalars().all()

    return [
        {
            "id": activity.id,
            "title": activity.title,
            "activity_type": activity.activity_type.value,
            "location": activity.location,
            "start_time": activity.start_time.isoformat(),
            "end_time": activity.end_time.isoformat(),
            "is_recommended": activity.is_recommended
        }
        for activity in activities
    ]


@router.post("/{activity_id}/bookmark")
async def bookmark_activity(
    activity_id: int,
    bookmarked: bool,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Bookmark or unbookmark an activity."""
    result = await db.execute(
        select(Activity).where(Activity.id == activity_id)
    )
    activity = result.scalar_one_or_none()

    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    activity.is_bookmarked = bookmarked
    await db.commit()

    return {"success": True, "is_bookmarked": activity.is_bookmarked}


@router.post("/{activity_id}/register")
async def register_for_activity(
    activity_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Register for an activity."""
    result = await db.execute(
        select(Activity).where(Activity.id == activity_id)
    )
    activity = result.scalar_one_or_none()

    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")

    activity.is_registered = True
    await db.commit()

    return {
        "success": True,
        "message": f"Successfully registered for {activity.title}",
        "registration_url": activity.registration_url
    }
