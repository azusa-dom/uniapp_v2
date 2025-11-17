FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY shared/ /app/shared/
COPY services/auth/ /app/services/auth/
COPY services/ucl_proxy/ /app/services/ucl_proxy/

CMD ["uvicorn", "services.ucl_proxy.main:app", "--host", "0.0.0.0", "--port", "8002"]
