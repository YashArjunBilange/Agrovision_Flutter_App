import os
from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    PROJECT_NAME: str = "AgroVision API"
    API_V1_STR: str = "/api/v1"
    VERSION: str = "1.0.0"
    DESCRIPTION: str = "Production AI-Powered Agricultural Assistant API for Maize Farming"

    # Security & JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "agrovision-production-super-secret-jwt-key-change-in-prod-2026")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 Days

    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "sqlite:///./agrovision.db"
    )

    # CORS
    CORS_ORIGINS: List[str] = ["*"]

    # ML Models
    LEGACY_MODEL_PATH: str = os.getenv("LEGACY_MODEL_PATH", "best.pt")
    MAIZE_YOLO_MODEL: str = os.getenv("MAIZE_YOLO_MODEL", "models/maize_disease_yolov11.pt")
    MAIZE_MODEL_VERSION: str = os.getenv("MAIZE_MODEL_VERSION", "1.0.0")
    MAIZE_CONFIDENCE_THRESHOLD: float = float(os.getenv("MAIZE_CONFIDENCE_THRESHOLD", "0.40"))
    MAIZE_DISEASE_CLASSES: List[str] = [
        "corn_cercospora_leaf_spot",
        "corn_common_rust",
        "corn_gray_leaf_spot",
        "corn_northern_leaf_blight",
    ]

    # External APIs
    WEATHER_API_KEY: str = os.getenv("WEATHER_API_KEY", "")
    AI_API_KEY: str = os.getenv("AI_API_KEY", "")
    AI_MODEL: str = os.getenv("AI_MODEL", "gemini-2.5-flash")

    # Sentinel-2 Satellite API
    SENTINEL_CLIENT_ID: str = os.getenv("SENTINEL_CLIENT_ID", "")
    SENTINEL_CLIENT_SECRET: str = os.getenv("SENTINEL_CLIENT_SECRET", "")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
