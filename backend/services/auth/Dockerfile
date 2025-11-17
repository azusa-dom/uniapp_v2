FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy shared modules
COPY shared/ /app/shared/

# Copy service code
COPY services/auth/ /app/services/auth/

# Run the service
CMD ["uvicorn", "services.auth.main:app", "--host", "0.0.0.0", "--port", "8001"]
