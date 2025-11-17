"""
UCL API Client
Wrapper for UCL API endpoints
"""
from typing import List, Dict, Any, Optional
import httpx
from datetime import datetime

from shared.config import settings
from shared.database import redis_client


class UCLAPIClient:
    """UCL API client with caching"""

    def __init__(self):
        self.base_url = settings.ucl_api_base_url
        self.token = settings.ucl_api_token
        self.cache_ttl = 3600  # 1 hour

    async def _make_request(
        self,
        endpoint: str,
        params: Optional[Dict[str, Any]] = None,
        cache_key: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Make HTTP request to UCL API with caching

        Args:
            endpoint: API endpoint
            params: Query parameters
            cache_key: Redis cache key

        Returns:
            API response data
        """
        # Check cache first
        if cache_key:
            cached = await redis_client.get(cache_key)
            if cached:
                import json
                return json.loads(cached)

        # Make request
        url = f"{self.base_url}{endpoint}"
        params = params or {}
        params["token"] = self.token

        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, timeout=30.0)
            response.raise_for_status()
            data = response.json()

        # Cache response
        if cache_key:
            import json
            await redis_client.set(cache_key, json.dumps(data), expire=self.cache_ttl)

        return data

    async def get_personal_timetable(
        self,
        client_secret: str
    ) -> List[Dict[str, Any]]:
        """
        Get personal timetable

        Args:
            client_secret: User's UCL API client secret

        Returns:
            List of timetable events
        """
        cache_key = f"ucl:timetable:{client_secret}"
        data = await self._make_request(
            "/timetable/personal",
            params={"client_secret": client_secret},
            cache_key=cache_key
        )
        return data.get("timetable", [])

    async def get_timetable_by_modules(
        self,
        modules: List[str],
        date: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Get timetable by module codes

        Args:
            modules: List of module codes
            date: Date in YYYY-MM-DD format

        Returns:
            List of timetable events
        """
        params = {
            "modules": ",".join(modules),
        }
        if date:
            params["date"] = date

        cache_key = f"ucl:timetable:modules:{'-'.join(modules)}:{date}"
        data = await self._make_request(
            "/timetable/bymodule",
            params=params,
            cache_key=cache_key
        )
        return data.get("timetable", [])

    async def get_rooms(self) -> List[Dict[str, Any]]:
        """
        Get list of rooms

        Returns:
            List of rooms
        """
        cache_key = "ucl:rooms"
        data = await self._make_request(
            "/roombookings/rooms",
            cache_key=cache_key
        )
        return data.get("rooms", [])

    async def get_room_bookings(
        self,
        roomid: str,
        date: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Get room bookings

        Args:
            roomid: Room ID
            date: Date in YYYY-MM-DD format

        Returns:
            List of bookings
        """
        params = {"roomid": roomid}
        if date:
            params["date"] = date

        cache_key = f"ucl:bookings:{roomid}:{date}"
        data = await self._make_request(
            "/roombookings/bookings",
            params=params,
            cache_key=cache_key
        )
        return data.get("bookings", [])

    async def search_people(
        self,
        query: str
    ) -> List[Dict[str, Any]]:
        """
        Search for people

        Args:
            query: Search query

        Returns:
            List of people
        """
        data = await self._make_request(
            "/search/people",
            params={"query": query}
        )
        return data.get("people", [])


# Global instance
ucl_client = UCLAPIClient()
