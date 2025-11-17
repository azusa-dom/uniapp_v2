"""
UCL API service for fetching timetables, room bookings, and other UCL data.
"""
import httpx
from typing import List, Dict, Any, Optional
from datetime import datetime
import logging
from config import settings

logger = logging.getLogger(__name__)


class UCLAPIService:
    """Service for interacting with UCL API."""

    def __init__(self):
        self.base_url = settings.UCL_API_BASE_URL
        self.token = settings.UCL_API_TOKEN
        self.client = httpx.AsyncClient(timeout=30.0)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()

    def _build_url(self, endpoint: str, params: Dict[str, Any] = None) -> str:
        """Build URL with token parameter."""
        if params is None:
            params = {}
        params["token"] = self.token
        return f"{self.base_url}{endpoint}"

    async def _make_request(self, endpoint: str, params: Dict[str, Any] = None) -> Dict[str, Any]:
        """Make HTTP request to UCL API."""
        if params is None:
            params = {}
        params["token"] = self.token

        try:
            response = await self.client.get(
                f"{self.base_url}{endpoint}",
                params=params
            )
            response.raise_for_status()
            data = response.json()

            if not data.get("ok", False):
                logger.error(f"UCL API error: {data.get('error', 'Unknown error')}")
                raise Exception(f"UCL API error: {data.get('error', 'Unknown error')}")

            return data
        except httpx.HTTPError as e:
            logger.error(f"HTTP error calling UCL API: {e}")
            raise
        except Exception as e:
            logger.error(f"Error calling UCL API: {e}")
            raise

    async def get_personal_timetable(self, ucl_token: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Get personal timetable for a user.

        Args:
            ucl_token: User's UCL API token (if different from default)

        Returns:
            List of timetable events
        """
        params = {}
        if ucl_token:
            params["token"] = ucl_token
        else:
            params["token"] = self.token

        try:
            data = await self._make_request("/timetable/personal", params)

            # Flatten timetable events from different dates
            events = []
            if "timetable" in data:
                for date, date_events in data["timetable"].items():
                    events.extend(date_events)

            return events
        except Exception as e:
            logger.error(f"Error fetching personal timetable: {e}")
            return []

    async def get_timetable_by_modules(self, modules: List[str]) -> List[Dict[str, Any]]:
        """
        Get timetable by module codes.

        Args:
            modules: List of module codes

        Returns:
            List of timetable events
        """
        params = {
            "modules": ",".join(modules)
        }

        try:
            data = await self._make_request("/timetable/bymodule", params)

            events = []
            if "timetable" in data:
                for date, date_events in data["timetable"].items():
                    events.extend(date_events)

            return events
        except Exception as e:
            logger.error(f"Error fetching timetable by modules: {e}")
            return []

    async def get_rooms(self,
                        roomname: Optional[str] = None,
                        roomid: Optional[str] = None,
                        siteid: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Get room information.

        Args:
            roomname: Filter by room name
            roomid: Filter by room ID
            siteid: Filter by site ID

        Returns:
            List of rooms
        """
        params = {}
        if roomname:
            params["roomname"] = roomname
        if roomid:
            params["roomid"] = roomid
        if siteid:
            params["siteid"] = siteid

        try:
            data = await self._make_request("/roombookings/rooms", params)
            return data.get("rooms", [])
        except Exception as e:
            logger.error(f"Error fetching rooms: {e}")
            return []

    async def get_room_bookings(self,
                                 roomid: str,
                                 siteid: str,
                                 start_datetime: Optional[str] = None,
                                 end_datetime: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Get room bookings for a specific room.

        Args:
            roomid: Room ID
            siteid: Site ID
            start_datetime: Start datetime (ISO format)
            end_datetime: End datetime (ISO format)

        Returns:
            List of bookings
        """
        params = {
            "roomid": roomid,
            "siteid": siteid
        }
        if start_datetime:
            params["start_datetime"] = start_datetime
        if end_datetime:
            params["end_datetime"] = end_datetime

        try:
            data = await self._make_request("/roombookings/bookings", params)
            return data.get("bookings", [])
        except Exception as e:
            logger.error(f"Error fetching room bookings: {e}")
            return []

    async def search_people(self, query: str) -> List[Dict[str, Any]]:
        """
        Search for people at UCL.

        Args:
            query: Search query

        Returns:
            List of people
        """
        params = {"query": query}

        try:
            data = await self._make_request("/search/people", params)
            return data.get("people", [])
        except Exception as e:
            logger.error(f"Error searching people: {e}")
            return []

    async def close(self):
        """Close the HTTP client."""
        await self.client.aclose()
