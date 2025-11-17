FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy all code
COPY shared/ /app/shared/
COPY services/ /app/services/
COPY gateway/ /app/gateway/

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run gateway
CMD ["uvicorn", "gateway.main:app", "--host", "0.0.0.0", "--port", "8000"]
