"""
UCL API Proxy Service Main Application
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from shared.config import settings
from shared.database import redis_client
from .router import router

app = FastAPI(
    title="UniApp UCL API Proxy",
    version="1.0.0",
    description="Proxy service for UCL API with caching"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include router
app.include_router(router)


@app.on_event("startup")
async def startup():
    """Connect to Redis"""
    await redis_client.connect()


@app.on_event("shutdown")
async def shutdown():
    """Disconnect from Redis"""
    await redis_client.disconnect()


@app.get("/health")
async def health_check():
    """Health check"""
    return {"status": "healthy", "service": "ucl_proxy"}
