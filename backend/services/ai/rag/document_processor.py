"""
Document Processing and Chunking
Intelligent text splitting strategies for optimal RAG performance
"""
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
import re
from datetime import datetime


@dataclass
class DocumentChunk:
    """A chunk of a document"""
    text: str
    metadata: Dict[str, Any]
    chunk_index: int
    total_chunks: int
    char_start: int
    char_end: int


class TextChunker:
    """
    Intelligent text chunking with multiple strategies
    """

    def __init__(
        self,
        chunk_size: int = 512,
        chunk_overlap: int = 50,
        separators: Optional[List[str]] = None,
    ):
        """
        Args:
            chunk_size: Target size of each chunk (in tokens/characters)
            chunk_overlap: Number of overlapping tokens/characters
            separators: List of separators to split on (in priority order)
        """
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        self.separators = separators or [
            "\n\n\n",  # Multiple newlines
            "\n\n",    # Paragraph breaks
            "\n",      # Single newline
            ". ",      # Sentence end
            "。",      # Chinese sentence end
            "! ",      # Exclamation
            "！",      # Chinese exclamation
            "? ",      # Question
            "？",      # Chinese question
            "; ",      # Semicolon
            "；",      # Chinese semicolon
            ", ",      # Comma
            "，",      # Chinese comma
            " ",       # Space
            "",        # Character-level
        ]

    def chunk_text(
        self,
        text: str,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> List[DocumentChunk]:
        """
        Split text into chunks using recursive character splitting

        Args:
            text: Input text
            metadata: Additional metadata for chunks

        Returns:
            List of DocumentChunk objects
        """
        metadata = metadata or {}

        # Clean text
        text = self._clean_text(text)

        # Split into chunks
        chunks = self._recursive_split(text)

        # Create DocumentChunk objects
        result = []
        total_chunks = len(chunks)

        char_pos = 0
        for i, chunk_text in enumerate(chunks):
            chunk_start = text.find(chunk_text, char_pos)
            chunk_end = chunk_start + len(chunk_text)

            chunk = DocumentChunk(
                text=chunk_text,
                metadata=metadata.copy(),
                chunk_index=i,
                total_chunks=total_chunks,
                char_start=chunk_start,
                char_end=chunk_end,
            )
            result.append(chunk)

            char_pos = chunk_end

        return result

    def _clean_text(self, text: str) -> str:
        """Clean and normalize text"""
        # Remove excessive whitespace
        text = re.sub(r'\s+', ' ', text)
        # Remove leading/trailing whitespace
        text = text.strip()
        return text

    def _recursive_split(
        self,
        text: str,
        separators: Optional[List[str]] = None,
    ) -> List[str]:
        """
        Recursively split text on separators

        Args:
            text: Text to split
            separators: List of separators (uses self.separators if None)

        Returns:
            List of text chunks
        """
        separators = separators or self.separators

        # Base case: text is small enough
        if len(text) <= self.chunk_size:
            return [text] if text else []

        # Try each separator
        for separator in separators:
            if separator in text:
                splits = text.split(separator)

                # Reconstruct chunks with separators
                chunks = []
                current_chunk = ""

                for split in splits:
                    # Add separator back (except for empty string separator)
                    if separator:
                        split = split + separator

                    # Check if adding this split exceeds chunk size
                    if len(current_chunk) + len(split) <= self.chunk_size:
                        current_chunk += split
                    else:
                        # Current chunk is full
                        if current_chunk:
                            chunks.append(current_chunk)

                        # Start new chunk with overlap
                        if self.chunk_overlap > 0 and current_chunk:
                            overlap_text = current_chunk[-self.chunk_overlap:]
                            current_chunk = overlap_text + split
                        else:
                            current_chunk = split

                # Add final chunk
                if current_chunk:
                    chunks.append(current_chunk)

                return chunks

        # Fallback: character-level splitting
        return self._character_split(text)

    def _character_split(self, text: str) -> List[str]:
        """Split text by characters with overlap"""
        chunks = []
        start = 0

        while start < len(text):
            end = start + self.chunk_size
            chunk = text[start:end]
            chunks.append(chunk)

            # Move to next chunk with overlap
            start = end - self.chunk_overlap

        return chunks


class SemanticChunker:
    """
    Semantic chunking based on sentence embeddings
    Groups semantically similar sentences together
    """

    def __init__(
        self,
        max_chunk_size: int = 512,
        similarity_threshold: float = 0.75,
    ):
        """
        Args:
            max_chunk_size: Maximum chunk size
            similarity_threshold: Threshold for semantic similarity
        """
        self.max_chunk_size = max_chunk_size
        self.similarity_threshold = similarity_threshold

    def chunk_text(
        self,
        text: str,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> List[DocumentChunk]:
        """
        Chunk text based on semantic similarity

        Args:
            text: Input text
            metadata: Additional metadata

        Returns:
            List of DocumentChunk objects
        """
        metadata = metadata or {}

        # Split into sentences
        sentences = self._split_sentences(text)

        if not sentences:
            return []

        # For now, use simple length-based chunking
        # TODO: Implement embedding-based semantic chunking
        chunks = []
        current_chunk = []
        current_length = 0

        for sentence in sentences:
            sentence_length = len(sentence)

            if current_length + sentence_length <= self.max_chunk_size:
                current_chunk.append(sentence)
                current_length += sentence_length
            else:
                if current_chunk:
                    chunks.append(" ".join(current_chunk))
                current_chunk = [sentence]
                current_length = sentence_length

        # Add final chunk
        if current_chunk:
            chunks.append(" ".join(current_chunk))

        # Convert to DocumentChunk objects
        result = []
        total_chunks = len(chunks)
        char_pos = 0

        for i, chunk_text in enumerate(chunks):
            chunk_start = text.find(chunk_text, char_pos)
            chunk_end = chunk_start + len(chunk_text)

            chunk = DocumentChunk(
                text=chunk_text,
                metadata=metadata.copy(),
                chunk_index=i,
                total_chunks=total_chunks,
                char_start=chunk_start,
                char_end=chunk_end,
            )
            result.append(chunk)

            char_pos = chunk_end

        return result

    def _split_sentences(self, text: str) -> List[str]:
        """Split text into sentences"""
        # Simple sentence splitting for both English and Chinese
        sentence_endings = r'([.!?。！？]+[\s\n]*)'
        sentences = re.split(sentence_endings, text)

        # Recombine sentences with their endings
        result = []
        for i in range(0, len(sentences) - 1, 2):
            sentence = sentences[i] + (sentences[i + 1] if i + 1 < len(sentences) else "")
            sentence = sentence.strip()
            if sentence:
                result.append(sentence)

        return result


class DocumentProcessor:
    """
    Main document processor
    Handles different document types and chunking strategies
    """

    def __init__(self):
        self.text_chunker = TextChunker(chunk_size=512, chunk_overlap=50)
        self.semantic_chunker = SemanticChunker(max_chunk_size=512)

    def process_document(
        self,
        text: str,
        document_type: str = "text",
        metadata: Optional[Dict[str, Any]] = None,
        chunking_strategy: str = "recursive",
    ) -> List[Dict[str, Any]]:
        """
        Process document and create chunks

        Args:
            text: Document text
            document_type: Type of document
            metadata: Additional metadata
            chunking_strategy: 'recursive' or 'semantic'

        Returns:
            List of chunk dictionaries ready for embedding
        """
        metadata = metadata or {}
        metadata["document_type"] = document_type
        metadata["processed_at"] = datetime.utcnow().isoformat()

        # Choose chunking strategy
        if chunking_strategy == "semantic":
            chunks = self.semantic_chunker.chunk_text(text, metadata)
        else:
            chunks = self.text_chunker.chunk_text(text, metadata)

        # Convert to dictionaries
        result = []
        for chunk in chunks:
            chunk_dict = {
                "text": chunk.text,
                "metadata": chunk.metadata,
                "chunk_index": chunk.chunk_index,
                "total_chunks": chunk.total_chunks,
                "char_start": chunk.char_start,
                "char_end": chunk.char_end,
            }
            result.append(chunk_dict)

        return result

    def process_markdown(self, text: str, metadata: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """Process Markdown document"""
        # Extract headings and structure
        sections = self._extract_markdown_sections(text)

        all_chunks = []
        for section in sections:
            section_meta = metadata.copy() if metadata else {}
            section_meta.update(section["metadata"])

            chunks = self.process_document(
                text=section["text"],
                metadata=section_meta,
                chunking_strategy="recursive",
            )
            all_chunks.extend(chunks)

        return all_chunks

    def _extract_markdown_sections(self, text: str) -> List[Dict[str, Any]]:
        """Extract sections from Markdown text"""
        # Simple markdown section extraction
        lines = text.split('\n')
        sections = []
        current_section = {"heading": "", "level": 0, "text": "", "metadata": {}}

        for line in lines:
            # Check for heading
            heading_match = re.match(r'^(#{1,6})\s+(.+)$', line)
            if heading_match:
                # Save previous section
                if current_section["text"]:
                    sections.append({
                        "text": current_section["text"].strip(),
                        "metadata": current_section["metadata"].copy(),
                    })

                # Start new section
                level = len(heading_match.group(1))
                heading = heading_match.group(2)
                current_section = {
                    "heading": heading,
                    "level": level,
                    "text": f"{'#' * level} {heading}\n",
                    "metadata": {"heading": heading, "level": level},
                }
            else:
                current_section["text"] += line + "\n"

        # Add final section
        if current_section["text"]:
            sections.append({
                "text": current_section["text"].strip(),
                "metadata": current_section["metadata"].copy(),
            })

        return sections

    def process_html(self, html: str, metadata: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """Process HTML document"""
        # Remove HTML tags and extract text
        from html.parser import HTMLParser

        class TextExtractor(HTMLParser):
            def __init__(self):
                super().__init__()
                self.text = []

            def handle_data(self, data):
                self.text.append(data)

        extractor = TextExtractor()
        extractor.feed(html)
        text = ' '.join(extractor.text)

        return self.process_document(text, metadata=metadata)


# Global instance
document_processor = DocumentProcessor()
