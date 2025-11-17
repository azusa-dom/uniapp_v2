"""
Base Agent and Multi-Agent System
"""
from typing import List, Dict, Any, Optional, Callable
from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum

from ..llm.deepseek import deepseek_client


class AgentType(str, Enum):
    """Agent types"""
    ACADEMIC = "academic"  # Academic queries
    SCHEDULE = "schedule"  # Schedule and timetable
    EMAIL = "email"  # Email management
    ACTIVITY = "activity"  # Campus activities
    HEALTH = "health"  # Health and wellness
    GENERAL = "general"  # General queries


@dataclass
class AgentContext:
    """Context for agent execution"""
    query: str
    user_id: str
    conversation_history: List[Dict[str, str]]
    user_profile: Dict[str, Any]
    retrieved_documents: List[Dict[str, Any]]


@dataclass
class AgentResponse:
    """Agent response"""
    answer: str
    confidence: float
    agent_type: AgentType
    sources: List[Dict[str, Any]]
    next_actions: List[str]
    metadata: Dict[str, Any]


class BaseAgent(ABC):
    """Base class for all agents"""

    def __init__(self, agent_type: AgentType):
        self.agent_type = agent_type
        self.tools = []

    @abstractmethod
    async def can_handle(self, context: AgentContext) -> float:
        """
        Determine if this agent can handle the query

        Args:
            context: Agent context

        Returns:
            Confidence score (0-1)
        """
        pass

    @abstractmethod
    async def process(self, context: AgentContext) -> AgentResponse:
        """
        Process the query

        Args:
            context: Agent context

        Returns:
            AgentResponse
        """
        pass

    def register_tool(self, tool: Callable):
        """Register a tool for this agent"""
        self.tools.append(tool)


class AcademicAgent(BaseAgent):
    """
    Agent for academic queries
    Handles: courses, assignments, grades, study resources
    """

    def __init__(self):
        super().__init__(AgentType.ACADEMIC)
        self.keywords = [
            "course", "class", "module", "课程",
            "assignment", "homework", "作业",
            "grade", "成绩", "score",
            "exam", "考试", "test",
            "study", "学习", "复习",
        ]

    async def can_handle(self, context: AgentContext) -> float:
        """Check if query is academic-related"""
        query_lower = context.query.lower()

        # Check for keywords
        keyword_matches = sum(1 for kw in self.keywords if kw in query_lower)
        confidence = min(keyword_matches / 3, 1.0)  # Up to 3 keywords = 100% confidence

        return confidence

    async def process(self, context: AgentContext) -> AgentResponse:
        """Process academic query"""
        # Build specialized prompt for academic queries
        system_prompt = """You are an academic advisor assistant for UCL students.

Your expertise includes:
- Course information and requirements
- Assignment guidelines and deadlines
- Study strategies and resources
- Academic performance analysis

Provide clear, actionable academic advice based on the context provided."""

        # Use retrieved documents
        context_text = "\n\n".join([
            f"[{i+1}] {doc.get('text', '')}"
            for i, doc in enumerate(context.retrieved_documents[:5])
        ])

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Context:\n{context_text}\n\nQuestion: {context.query}"}
        ]

        answer = await deepseek_client.chat_completion(messages, temperature=0.3)

        return AgentResponse(
            answer=answer,
            confidence=0.9,
            agent_type=self.agent_type,
            sources=context.retrieved_documents[:5],
            next_actions=["view_assignments", "check_grades"],
            metadata={"agent": "academic"},
        )


class ScheduleAgent(BaseAgent):
    """
    Agent for schedule and timetable queries
    Handles: classes, events, bookings, availability
    """

    def __init__(self):
        super().__init__(AgentType.SCHEDULE)
        self.keywords = [
            "schedule", "timetable", "日程", "时间表",
            "class time", "上课时间",
            "when", "什么时候",
            "free time", "空闲",
            "booking", "预定", "预约",
            "today", "tomorrow", "今天", "明天",
        ]

    async def can_handle(self, context: AgentContext) -> float:
        """Check if query is schedule-related"""
        query_lower = context.query.lower()

        keyword_matches = sum(1 for kw in self.keywords if kw in query_lower)
        confidence = min(keyword_matches / 2, 1.0)

        return confidence

    async def process(self, context: AgentContext) -> AgentResponse:
        """Process schedule query"""
        system_prompt = """You are a scheduling assistant for UCL students.

Your expertise includes:
- Class timetables and schedules
- Room bookings and availability
- Event scheduling
- Time management advice

Provide specific time-related information based on the context."""

        context_text = "\n\n".join([
            f"[{i+1}] {doc.get('text', '')}"
            for i, doc in enumerate(context.retrieved_documents[:5])
        ])

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Context:\n{context_text}\n\nQuestion: {context.query}"}
        ]

        answer = await deepseek_client.chat_completion(messages, temperature=0.2)

        return AgentResponse(
            answer=answer,
            confidence=0.85,
            agent_type=self.agent_type,
            sources=context.retrieved_documents[:5],
            next_actions=["view_calendar", "book_room"],
            metadata={"agent": "schedule"},
        )


