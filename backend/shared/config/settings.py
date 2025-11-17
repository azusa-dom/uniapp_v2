"""
Application Settings
Centralized configuration management using Pydantic Settings
"""
from typing import List, Optional
from pydantic import Field, validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    """Main application settings"""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )

    # Application
    app_env: str = Field(default="development", alias="APP_ENV")
    app_debug: bool = Field(default=True, alias="APP_DEBUG")
    app_host: str = Field(default="0.0.0.0", alias="APP_HOST")
    app_port: int = Field(default=8000, alias="APP_PORT")
    app_workers: int = Field(default=4, alias="APP_WORKERS")

    # Database
    database_url: str = Field(..., alias="DATABASE_URL")
    database_pool_size: int = Field(default=20, alias="DATABASE_POOL_SIZE")
    database_max_overflow: int = Field(default=10, alias="DATABASE_MAX_OVERFLOW")

    # Redis
    redis_url: str = Field(default="redis://localhost:6379/0", alias="REDIS_URL")
    redis_cache_db: int = Field(default=1, alias="REDIS_CACHE_DB")
    redis_session_db: int = Field(default=2, alias="REDIS_SESSION_DB")

    # JWT
    jwt_secret_key: str = Field(..., alias="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    jwt_access_token_expire_minutes: int = Field(default=60, alias="JWT_ACCESS_TOKEN_EXPIRE_MINUTES")
    jwt_refresh_token_expire_days: int = Field(default=7, alias="JWT_REFRESH_TOKEN_EXPIRE_DAYS")

    # OAuth2 (Optional)
    google_client_id: Optional[str] = Field(default=None, alias="GOOGLE_CLIENT_ID")
    google_client_secret: Optional[str] = Field(default=None, alias="GOOGLE_CLIENT_SECRET")
    microsoft_client_id: Optional[str] = Field(default=None, alias="MICROSOFT_CLIENT_ID")
    microsoft_client_secret: Optional[str] = Field(default=None, alias="MICROSOFT_CLIENT_SECRET")

    # UCL API
    ucl_api_base_url: str = Field(default="https://uclapi.com", alias="UCL_API_BASE_URL")
    ucl_api_token: str = Field(..., alias="UCL_API_TOKEN")

    # AI Services
    deepseek_api_key: Optional[str] = Field(default=None, alias="DEEPSEEK_API_KEY")
    deepseek_base_url: str = Field(default="https://api.deepseek.com/v1", alias="DEEPSEEK_BASE_URL")
    openai_api_key: Optional[str] = Field(default=None, alias="OPENAI_API_KEY")
    anthropic_api_key: Optional[str] = Field(default=None, alias="ANTHROPIC_API_KEY")

    # Vector Database
    qdrant_url: str = Field(default="http://localhost:6333", alias="QDRANT_URL")
    qdrant_api_key: Optional[str] = Field(default=None, alias="QDRANT_API_KEY")
    qdrant_collection_name: str = Field(default="ucl_knowledge", alias="QDRANT_COLLECTION_NAME")

    # Email
    email_imap_host: str = Field(default="imap.gmail.com", alias="EMAIL_IMAP_HOST")
    email_imap_port: int = Field(default=993, alias="EMAIL_IMAP_PORT")
    email_smtp_host: str = Field(default="smtp.gmail.com", alias="EMAIL_SMTP_HOST")
    email_smtp_port: int = Field(default=587, alias="EMAIL_SMTP_PORT")
    email_use_tls: bool = Field(default=True, alias="EMAIL_USE_TLS")

    # Moodle
    moodle_base_url: Optional[str] = Field(default=None, alias="MOODLE_BASE_URL")
    moodle_api_token: Optional[str] = Field(default=None, alias="MOODLE_API_TOKEN")

    # WiseFlow
    wiseflow_base_url: Optional[str] = Field(default=None, alias="WISEFLOW_BASE_URL")
    wiseflow_username: Optional[str] = Field(default=None, alias="WISEFLOW_USERNAME")
    wiseflow_password: Optional[str] = Field(default=None, alias="WISEFLOW_PASSWORD")

    # Celery
    celery_broker_url: str = Field(default="amqp://guest:guest@localhost:5672//", alias="CELERY_BROKER_URL")
    celery_result_backend: str = Field(default="redis://localhost:6379/3", alias="CELERY_RESULT_BACKEND")

    # MinIO/S3
    minio_endpoint: str = Field(default="localhost:9000", alias="MINIO_ENDPOINT")
    minio_access_key: str = Field(default="minioadmin", alias="MINIO_ACCESS_KEY")
    minio_secret_key: str = Field(default="minioadmin", alias="MINIO_SECRET_KEY")
    minio_bucket_name: str = Field(default="uniapp", alias="MINIO_BUCKET_NAME")
    minio_use_ssl: bool = Field(default=False, alias="MINIO_USE_SSL")

    # APNs
    apns_key_id: Optional[str] = Field(default=None, alias="APNS_KEY_ID")
    apns_team_id: Optional[str] = Field(default=None, alias="APNS_TEAM_ID")
    apns_bundle_id: str = Field(default="-.uniapp", alias="APNS_BUNDLE_ID")
    apns_use_sandbox: bool = Field(default=True, alias="APNS_USE_SANDBOX")
    apns_key_path: Optional[str] = Field(default=None, alias="APNS_KEY_PATH")

    # Monitoring
    sentry_dsn: Optional[str] = Field(default=None, alias="SENTRY_DSN")
    prometheus_port: int = Field(default=9090, alias="PROMETHEUS_PORT")

    # CORS
    cors_origins: List[str] = Field(
        default=["http://localhost:3000"],
        alias="CORS_ORIGINS"
    )
    cors_allow_credentials: bool = Field(default=True, alias="CORS_ALLOW_CREDENTIALS")

    # Rate Limiting
    rate_limit_per_minute: int = Field(default=100, alias="RATE_LIMIT_PER_MINUTE")
    rate_limit_per_hour: int = Field(default=1000, alias="RATE_LIMIT_PER_HOUR")

    # Logging
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")
    log_format: str = Field(default="json", alias="LOG_FORMAT")

    @validator("cors_origins", pre=True)
    def parse_cors_origins(cls, v):
        """Parse CORS origins from string or list"""
        if isinstance(v, str):
            return [origin.strip() for origin in v.strip("[]").split(",")]
        return v

    @property
    def is_production(self) -> bool:
        """Check if running in production"""
        return self.app_env.lower() == "production"

    @property
    def is_development(self) -> bool:
        """Check if running in development"""
        return self.app_env.lower() == "development"


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()


# Global settings instance
settings = get_settings()
