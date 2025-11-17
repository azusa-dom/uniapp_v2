"""
Academic endpoints for courses, assignments, and grades.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from datetime import datetime

from app.api.auth import get_current_active_user
from app.models.user import User
from app.models.academic import Course, Assignment, Grade
from app.database import get_db
from app.services.moodle_service import MoodleService

router = APIRouter()


@router.get("/courses")
async def get_courses(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get all courses for current user."""
    result = await db.execute(
        select(Course).where(Course.student_id == current_user.id)
    )
    courses = result.scalars().all()

    return [
        {
            "id": course.id,
            "course_code": course.course_code,
            "course_name": course.course_name,
            "department": course.department,
            "credits": course.credits,
            "current_grade": course.current_grade,
            "module_average": course.module_average,
            "instructor_name": course.instructor_name
        }
        for course in courses
    ]


@router.get("/courses/{course_id}/assignments")
async def get_course_assignments(
    course_id: int,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get assignments for a specific course."""
    # Verify course belongs to user
    result = await db.execute(
        select(Course).where(
            Course.id == course_id,
            Course.student_id == current_user.id
        )
    )
    course = result.scalar_one_or_none()

    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    result = await db.execute(
        select(Assignment).where(Assignment.course_id == course_id)
    )
    assignments = result.scalars().all()

    return [
        {
            "id": assignment.id,
            "name": assignment.name,
            "description": assignment.description,
            "assignment_type": assignment.assignment_type,
            "weight": assignment.weight,
            "due_date": assignment.due_date.isoformat() if assignment.due_date else None,
            "submitted": assignment.submitted,
            "grade": assignment.grade,
            "max_grade": assignment.max_grade,
            "feedback": assignment.feedback
        }
        for assignment in assignments
    ]


@router.get("/assignments/upcoming")
async def get_upcoming_assignments(
    limit: int = 10,
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get upcoming assignments across all courses."""
    # Get user's course IDs
    course_result = await db.execute(
        select(Course.id).where(Course.student_id == current_user.id)
    )
    course_ids = [row[0] for row in course_result.all()]

    if not course_ids:
        return []

    # Get upcoming assignments
    now = datetime.utcnow()
    result = await db.execute(
        select(Assignment).where(
            Assignment.course_id.in_(course_ids),
            Assignment.due_date >= now,
            Assignment.submitted == False
        ).order_by(Assignment.due_date).limit(limit)
    )
    assignments = result.scalars().all()

    return [
        {
            "id": assignment.id,
            "name": assignment.name,
            "course_id": assignment.course_id,
            "due_date": assignment.due_date.isoformat() if assignment.due_date else None,
            "submitted": assignment.submitted,
            "weight": assignment.weight
        }
        for assignment in assignments
    ]


@router.post("/sync/moodle")
async def sync_moodle_data(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Sync courses and assignments from Moodle."""
    if not current_user.moodle_token:
        raise HTTPException(
            status_code=400,
            detail="Moodle token not configured for user"
        )

    async with MoodleService(current_user.moodle_token) as moodle:
        # Get courses
        moodle_courses = await moodle.get_user_courses()

        for moodle_course in moodle_courses:
            # Check if course exists
            result = await db.execute(
                select(Course).where(
                    Course.student_id == current_user.id,
                    Course.moodle_course_id == str(moodle_course["id"])
                )
            )
            course = result.scalar_one_or_none()

            if not course:
                # Create new course
                course = Course(
                    student_id=current_user.id,
                    course_code=moodle_course.get("shortname", ""),
                    course_name=moodle_course.get("fullname", ""),
                    moodle_course_id=str(moodle_course["id"])
                )
                db.add(course)
                await db.flush()

            # Get assignments for this course
            assignments = await moodle.get_assignments([moodle_course["id"]])

            for moodle_assignment in assignments:
                # Check if assignment exists
                result = await db.execute(
                    select(Assignment).where(
                        Assignment.course_id == course.id,
                        Assignment.moodle_assignment_id == str(moodle_assignment["id"])
                    )
                )
                assignment = result.scalar_one_or_none()

                if not assignment:
                    # Create new assignment
                    due_date = None
                    if moodle_assignment.get("duedate"):
                        due_date = datetime.fromtimestamp(moodle_assignment["duedate"])

                    assignment = Assignment(
                        course_id=course.id,
                        name=moodle_assignment.get("name", ""),
                        description=moodle_assignment.get("intro", ""),
                        due_date=due_date,
                        moodle_assignment_id=str(moodle_assignment["id"])
                    )
                    db.add(assignment)

        await db.commit()

    return {"message": "Moodle data synced successfully"}


@router.get("/grades/summary")
async def get_grades_summary(
    current_user: User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Get grade summary across all courses."""
    result = await db.execute(
        select(Course).where(Course.student_id == current_user.id)
    )
    courses = result.scalars().all()

    summary = {
        "overall_average": 0.0,
        "courses": []
    }

    total_credits = 0
    weighted_sum = 0

    for course in courses:
        if course.current_grade and course.credits:
            weighted_sum += course.current_grade * course.credits
            total_credits += course.credits

        summary["courses"].append({
            "course_code": course.course_code,
            "course_name": course.course_name,
            "current_grade": course.current_grade,
            "module_average": course.module_average,
            "credits": course.credits
        })

    if total_credits > 0:
        summary["overall_average"] = weighted_sum / total_credits

    return summary
