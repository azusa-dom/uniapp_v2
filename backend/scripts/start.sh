#!/bin/bash
# Start script for UniApp Backend

set -e

echo "🚀 Starting UniApp Backend System..."
echo "===================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please edit it with your actual values."
    echo ""
    read -p "Press Enter to continue after editing .env, or Ctrl+C to abort..."
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

echo "✅ Docker is running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose not found"
    echo "Please install docker-compose and try again"
    exit 1
fi

echo "✅ docker-compose is available"

# Pull latest images
echo ""
echo "📥 Pulling latest base images..."
docker-compose pull postgres redis qdrant rabbitmq minio

# Build services
echo ""
echo "🔨 Building services..."
docker-compose build

# Start services
echo ""
echo "🚀 Starting all services..."
docker-compose up -d

# Wait for services to be healthy
echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check gateway health
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Gateway is healthy!"
        break
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Waiting for gateway... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Gateway failed to start. Check logs with: docker-compose logs gateway"
    exit 1
fi

# Display service URLs
echo ""
echo "🎉 UniApp Backend is running!"
echo "===================================="
echo ""
echo "📖 API Documentation:"
echo "   - Swagger UI: http://localhost:8000/docs"
echo "   - ReDoc:      http://localhost:8000/redoc"
echo ""
echo "🔍 Service Endpoints:"
echo "   - Gateway:    http://localhost:8000"
echo "   - Auth:       http://localhost:8001"
echo "   - UCL Proxy:  http://localhost:8002"
echo "   - AI:         http://localhost:8003"
echo ""
echo "🗄️  Infrastructure:"
echo "   - PostgreSQL: localhost:5432"
echo "   - Redis:      localhost:6379"
echo "   - RabbitMQ:   http://localhost:15672 (guest/guest)"
echo "   - MinIO:      http://localhost:9001 (minioadmin/minioadmin)"
echo "   - Qdrant:     http://localhost:6333"
echo ""
echo "📊 Monitoring:"
echo "   - Prometheus: http://localhost:9090"
echo "   - Grafana:    http://localhost:3000 (admin/admin)"
echo ""
echo "🔧 Useful commands:"
echo "   - View logs:    docker-compose logs -f"
echo "   - Stop all:     docker-compose down"
echo "   - Restart:      docker-compose restart"
echo ""
