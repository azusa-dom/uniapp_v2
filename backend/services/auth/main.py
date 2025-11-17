"""
Authentication Service Main Application
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from shared.config import settings
from shared.database import init_db, close_db
from .router import router

# Create FastAPI app
app = FastAPI(
    title="UniApp Authentication Service",
    version="1.0.0",
    description="Authentication and user management service"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(router)


@app.on_event("startup")
async def startup():
    """Initialize database on startup"""
    await init_db()


@app.on_event("shutdown")
async def shutdown():
    """Close database connections on shutdown"""
    await close_db()


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "auth"}
