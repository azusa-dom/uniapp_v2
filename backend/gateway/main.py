"""
API Gateway - Main Entry Point
Aggregates all microservices
"""
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import time

from shared.config import settings
from shared.database import init_db, close_db, redis_client

# Import service routers
import sys
sys.path.append("/app")

from services.auth.router import router as auth_router
from services.ucl_proxy.router import router as ucl_router
from services.ai.router import router as ai_router

# Create FastAPI app
app = FastAPI(
    title="UniApp API Gateway",
    version="1.0.0",
    description="Unified API Gateway for UniApp Backend Services",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


# Request timing middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """Add X-Process-Time header to responses"""
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = f"{process_time:.4f}"
    return response


# Exception handlers
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle validation errors"""
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Invalid request data",
                "details": exc.errors()
            }
        }
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle all uncaught exceptions"""
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred",
                "details": str(exc) if settings.app_debug else None
            }
        }
    )


# Include routers from microservices
app.include_router(auth_router, prefix="/api/v1")
app.include_router(ucl_router, prefix="/api/v1")
app.include_router(ai_router, prefix="/api/v1")


@app.on_event("startup")
async def startup():
    """Startup tasks"""
    print("🚀 Starting UniApp API Gateway...")
    await init_db()
    await redis_client.connect()
    print("✅ Database and Redis connected")
    print(f"📖 API Documentation: http://{settings.app_host}:{settings.app_port}/docs")


@app.on_event("shutdown")
async def shutdown():
    """Shutdown tasks"""
    print("👋 Shutting down UniApp API Gateway...")
    await close_db()
    await redis_client.disconnect()


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "UniApp API Gateway",
        "version": "1.0.0",
        "status": "running",
        "documentation": "/docs",
        "health": "/health"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "gateway",
        "environment": settings.app_env,
        "version": "1.0.0"
    }


@app.get("/api/v1")
async def api_info():
    """API version info"""
    return {
        "version": "v1",
        "services": {
            "auth": "/api/v1/auth",
            "ucl": "/api/v1/ucl",
            "ai": "/api/v1/ai",
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.app_host,
        port=settings.app_port,
        reload=settings.app_debug,
        log_level=settings.log_level.lower()
    )
