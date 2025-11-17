"""
AI Service Main Application
Enhanced with comprehensive RAG capabilities
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from shared.config import settings
from shared.database import init_db, close_db
from .router import router
from .rag_endpoints import router as rag_router

app = FastAPI(
    title="UniApp AI Service with RAG",
    version="2.0.0",
    description="""
    Advanced AI assistant service with comprehensive RAG capabilities:

    - **Chat**: Conversational AI with context-aware responses
    - **RAG**: Retrieval-Augmented Generation for accurate, sourced answers
    - **Multi-Agent**: Specialized agents for different domains
    - **Knowledge Base**: Document indexing and semantic search
    - **Hybrid Retrieval**: Vector + keyword search with re-ranking
    """,
    openapi_tags=[
        {
            "name": "AI",
            "description": "Chat and AI assistant endpoints"
        },
        {
            "name": "RAG",
            "description": "RAG-specific endpoints (queries, indexing, search)"
        }
    ]
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=settings.cors_allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(router)
app.include_router(rag_router)


@app.on_event("startup")
async def startup():
    """Initialize services"""
    print("🚀 Starting AI Service with RAG...")

    # Initialize database
    await init_db()

    # Initialize vector database collection
    try:
        from .rag.vector_store import qdrant_store
        await qdrant_store.create_collection()
        print("✅ Vector database collection ready")
    except Exception as e:
        print(f"⚠️  Vector database initialization: {e}")

    print("✅ AI Service ready")


@app.on_event("shutdown")
async def shutdown():
    """Cleanup"""
    print("👋 Shutting down AI Service...")
    await close_db()


@app.get("/")
async def root():
    """Service information"""
    return {
        "service": "UniApp AI Service",
        "version": "2.0.0",
        "features": [
            "Chat with conversation history",
            "RAG-enhanced answers",
            "Multi-agent routing",
            "Knowledge base management",
            "Semantic search",
            "Hybrid retrieval",
            "Re-ranking",
            "Query understanding"
        ],
        "documentation": "/docs"
    }


@app.get("/health")
async def health_check():
    """Health check with component status"""
    status = {
        "status": "healthy",
        "service": "ai",
        "version": "2.0.0",
        "components": {}
    }

    # Check vector database
    try:
        from .rag.vector_store import qdrant_store
        info = await qdrant_store.get_collection_info()
        status["components"]["vector_db"] = {
            "status": "healthy",
            "documents": info["points_count"]
        }
    except Exception as e:
        status["components"]["vector_db"] = {
            "status": "unhealthy",
            "error": str(e)
        }

    return status
