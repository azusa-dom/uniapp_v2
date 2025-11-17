"""
AI Assistant service with RAG (Retrieval Augmented Generation) for accurate UCL-specific responses.
"""
import httpx
from typing import List, Dict, Any, Optional
import logging
from datetime import datetime
import json

from config import settings

logger = logging.getLogger(__name__)


class AIAssistantService:
    """AI Assistant service using DeepSeek/OpenAI with RAG for UCL-specific context."""

    def __init__(self):
        self.deepseek_api_key = settings.DEEPSEEK_API_KEY
        self.openai_api_key = settings.OPENAI_API_KEY
        self.client = httpx.AsyncClient(timeout=60.0)

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.client.aclose()

    def _build_system_prompt(self, user_context: Dict[str, Any]) -> str:
        """
        Build system prompt with user context.

        Args:
            user_context: Dictionary containing user information and UCL data

        Returns:
            System prompt string
        """
        user_name = user_context.get("full_name", "Student")
        program = user_context.get("program", "")
        department = user_context.get("department", "")

        system_prompt = f"""You are UniApp's intelligent bilingual study assistant for UCL students.

You are helping {user_name}, a student {f'in {program}' if program else ''} {f'at {department}' if department else ''}.

Your capabilities:
1. Answer questions about courses, assignments, and deadlines with REAL-TIME data
2. Provide guidance on UCL campus activities and events
3. Help with academic planning and time management
4. Offer information about UCL facilities, services, and resources
5. Respond in Simplified Chinese with professional, concise, and actionable advice

Guidelines:
- Always use real-time data provided in the context when available
- If you don't have specific information, acknowledge it and suggest where to find it
- Keep responses focused and practical
- Use emojis sparingly and appropriately
- Prioritize student wellbeing and academic success
"""

        return system_prompt

    def _prepare_context_data(self, ucl_data: Dict[str, Any]) -> str:
        """
        Prepare UCL data as context for the AI.

        Args:
            ucl_data: Dictionary containing UCL-specific data

        Returns:
            Formatted context string
        """
        context_parts = []

        # Courses and assignments
        if "courses" in ucl_data and ucl_data["courses"]:
            context_parts.append("## Current Courses:")
            for course in ucl_data["courses"]:
                context_parts.append(f"- {course.get('course_name')} ({course.get('course_code')})")
                if course.get('current_grade'):
                    context_parts.append(f"  Current Grade: {course.get('current_grade')}%")

        # Upcoming assignments
        if "assignments" in ucl_data and ucl_data["assignments"]:
            context_parts.append("\n## Upcoming Assignments:")
            for assignment in ucl_data["assignments"][:5]:  # Top 5
                due_date = assignment.get('due_date', 'TBD')
                context_parts.append(
                    f"- {assignment.get('name')} (Due: {due_date})"
                )

        # Timetable
        if "timetable" in ucl_data and ucl_data["timetable"]:
            context_parts.append("\n## This Week's Schedule:")
            for event in ucl_data["timetable"][:10]:  # Next 10 events
                context_parts.append(
                    f"- {event.get('module_name', event.get('title'))}: "
                    f"{event.get('start_time')} at {event.get('location', 'TBD')}"
                )

        # Activities
        if "activities" in ucl_data and ucl_data["activities"]:
            context_parts.append("\n## Upcoming UCL Activities:")
            for activity in ucl_data["activities"][:5]:
                context_parts.append(
                    f"- {activity.get('title')}: {activity.get('start_time')} "
                    f"at {activity.get('location', 'TBD')}"
                )

        # Recent emails (important ones)
        if "emails" in ucl_data and ucl_data["emails"]:
            context_parts.append("\n## Recent Important Emails:")
            urgent_emails = [e for e in ucl_data["emails"] if e.get('category') == 'urgent'][:3]
            for email in urgent_emails:
                context_parts.append(
                    f"- From {email.get('sender_name')}: {email.get('subject')}"
                )

        return "\n".join(context_parts)

    async def _call_deepseek(self,
                             messages: List[Dict[str, str]],
                             temperature: float = 0.7,
                             max_tokens: int = 800) -> Dict[str, Any]:
        """
        Call DeepSeek API.

        Args:
            messages: List of message dictionaries
            temperature: Sampling temperature
            max_tokens: Maximum tokens to generate

        Returns:
            API response
        """
        url = "https://api.deepseek.com/v1/chat/completions"

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.deepseek_api_key}"
        }

        payload = {
            "model": "deepseek-chat",
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": False
        }

        try:
            response = await self.client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Error calling DeepSeek API: {e}")
            raise

    async def _call_openai(self,
                           messages: List[Dict[str, str]],
                           temperature: float = 0.7,
                           max_tokens: int = 800) -> Dict[str, Any]:
        """
        Call OpenAI API as fallback.

        Args:
            messages: List of message dictionaries
            temperature: Sampling temperature
            max_tokens: Maximum tokens to generate

        Returns:
            API response
        """
        url = "https://api.openai.com/v1/chat/completions"

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.openai_api_key}"
        }

        payload = {
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens
        }

        try:
            response = await self.client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Error calling OpenAI API: {e}")
            raise

    async def generate_response(self,
                                user_message: str,
                                user_context: Dict[str, Any],
                                ucl_data: Dict[str, Any],
                                conversation_history: List[Dict[str, str]] = None,
                                use_openai: bool = False) -> Dict[str, Any]:
        """
        Generate AI response with UCL-specific context.

        Args:
            user_message: User's message
            user_context: User profile information
            ucl_data: Real-time UCL data (courses, assignments, timetable, etc.)
            conversation_history: Previous messages in conversation
            use_openai: Whether to use OpenAI instead of DeepSeek

        Returns:
            Dictionary with response and metadata
        """
        start_time = datetime.now()

        # Build system prompt
        system_prompt = self._build_system_prompt(user_context)

        # Prepare UCL data context
        ucl_context = self._prepare_context_data(ucl_data)

        # Build messages
        messages = [
            {"role": "system", "content": system_prompt}
        ]

        # Add UCL context as system message
        if ucl_context:
            messages.append({
                "role": "system",
                "content": f"Here is the real-time UCL data for this student:\n\n{ucl_context}"
            })

        # Add conversation history (limit to last 8 messages)
        if conversation_history:
            messages.extend(conversation_history[-8:])

        # Add current user message
        messages.append({"role": "user", "content": user_message})

        # Call AI API
        try:
            if use_openai and self.openai_api_key:
                response_data = await self._call_openai(messages)
            elif self.deepseek_api_key:
                response_data = await self._call_deepseek(messages)
            else:
                raise Exception("No AI API key configured")

            # Extract response
            ai_response = response_data["choices"][0]["message"]["content"]
            tokens_used = response_data["usage"]["total_tokens"]
            model = response_data.get("model", "deepseek-chat")

            processing_time = (datetime.now() - start_time).total_seconds()

            return {
                "response": ai_response,
                "model": model,
                "tokens_used": tokens_used,
                "processing_time": processing_time,
                "context_data": ucl_context,
                "sources": list(ucl_data.keys())
            }

        except Exception as e:
            logger.error(f"Error generating AI response: {e}")
            raise

    async def generate_email_summary(self, email_content: str) -> Dict[str, Any]:
        """
        Generate AI summary for email.

        Args:
            email_content: Email body text

        Returns:
            Dictionary with summary and translation
        """
        messages = [
            {
                "role": "system",
                "content": "You are a helpful assistant that summarizes emails for UCL students. "
                          "Provide a Chinese translation and extract key action items."
            },
            {
                "role": "user",
                "content": f"Please summarize this email and translate to Chinese:\n\n{email_content}"
            }
        ]

        try:
            if self.deepseek_api_key:
                response_data = await self._call_deepseek(messages, max_tokens=600)
            else:
                response_data = await self._call_openai(messages, max_tokens=600)

            summary = response_data["choices"][0]["message"]["content"]

            return {
                "summary": summary,
                "success": True
            }

        except Exception as e:
            logger.error(f"Error generating email summary: {e}")
            return {
                "summary": "Failed to generate summary",
                "success": False
            }

    async def close(self):
        """Close the HTTP client."""
        await self.client.aclose()