class EmailAgent(BaseAgent):
    """
    Agent for email-related queries
    Handles: email summaries, drafts, organization
    """

    def __init__(self):
        super().__init__(AgentType.EMAIL)
        self.keywords = [
            "email", "邮件",
            "message", "消息",
            "inbox", "收件箱",
            "draft", "草稿",
            "send", "发送",
        ]

    async def can_handle(self, context: AgentContext) -> float:
        """Check if query is email-related"""
        query_lower = context.query.lower()

        keyword_matches = sum(1 for kw in self.keywords if kw in query_lower)
        confidence = min(keyword_matches / 2, 1.0)

        return confidence

    async def process(self, context: AgentContext) -> AgentResponse:
        """Process email query"""
        system_prompt = """You are an email management assistant for UCL students.

Your expertise includes:
- Email summarization
- Draft composition
- Email organization and prioritization

Help users manage their email effectively."""

        context_text = "\n\n".join([
            f"[{i+1}] {doc.get('text', '')}"
            for i, doc in enumerate(context.retrieved_documents[:5])
        ])

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Context:\n{context_text}\n\nQuestion: {context.query}"}
        ]

        answer = await deepseek_client.chat_completion(messages, temperature=0.3)

        return AgentResponse(
            answer=answer,
            confidence=0.8,
            agent_type=self.agent_type,
            sources=context.retrieved_documents[:5],
            next_actions=["view_emails", "compose_email"],
            metadata={"agent": "email"},
        )


class ActivityAgent(BaseAgent):
    """
    Agent for campus activities and events
    Handles: events, clubs, social activities
    """

    def __init__(self):
        super().__init__(AgentType.ACTIVITY)
        self.keywords = [
            "activity", "活动", "event",
            "club", "社团",
            "workshop", "研讨会",
            "lecture", "讲座",
            "sports", "运动",
        ]

    async def can_handle(self, context: AgentContext) -> float:
        """Check if query is activity-related"""
        query_lower = context.query.lower()

        keyword_matches = sum(1 for kw in self.keywords if kw in query_lower)
        confidence = min(keyword_matches / 2, 1.0)

        return confidence

    async def process(self, context: AgentContext) -> AgentResponse:
        """Process activity query"""
        system_prompt = """You are a campus activities coordinator for UCL students.

Your expertise includes:
- Campus events and activities
- Club and society information
- Workshop and seminar schedules
- Social and networking opportunities

Help students discover and participate in campus activities."""

        context_text = "\n\n".join([
            f"[{i+1}] {doc.get('text', '')}"
            for i, doc in enumerate(context.retrieved_documents[:5])
        ])

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Context:\n{context_text}\n\nQuestion: {context.query}"}
        ]

        answer = await deepseek_client.chat_completion(messages, temperature=0.4)

        return AgentResponse(
            answer=answer,
            confidence=0.85,
            agent_type=self.agent_type,
            sources=context.retrieved_documents[:5],
            next_actions=["browse_activities", "register_event"],
            metadata={"agent": "activity"},
        )


class GeneralAgent(BaseAgent):
    """
    Fallback agent for general queries
    """

    def __init__(self):
        super().__init__(AgentType.GENERAL)

    async def can_handle(self, context: AgentContext) -> float:
        """Always can handle as fallback"""
        return 0.5  # Medium confidence

    async def process(self, context: AgentContext) -> AgentResponse:
        """Process general query"""
        system_prompt = """You are UniApp's helpful assistant for UCL students.

Provide general assistance on any topic related to student life at UCL."""

        context_text = "\n\n".join([
            f"[{i+1}] {doc.get('text', '')}"
            for i, doc in enumerate(context.retrieved_documents[:5])
        ])

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": f"Context:\n{context_text}\n\nQuestion: {context.query}"}
        ]

        answer = await deepseek_client.chat_completion(messages, temperature=0.5)

        return AgentResponse(
            answer=answer,
            confidence=0.7,
            agent_type=self.agent_type,
            sources=context.retrieved_documents[:5],
            next_actions=[],
            metadata={"agent": "general"},
        )


class AgentOrchestrator:
    """
    Orchestrates multiple agents
    Routes queries to the best agent
    """

    def __init__(self):
        self.agents: List[BaseAgent] = [
            AcademicAgent(),
            ScheduleAgent(),
            EmailAgent(),
            ActivityAgent(),
            GeneralAgent(),  # Always last (fallback)
        ]

    async def route(self, context: AgentContext) -> AgentResponse:
        """
        Route query to best agent

        Args:
            context: Agent context

        Returns:
            AgentResponse from selected agent
        """
        # Ask each agent if it can handle the query
        agent_scores = []
        for agent in self.agents:
            score = await agent.can_handle(context)
            agent_scores.append((agent, score))

        # Sort by confidence
        agent_scores.sort(key=lambda x: x[1], reverse=True)

        # Use best agent
        best_agent, best_score = agent_scores[0]

        print(f"Selected agent: {best_agent.agent_type.value} (confidence: {best_score:.2f})")

        # Process with selected agent
        response = await best_agent.process(context)

        return response


# Global instance
agent_orchestrator = AgentOrchestrator()
