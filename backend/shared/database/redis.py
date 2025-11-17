"""
Redis connection and utilities
"""
import json
from typing import Any, Optional
import redis.asyncio as aioredis
from redis.asyncio import Redis

from shared.config import settings


class RedisClient:
    """Redis client wrapper"""

    def __init__(self):
        self.client: Optional[Redis] = None

    async def connect(self):
        """Connect to Redis"""
        self.client = await aioredis.from_url(
            settings.redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=50,
        )

    async def disconnect(self):
        """Disconnect from Redis"""
        if self.client:
            await self.client.close()

    async def get(self, key: str) -> Optional[str]:
        """Get value by key"""
        if not self.client:
            await self.connect()
        return await self.client.get(key)

    async def set(
        self,
        key: str,
        value: Any,
        expire: Optional[int] = None
    ) -> bool:
        """Set key-value pair with optional expiration (seconds)"""
        if not self.client:
            await self.connect()

        if isinstance(value, (dict, list)):
            value = json.dumps(value)

        await self.client.set(key, value)
        if expire:
            await self.client.expire(key, expire)
        return True

    async def delete(self, *keys: str) -> int:
        """Delete one or more keys"""
        if not self.client:
            await self.connect()
        return await self.client.delete(*keys)

    async def exists(self, key: str) -> bool:
        """Check if key exists"""
        if not self.client:
            await self.connect()
        return await self.client.exists(key) > 0

    async def incr(self, key: str) -> int:
        """Increment value"""
        if not self.client:
            await self.connect()
        return await self.client.incr(key)

    async def expire(self, key: str, seconds: int) -> bool:
        """Set expiration on key"""
        if not self.client:
            await self.connect()
        return await self.client.expire(key, seconds)

    async def ttl(self, key: str) -> int:
        """Get time to live for key"""
        if not self.client:
            await self.connect()
        return await self.client.ttl(key)

    async def hset(self, name: str, key: str, value: Any) -> int:
        """Set hash field"""
        if not self.client:
            await self.connect()
        if isinstance(value, (dict, list)):
            value = json.dumps(value)
        return await self.client.hset(name, key, value)

    async def hget(self, name: str, key: str) -> Optional[str]:
        """Get hash field"""
        if not self.client:
            await self.connect()
        return await self.client.hget(name, key)

    async def hgetall(self, name: str) -> dict:
        """Get all hash fields"""
        if not self.client:
            await self.connect()
        return await self.client.hgetall(name)

    async def lpush(self, key: str, *values: Any) -> int:
        """Push to list (left)"""
        if not self.client:
            await self.connect()
        serialized = [json.dumps(v) if isinstance(v, (dict, list)) else v for v in values]
        return await self.client.lpush(key, *serialized)

    async def rpush(self, key: str, *values: Any) -> int:
        """Push to list (right)"""
        if not self.client:
            await self.connect()
        serialized = [json.dumps(v) if isinstance(v, (dict, list)) else v for v in values]
        return await self.client.rpush(key, *serialized)

    async def lrange(self, key: str, start: int, end: int) -> list:
        """Get list range"""
        if not self.client:
            await self.connect()
        return await self.client.lrange(key, start, end)

    async def zadd(self, key: str, mapping: dict) -> int:
        """Add to sorted set"""
        if not self.client:
            await self.connect()
        return await self.client.zadd(key, mapping)

    async def zrange(
        self,
        key: str,
        start: int,
        end: int,
        withscores: bool = False
    ) -> list:
        """Get sorted set range"""
        if not self.client:
            await self.connect()
        return await self.client.zrange(key, start, end, withscores=withscores)


# Global Redis client instance
redis_client = RedisClient()


async def get_redis() -> Redis:
    """Get Redis client dependency"""
    if not redis_client.client:
        await redis_client.connect()
    return redis_client.client
