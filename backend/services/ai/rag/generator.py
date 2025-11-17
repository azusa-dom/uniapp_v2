"""
RAG Generator
Combines retrieval results with LLM to generate final answer
"""
from typing import List, Dict, Any, Optional
from dataclasses import dataclass

from ..llm.deepseek import deepseek_client
from .retriever import RetrievedDocument


@dataclass
class GeneratedAnswer:
    """Generated answer with metadata"""
    answer: str
    sources: List[Dict[str, Any]]
    confidence: float
    context_used: List[str]
    tokens_used: int


class RAGGenerator:
    """
    Generator for RAG system
    """

    def __init__(self):
        self.system_prompt = """You are UniApp's intelligent assistant for UCL students.

Your task is to answer questions based ONLY on the provided context documents.

Guidelines:
1. Answer in Simplified Chinese unless the user asks in English
2. Be concise and accurate
3. If the context doesn't contain the answer, say "根据现有信息，我无法回答这个问题。"
4. Always cite sources using [Source 1], [Source 2], etc.
5. Focus on actionable information
6. If multiple sources contradict, mention both perspectives

Context documents will be provided in the format:
[Source 1]: <document text>
[Source 2]: <document text>
"""

    async def generate(
        self,
        query: str,
        retrieved_docs: List[RetrievedDocument],
        max_context_length: int = 3000,
        temperature: float = 0.3,
    ) -> GeneratedAnswer:
        """
        Generate answer using retrieved documents

        Args:
            query: User query
            retrieved_docs: Retrieved documents
            max_context_length: Maximum context length
            temperature: LLM temperature

        Returns:
            GeneratedAnswer object
        """
        if not retrieved_docs:
            return GeneratedAnswer(
                answer="抱歉，我找不到相关信息来回答这个问题。",
                sources=[],
                confidence=0.0,
                context_used=[],
                tokens_used=0,
            )

        # Build context from retrieved documents
        context, sources = self._build_context(retrieved_docs, max_context_length)

        # Build prompt
        prompt = self._build_prompt(query, context)

        # Generate answer
        messages = [
            {"role": "system", "content": self.system_prompt},
            {"role": "user", "content": prompt},
        ]

        answer = await deepseek_client.chat_completion(
            messages=messages,
            temperature=temperature,
            max_tokens=800,
        )

        # Calculate confidence based on source scores
        confidence = self._calculate_confidence(retrieved_docs)

        return GeneratedAnswer(
            answer=answer,
            sources=sources,
            confidence=confidence,
            context_used=[doc.text for doc in retrieved_docs],
            tokens_used=len(answer.split()) * 2,  # Rough estimate
        )

    def _build_context(
        self,
        documents: List[RetrievedDocument],
        max_length: int,
    ) -> tuple[str, List[Dict[str, Any]]]:
        """
        Build context from documents

        Args:
            documents: Retrieved documents
            max_length: Maximum context length

        Returns:
            (context_string, sources_metadata)
        """
        context_parts = []
        sources = []
        current_length = 0

        for i, doc in enumerate(documents, start=1):
            # Format source
            source_text = f"[Source {i}]: {doc.text}\n\n"
            source_length = len(source_text)

            # Check if we can add this source
            if current_length + source_length > max_length:
                break

            context_parts.append(source_text)
            current_length += source_length

            # Add source metadata
            sources.append({
                "id": doc.id,
                "text": doc.text,
                "score": doc.score,
                "metadata": doc.metadata,
            })

        context = "".join(context_parts)
        return context, sources

    def _build_prompt(self, query: str, context: str) -> str:
        """Build prompt for LLM"""
        prompt = f"""Context Documents:
{context}

User Question: {query}

Instructions:
- Answer the question based ONLY on the context above
- Cite sources using [Source X] format
- If the answer is not in the context, say so clearly
- Keep your answer concise and actionable

Answer:"""
        return prompt

    def _calculate_confidence(self, documents: List[RetrievedDocument]) -> float:
        """
        Calculate confidence score based on retrieval scores

        Args:
            documents: Retrieved documents

        Returns:
            Confidence score (0-1)
        """
        if not documents:
            return 0.0

        # Use top document score as confidence
        top_score = documents[0].score

        # Normalize to 0-1 range (assuming scores are 0-1 from Qdrant)
        confidence = min(max(top_score, 0.0), 1.0)

        # Apply threshold
        if confidence < 0.5:
            confidence *= 0.8  # Reduce confidence for low scores

        return confidence


class CitationExtractor:
    """
    Extract and validate citations from generated answers
    """

    def extract_citations(self, answer: str) -> List[int]:
        """
        Extract citation numbers from answer

        Args:
            answer: Generated answer text

        Returns:
            List of citation numbers
        """
        import re
        pattern = r'\[Source (\d+)\]'
        matches = re.findall(pattern, answer)
        return [int(m) for m in matches]

    def validate_citations(
        self,
        answer: str,
        num_sources: int,
    ) -> bool:
        """
        Validate that all citations are valid

        Args:
            answer: Generated answer
            num_sources: Number of available sources

        Returns:
            True if all citations are valid
        """
        citations = self.extract_citations(answer)
        return all(1 <= c <= num_sources for c in citations)


# Global instances
rag_generator = RAGGenerator()
citation_extractor = CitationExtractor()
