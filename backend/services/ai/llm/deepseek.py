"""
DeepSeek LLM Client
"""
from typing import List, Dict, Any, Optional, AsyncGenerator
import httpx
import json

from shared.config import settings


class DeepSeekClient:
    """DeepSeek API client"""

    def __init__(self):
        self.api_key = settings.deepseek_api_key
        self.base_url = settings.deepseek_base_url
        self.model = "deepseek-chat"

    async def chat_completion(
        self,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 800,
        stream: bool = False
    ) -> Union[str, AsyncGenerator[str, None]]:
        """
        Chat completion

        Args:
            messages: List of messages [{"role": "user", "content": "..."}]
            temperature: Sampling temperature
            max_tokens: Maximum tokens to generate
            stream: Whether to stream responses

        Returns:
            Generated text or async generator for streaming
        """
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "stream": stream
        }

        async with httpx.AsyncClient() as client:
            if stream:
                return self._stream_response(client, headers, payload)
            else:
                response = await client.post(
                    f"{self.base_url}/chat/completions",
                    headers=headers,
                    json=payload,
                    timeout=60.0
                )
                response.raise_for_status()
                data = response.json()
                return data["choices"][0]["message"]["content"]

    async def _stream_response(
        self,
        client: httpx.AsyncClient,
        headers: Dict[str, str],
        payload: Dict[str, Any]
    ) -> AsyncGenerator[str, None]:
        """Stream response chunks"""
        async with client.stream(
            "POST",
            f"{self.base_url}/chat/completions",
            headers=headers,
            json=payload,
            timeout=60.0
        ) as response:
            response.raise_for_status()
            async for line in response.aiter_lines():
                if line.startswith("data: "):
                    data_str = line[6:]
                    if data_str == "[DONE]":
                        break
                    try:
                        data = json.loads(data_str)
                        delta = data["choices"][0]["delta"]
                        if "content" in delta:
                            yield delta["content"]
                    except json.JSONDecodeError:
                        continue


# Global instance
deepseek_client = DeepSeekClient()


from typing import Union  # Add this import at the top
