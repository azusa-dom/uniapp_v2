"""
Query Understanding and Processing
Intent detection, entity extraction, query expansion
"""
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import re
from datetime import datetime, timedelta


class QueryIntent(str, Enum):
    """Query intent types"""
    FACTUAL = "factual"  # "What is..."
    PROCEDURAL = "procedural"  # "How to..."
    NAVIGATIONAL = "navigational"  # "Where is..."
    TEMPORAL = "temporal"  # "When is..."
    COMPARISON = "comparison"  # "Compare X and Y"
    RECOMMENDATION = "recommendation"  # "Recommend..."
    GENERAL = "general"


@dataclass
class ProcessedQuery:
    """Processed query with metadata"""
    original_query: str
    cleaned_query: str
    intent: QueryIntent
    entities: Dict[str, List[str]]
    temporal_context: Optional[Dict[str, Any]]
    expanded_queries: List[str]
    keywords: List[str]
    filters: Dict[str, Any]


class QueryProcessor:
    """
    Query understanding and processing
    """

    def __init__(self):
        self.intent_patterns = {
            QueryIntent.FACTUAL: [
                r'what is', r'what are', r'什么是', r'define', r'explain', r'介绍'
            ],
            QueryIntent.PROCEDURAL: [
                r'how to', r'how do', r'怎么', r'如何', r'步骤', r'方法'
            ],
            QueryIntent.NAVIGATIONAL: [
                r'where is', r'where are', r'哪里', r'在哪', r'地点', r'位置'
            ],
            QueryIntent.TEMPORAL: [
                r'when is', r'when are', r'什么时候', r'何时', r'时间'
            ],
            QueryIntent.COMPARISON: [
                r'compare', r'difference between', r'比较', r'区别', r'vs'
            ],
            QueryIntent.RECOMMENDATION: [
                r'recommend', r'suggest', r'推荐', r'建议', r'应该'
            ],
        }

        self.stop_words_en = set(['the', 'is', 'at', 'which', 'on', 'a', 'an'])
        self.stop_words_zh = set(['的', '了', '在', '是', '和', '与', '或'])

    async def process(self, query: str) -> ProcessedQuery:
        """
        Process and analyze query

        Args:
            query: Raw query text

        Returns:
            ProcessedQuery object
        """
        # Clean query
        cleaned_query = self._clean_query(query)

        # Detect intent
        intent = self._detect_intent(cleaned_query)

        # Extract entities
        entities = self._extract_entities(cleaned_query)

        # Extract temporal context
        temporal_context = self._extract_temporal_context(cleaned_query)

        # Generate query expansions
        expanded_queries = await self._expand_query(cleaned_query, intent)

        # Extract keywords
        keywords = self._extract_keywords(cleaned_query)

        # Build filters
        filters = self._build_filters(entities, temporal_context)

        return ProcessedQuery(
            original_query=query,
            cleaned_query=cleaned_query,
            intent=intent,
            entities=entities,
            temporal_context=temporal_context,
            expanded_queries=expanded_queries,
            keywords=keywords,
            filters=filters,
        )

    def _clean_query(self, query: str) -> str:
        """Clean and normalize query"""
        # Convert to lowercase
        query = query.lower()

        # Remove extra whitespace
        query = re.sub(r'\s+', ' ', query)

        # Remove special characters (keep alphanumeric, spaces, and Chinese)
        query = re.sub(r'[^\w\s\u4e00-\u9fff]', ' ', query)

        return query.strip()

    def _detect_intent(self, query: str) -> QueryIntent:
        """Detect query intent"""
        query_lower = query.lower()

        for intent, patterns in self.intent_patterns.items():
            for pattern in patterns:
                if re.search(pattern, query_lower):
                    return intent

        return QueryIntent.GENERAL

    def _extract_entities(self, query: str) -> Dict[str, List[str]]:
        """Extract named entities"""
        entities = {
            "courses": [],
            "locations": [],
            "people": [],
            "dates": [],
            "activities": [],
        }

        # Course codes (e.g., "COMP0066", "STAT0002")
        course_pattern = r'\b[A-Z]{4}\d{4}\b'
        entities["courses"] = re.findall(course_pattern, query.upper())

        # Locations (UCL buildings)
        ucl_buildings = [
            "UCL", "Roberts Building", "Cruciform", "IOE", "SSEES",
            "Archaeology", "Bloomsbury", "Main Library", "Science Library"
        ]
        for building in ucl_buildings:
            if building.lower() in query:
                entities["locations"].append(building)

        # Dates
        date_patterns = [
            r'\d{4}-\d{2}-\d{2}',  # 2025-01-17
            r'\d{1,2}/\d{1,2}/\d{4}',  # 17/01/2025
            r'\d{1,2}-\d{1,2}-\d{4}',  # 17-01-2025
        ]
        for pattern in date_patterns:
            entities["dates"].extend(re.findall(pattern, query))

        # Activity types
        activity_types = ["lecture", "讲座", "workshop", "研讨会", "seminar", "活动", "event"]
        for activity_type in activity_types:
            if activity_type in query:
                entities["activities"].append(activity_type)

        return entities

    def _extract_temporal_context(self, query: str) -> Optional[Dict[str, Any]]:
        """Extract temporal context from query"""
        temporal_keywords = {
            "today": timedelta(days=0),
            "今天": timedelta(days=0),
            "tomorrow": timedelta(days=1),
            "明天": timedelta(days=1),
            "yesterday": timedelta(days=-1),
            "昨天": timedelta(days=-1),
            "this week": {"weeks": 0},
            "本周": {"weeks": 0},
            "next week": {"weeks": 1},
            "下周": {"weeks": 1},
            "last week": {"weeks": -1},
            "上周": {"weeks": -1},
            "this month": {"months": 0},
            "本月": {"months": 0},
        }

        query_lower = query.lower()
        for keyword, delta in temporal_keywords.items():
            if keyword in query_lower:
                if isinstance(delta, timedelta):
                    target_date = datetime.now() + delta
                    return {
                        "type": "date",
                        "date": target_date.date().isoformat(),
                        "keyword": keyword,
                    }
                elif isinstance(delta, dict):
                    if "weeks" in delta:
                        return {
                            "type": "week",
                            "offset": delta["weeks"],
                            "keyword": keyword,
                        }
                    elif "months" in delta:
                        return {
                            "type": "month",
                            "offset": delta["months"],
                            "keyword": keyword,
                        }

        return None

    async def _expand_query(self, query: str, intent: QueryIntent) -> List[str]:
        """Generate query variations"""
        expansions = [query]

        # Add intent-specific variations
        if intent == QueryIntent.FACTUAL:
            expansions.append(f"definition of {query}")
            expansions.append(f"{query} meaning")

        elif intent == QueryIntent.PROCEDURAL:
            expansions.append(f"steps to {query}")
            expansions.append(f"guide to {query}")

        elif intent == QueryIntent.NAVIGATIONAL:
            expansions.append(f"location of {query}")
            expansions.append(f"where to find {query}")

        # Add synonyms (simple example)
        synonym_map = {
            "course": ["class", "module", "subject"],
            "lecture": ["class", "lesson", "session"],
            "assignment": ["homework", "coursework", "task"],
        }

        for word, synonyms in synonym_map.items():
            if word in query:
                for synonym in synonyms:
                    expansion = query.replace(word, synonym)
                    if expansion not in expansions:
                        expansions.append(expansion)

        return expansions[:5]  # Limit to 5 expansions

    def _extract_keywords(self, query: str) -> List[str]:
        """Extract important keywords"""
        words = query.split()

        # Remove stop words
        keywords = [
            word for word in words
            if word not in self.stop_words_en and word not in self.stop_words_zh
            and len(word) > 2
        ]

        return keywords

    def _build_filters(
        self,
        entities: Dict[str, List[str]],
        temporal_context: Optional[Dict[str, Any]],
    ) -> Dict[str, Any]:
        """Build metadata filters for retrieval"""
        filters = {}

        # Add entity filters
        if entities.get("courses"):
            filters["course_code"] = entities["courses"][0]

        if entities.get("locations"):
            filters["location"] = entities["locations"][0]

        # Add temporal filters
        if temporal_context:
            if temporal_context["type"] == "date":
                filters["date"] = temporal_context["date"]
            elif temporal_context["type"] == "week":
                # Calculate week range
                pass  # Implement as needed

        return filters


# Global instance
query_processor = QueryProcessor()
