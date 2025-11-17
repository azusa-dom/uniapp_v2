# 🚀 UniApp Backend System

Enterprise-grade intelligent backend system for UniApp V2 - A comprehensive platform for UCL students and parents.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [API Documentation](#api-documentation)
- [Development](#development)
- [Deployment](#deployment)
- [Testing](#testing)

---

## ✨ Features

### 🔐 Authentication & Authorization
- JWT-based authentication
- Role-based access control (Student / Parent / Admin)
- OAuth2 integration ready (Google, Microsoft)
- Secure password hashing (bcrypt)

### 📚 UCL API Integration
- Personal timetable synchronization
- Course and module data
- Room booking information
- People search
- Intelligent caching (Redis)

### 🤖 AI Assistant
- Powered by DeepSeek-V3
- Context-aware conversations
- Chat history management
- Bilingual support (Chinese/English)
- RAG capabilities (ready for expansion)

### 📊 Database Models
- Users and permissions
- Courses and enrollments
- Emails and notifications
- Activities and participations
- Health records
- Chat sessions

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│           API Gateway (Port 8000)                │
│  - Request routing                               │
│  - Authentication middleware                     │
│  - CORS handling                                 │
└──────────┬──────────────────────────────────────┘
           │
    ┌──────┴──────┬─────────────┬─────────────┐
    ↓             ↓             ↓             ↓
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  Auth   │  │   UCL   │  │   AI    │  │  More   │
│ Service │  │  Proxy  │  │ Service │  │Services │
│ :8001   │  │  :8002  │  │  :8003  │  │  ...    │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
    │             │             │             │
    └──────┬──────┴─────┬───────┴─────────────┘
           ↓            ↓
    ┌─────────┐    ┌─────────┐
    │Postgres │    │  Redis  │
    │  :5432  │    │  :6379  │
    └─────────┘    └─────────┘
```

### Microservices

1. **Auth Service** (`:8001`)
   - User registration & login
   - JWT token management
   - Profile management

2. **UCL Proxy Service** (`:8002`)
   - UCL API integration
   - Data caching
   - Rate limiting

3. **AI Service** (`:8003`)
   - Chat conversations
   - Session management
   - LLM integration

### Infrastructure

- **PostgreSQL**: Primary database
- **Redis**: Caching & sessions
- **Qdrant**: Vector database (for RAG)
- **RabbitMQ**: Message queue
- **MinIO**: Object storage

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Git
- 2GB+ RAM
- 10GB+ disk space

### Installation

1. **Clone the repository**
```bash
cd /home/user/uniapp_v2/backend
```

2. **Create environment file**
```bash
cp .env.example .env
```

3. **Edit `.env` and configure:**
```bash
# Required: JWT Secret
JWT_SECRET_KEY=your-super-secret-key-change-this

# Required: UCL API Token
UCL_API_TOKEN=your-ucl-api-token

# Required: DeepSeek API Key (or OpenAI)
DEEPSEEK_API_KEY=sk-your-deepseek-api-key
```

4. **Start all services**
```bash
docker-compose up -d
```

5. **Check service health**
```bash
curl http://localhost:8000/health
```

6. **View logs**
```bash
docker-compose logs -f gateway
```

### First API Request

```bash
# Register a new user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@ucl.ac.uk",
    "password": "SecurePass123!",
    "full_name": "Test Student",
    "role": "student",
    "ucl_id": "ABCD1234"
  }'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@ucl.ac.uk",
    "password": "SecurePass123!"
  }'
```

---

## 📖 API Documentation

### Interactive Documentation

Once services are running, visit:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### API Endpoints

#### Authentication (`/api/v1/auth`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register new user |
| POST | `/login` | Login and get tokens |
| GET | `/me` | Get current user info |
| PATCH | `/me` | Update user profile |
| POST | `/change-password` | Change password |
| POST | `/logout` | Logout user |

#### UCL API (`/api/v1/ucl`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/timetable/personal` | Get personal timetable |
| GET | `/timetable/modules` | Get timetable by modules |
| GET | `/rooms` | List all rooms |
| GET | `/rooms/{id}/bookings` | Get room bookings |
| GET | `/search/people` | Search people |

#### AI Assistant (`/api/v1/ai`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/chat` | Send chat message |
| GET | `/sessions` | List chat sessions |
| GET | `/sessions/{id}/messages` | Get session messages |
| DELETE | `/sessions/{id}` | Delete session |

### Authentication

All endpoints except `/auth/register` and `/auth/login` require authentication.

**Include JWT token in headers:**
```bash
Authorization: Bearer <your_access_token>
```

**Example:**
```bash
curl -X GET http://localhost:8000/api/v1/auth/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

---

## 🛠️ Development

### Project Structure

```
backend/
├── shared/                 # Shared modules
│   ├── config/            # Settings & configuration
│   ├── database/          # Database connections
│   ├── models/            # SQLAlchemy models
│   └── utils/             # Utility functions
│
├── services/              # Microservices
│   ├── auth/              # Authentication service
│   ├── ucl_proxy/         # UCL API proxy
│   ├── ai/                # AI assistant service
│   ├── email/             # Email service (TODO)
│   ├── grades/            # Grades service (TODO)
│   └── ...
│
├── gateway/               # API Gateway
├── tests/                 # Tests
├── scripts/               # Utility scripts
├── docker-compose.yml     # Docker orchestration
└── requirements.txt       # Python dependencies
```

### Local Development (Without Docker)

1. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Set up local database**
```bash
# Start PostgreSQL and Redis locally
# Or use Docker:
docker-compose up -d postgres redis
```

4. **Run database migrations**
```bash
cd shared
alembic upgrade head
```

5. **Run individual service**
```bash
# Auth service
cd services/auth
uvicorn main:app --reload --port 8001

# Gateway
cd gateway
uvicorn main:app --reload --port 8000
```

### Adding a New Service

1. Create service directory:
```bash
mkdir -p services/new_service
```

2. Create files:
```
services/new_service/
├── __init__.py
├── main.py          # FastAPI app
├── router.py        # API routes
├── schemas.py       # Pydantic models
├── service.py       # Business logic
└── Dockerfile
```

3. Add to `docker-compose.yml`

4. Import router in `gateway/main.py`

### Code Quality

```bash
# Linting
ruff check .

# Type checking
mypy .

# Format code
black .

# Run tests
pytest tests/ -v --cov
```

---

## 🚢 Deployment

### Docker Compose (Recommended for Development)

```bash
# Production mode
docker-compose -f docker-compose.yml up -d

# Scale services
docker-compose up -d --scale auth_service=3

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Remove all data
docker-compose down -v
```

### Kubernetes (Production)

1. **Build and push images**
```bash
docker-compose build
docker-compose push
```

2. **Apply Kubernetes configs**
```bash
kubectl apply -f k8s/
```

3. **Check deployment**
```bash
kubectl get pods
kubectl get services
```

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | - | PostgreSQL connection string |
| `REDIS_URL` | ✅ | - | Redis connection string |
| `JWT_SECRET_KEY` | ✅ | - | JWT signing key |
| `UCL_API_TOKEN` | ✅ | - | UCL API token |
| `DEEPSEEK_API_KEY` | ❌ | - | DeepSeek AI API key |
| `OPENAI_API_KEY` | ❌ | - | OpenAI API key |
| `APP_ENV` | ❌ | development | Environment (development/production) |
| `APP_DEBUG` | ❌ | true | Debug mode |

---

## 🧪 Testing

### Run All Tests

```bash
pytest tests/ -v --cov=. --cov-report=html
```

### Test Individual Service

```bash
pytest tests/unit/test_auth.py -v
pytest tests/integration/test_api.py -v
```

### API Testing with curl

```bash
# Health check
curl http://localhost:8000/health

# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{...}'

# Login
TOKEN=$(curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@ucl.ac.uk","password":"Test123!"}' \
  | jq -r '.access_token')

# Use token
curl http://localhost:8000/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📊 Monitoring

### Health Checks

```bash
# Gateway
curl http://localhost:8000/health

# Individual services
curl http://localhost:8001/health  # Auth
curl http://localhost:8002/health  # UCL Proxy
curl http://localhost:8003/health  # AI
```

### Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f gateway
docker-compose logs -f auth_service

# Follow last 100 lines
docker-compose logs -f --tail=100
```

### Database

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U uniapp -d uniapp

# List tables
\dt

# Query users
SELECT id, email, role FROM users;
```

### Redis

```bash
# Connect to Redis
docker-compose exec redis redis-cli

# View cached keys
KEYS *

# Get value
GET ucl:timetable:*
```

---

## 🔧 Troubleshooting

### Services won't start

```bash
# Check logs
docker-compose logs

# Rebuild images
docker-compose build --no-cache

# Remove volumes and restart
docker-compose down -v
docker-compose up -d
```

### Database connection errors

```bash
# Verify PostgreSQL is running
docker-compose ps postgres

# Check connection
docker-compose exec postgres pg_isready

# Reset database
docker-compose down -v
docker-compose up -d postgres
```

### Port conflicts

```bash
# Check what's using the port
lsof -i :8000

# Change ports in docker-compose.yml
ports:
  - "8080:8000"  # Use 8080 instead
```

---

## 📚 Additional Resources

- [Architecture Documentation](../BACKEND_ARCHITECTURE.md)
- [API Design Guidelines](./docs/api-design.md)
- [Database Schema](./docs/database-schema.md)
- [Contributing Guide](./docs/contributing.md)

---

## 🤝 Support

For issues or questions:
1. Check existing documentation
2. Search [GitHub Issues](https://github.com/azusa-dom/uniapp_v2/issues)
3. Create a new issue with detailed description

---

## 📄 License

This project is proprietary software for UCL students.

---

**Built with ❤️ for UCL Students**
