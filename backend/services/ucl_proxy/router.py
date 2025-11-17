"""
UCL API Proxy Router
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel

from services.auth import get_current_user_id
from .client import ucl_client

router = APIRouter(prefix="/ucl", tags=["UCL API"])


class TimetableEvent(BaseModel):
    """Timetable event schema"""
    module_code: Optional[str]
    module_name: Optional[str]
    session_type: Optional[str]
    start_time: Optional[str]
    end_time: Optional[str]
    location: Optional[str]


class Room(BaseModel):
    """Room schema"""
    roomid: str
    roomname: str
    siteid: Optional[str]
    sitename: Optional[str]
    capacity: Optional[int]


@router.get("/timetable/personal")
async def get_personal_timetable(
    client_secret: str = Query(..., description="UCL API client secret"),
    user_id: str = Depends(get_current_user_id)
):
    """Get personal timetable"""
    events = await ucl_client.get_personal_timetable(client_secret)
    return {"events": events}


@router.get("/timetable/modules")
async def get_timetable_by_modules(
    modules: List[str] = Query(..., description="Module codes"),
    date: Optional[str] = Query(None, description="Date in YYYY-MM-DD format"),
    user_id: str = Depends(get_current_user_id)
):
    """Get timetable by module codes"""
    events = await ucl_client.get_timetable_by_modules(modules, date)
    return {"events": events}


@router.get("/rooms", response_model=List[Room])
async def get_rooms(
    user_id: str = Depends(get_current_user_id)
):
    """Get list of all rooms"""
    rooms = await ucl_client.get_rooms()
    return rooms


@router.get("/rooms/{roomid}/bookings")
async def get_room_bookings(
    roomid: str,
    date: Optional[str] = Query(None, description="Date in YYYY-MM-DD format"),
    user_id: str = Depends(get_current_user_id)
):
    """Get room bookings"""
    bookings = await ucl_client.get_room_bookings(roomid, date)
    return {"bookings": bookings}


@router.get("/search/people")
async def search_people(
    q: str = Query(..., min_length=2, description="Search query"),
    user_id: str = Depends(get_current_user_id)
):
    """Search for people"""
    people = await ucl_client.search_people(q)
    return {"people": people}
