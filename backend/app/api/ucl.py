"""
UCL data endpoints for timetables, rooms, and activities.
"""
from fastapi import APIRouter, Depends, HTTPException
from typing import List, Optional
from app.api.auth import get_current_active_user
from app.models.user import User
from app.services.ucl_api_service import UCLAPIService

router = APIRouter()


@router.get("/timetable/personal")
async def get_personal_timetable(
    current_user: User = Depends(get_current_active_user)
):
    """Get personal timetable for current user."""
    async with UCLAPIService() as ucl_service:
        # Use user's UCL token if available
        token = current_user.ucl_access_token if current_user.ucl_access_token else None
        timetable = await ucl_service.get_personal_timetable(token)
        return {"timetable": timetable}


@router.get("/timetable/modules")
async def get_timetable_by_modules(
    modules: str,  # Comma-separated module codes
    current_user: User = Depends(get_current_active_user)
):
    """Get timetable by module codes."""
    module_list = [m.strip() for m in modules.split(",")]

    async with UCLAPIService() as ucl_service:
        timetable = await ucl_service.get_timetable_by_modules(module_list)
        return {"timetable": timetable}


@router.get("/rooms")
async def get_rooms(
    roomname: Optional[str] = None,
    roomid: Optional[str] = None,
    siteid: Optional[str] = None,
    current_user: User = Depends(get_current_active_user)
):
    """Get room information."""
    async with UCLAPIService() as ucl_service:
        rooms = await ucl_service.get_rooms(roomname, roomid, siteid)
        return {"rooms": rooms}


@router.get("/rooms/bookings")
async def get_room_bookings(
    roomid: str,
    siteid: str,
    start_datetime: Optional[str] = None,
    end_datetime: Optional[str] = None,
    current_user: User = Depends(get_current_active_user)
):
    """Get room bookings."""
    async with UCLAPIService() as ucl_service:
        bookings = await ucl_service.get_room_bookings(
            roomid, siteid, start_datetime, end_datetime
        )
        return {"bookings": bookings}


@router.get("/search/people")
async def search_people(
    query: str,
    current_user: User = Depends(get_current_active_user)
):
    """Search for people at UCL."""
    async with UCLAPIService() as ucl_service:
        people = await ucl_service.search_people(query)
        return {"people": people}
