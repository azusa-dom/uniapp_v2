"""
Moodle Web Service API integration.
"""
import httpx
from typing import List, Dict, Any, Optional
import logging
from config import settings

logger = logging.getLogger(__name__)


class MoodleService:
    """Service for interacting with Moodle Web Service API."""

    def __init__(self, token: Optional[str] = None):
        self.base_url = settings.MOODLE_BASE_URL
        self.token = token or settings.MOODLE_WS_TOKEN
        self.client = httpx.AsyncClient(timeout=30.0)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()

    async def _call_function(self, function: str, params: Dict[str, Any] = None) -> Any:
        """
        Call a Moodle web service function.

        Args:
            function: Moodle web service function name
            params: Function parameters

        Returns:
            Function response data
        """
        if params is None:
            params = {}

        url = f"{self.base_url}/webservice/rest/server.php"

        data = {
            "wstoken": self.token,
            "wsfunction": function,
            "moodlewsrestformat": "json",
            **params
        }

        try:
            response = await self.client.post(url, data=data)
            response.raise_for_status()
            result = response.json()

            # Check for errors
            if isinstance(result, dict) and "exception" in result:
                logger.error(f"Moodle API error: {result.get('message', 'Unknown error')}")
                raise Exception(f"Moodle API error: {result.get('message', 'Unknown error')}")

            return result
        except httpx.HTTPError as e:
            logger.error(f"HTTP error calling Moodle API: {e}")
            raise
        except Exception as e:
            logger.error(f"Error calling Moodle API: {e}")
            raise

    async def get_user_courses(self, userid: Optional[int] = None) -> List[Dict[str, Any]]:
        """
        Get courses for a user.

        Args:
            userid: User ID (if None, gets current user's courses)

        Returns:
            List of courses
        """
        params = {}
        if userid:
            params["userid"] = userid

        try:
            courses = await self._call_function("core_enrol_get_users_courses", params)
            return courses if isinstance(courses, list) else []
        except Exception as e:
            logger.error(f"Error fetching user courses: {e}")
            return []

    async def get_course_contents(self, courseid: int) -> List[Dict[str, Any]]:
        """
        Get course contents (sections, modules, activities).

        Args:
            courseid: Course ID

        Returns:
            List of course sections
        """
        params = {"courseid": courseid}

        try:
            contents = await self._call_function("core_course_get_contents", params)
            return contents if isinstance(contents, list) else []
        except Exception as e:
            logger.error(f"Error fetching course contents: {e}")
            return []

    async def get_assignments(self, courseids: List[int] = None) -> List[Dict[str, Any]]:
        """
        Get assignments for courses.

        Args:
            courseids: List of course IDs

        Returns:
            List of assignments
        """
        params = {}
        if courseids:
            params["courseids"] = courseids

        try:
            result = await self._call_function("mod_assign_get_assignments", params)

            # Extract assignments from courses
            assignments = []
            if isinstance(result, dict) and "courses" in result:
                for course in result["courses"]:
                    if "assignments" in course:
                        for assignment in course["assignments"]:
                            assignment["course_id"] = course.get("id")
                            assignments.append(assignment)

            return assignments
        except Exception as e:
            logger.error(f"Error fetching assignments: {e}")
            return []

    async def get_assignment_submissions(self, assignmentid: int) -> List[Dict[str, Any]]:
        """
        Get submissions for an assignment.

        Args:
            assignmentid: Assignment ID

        Returns:
            List of submissions
        """
        params = {"assignmentid": assignmentid}

        try:
            result = await self._call_function("mod_assign_get_submissions", params)

            submissions = []
            if isinstance(result, dict) and "assignments" in result:
                for assignment in result["assignments"]:
                    if "submissions" in assignment:
                        submissions.extend(assignment["submissions"])

            return submissions
        except Exception as e:
            logger.error(f"Error fetching assignment submissions: {e}")
            return []

    async def get_grades(self, courseid: int, userid: Optional[int] = None) -> List[Dict[str, Any]]:
        """
        Get grades for a course.

        Args:
            courseid: Course ID
            userid: User ID (if None, gets all grades)

        Returns:
            List of grades
        """
        params = {"courseid": courseid}
        if userid:
            params["userid"] = userid

        try:
            result = await self._call_function("gradereport_user_get_grade_items", params)

            grades = []
            if isinstance(result, dict) and "usergrades" in result:
                for usergrade in result["usergrades"]:
                    if "gradeitems" in usergrade:
                        grades.extend(usergrade["gradeitems"])

            return grades
        except Exception as e:
            logger.error(f"Error fetching grades: {e}")
            return []

    async def get_calendar_events(self,
                                   courseids: List[int] = None,
                                   groupids: List[int] = None) -> List[Dict[str, Any]]:
        """
        Get calendar events.

        Args:
            courseids: List of course IDs
            groupids: List of group IDs

        Returns:
            List of calendar events
        """
        params = {
            "events": {
                "courseids": courseids or [],
                "groupids": groupids or []
            }
        }

        try:
            result = await self._call_function("core_calendar_get_calendar_events", params)

            if isinstance(result, dict) and "events" in result:
                return result["events"]

            return []
        except Exception as e:
            logger.error(f"Error fetching calendar events: {e}")
            return []

    async def close(self):
        """Close the HTTP client."""
        await self.client.aclose()
