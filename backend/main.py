from io import BytesIO
from typing import Dict
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image, UnidentifiedImageError
from ultralytics import YOLO

import remedies
from app.api.v1.api import api_router
from app.core.config import settings
from app.core.logging import LoggingMiddleware, logger
from app.db.session import init_db

# Initialize database schema
init_db()


ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
}

app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Add structured logging middleware
app.add_middleware(LoggingMiddleware)

# Add CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True if "*" not in settings.CORS_ORIGINS else False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Versioned API Router
app.include_router(api_router, prefix=settings.API_V1_STR)

# Load Legacy YOLO model for backward compatibility
try:
    legacy_model = YOLO(settings.LEGACY_MODEL_PATH)
    logger.info("Legacy YOLO model loaded successfully.")
except Exception as exc:
    legacy_model = None
    logger.warning(f"Could not load legacy model from {settings.LEGACY_MODEL_PATH}: {exc}")


def normalize_class_name(class_name: str) -> str:
    return class_name.lower().replace("___", "_").replace(" ", "_")


def get_remedy(class_name: str) -> str:
    normalized_name = normalize_class_name(class_name)
    return remedies.remedies.get(
        normalized_name,
        "No remedy information is currently available for this condition.",
    )


def extract_prediction(result) -> Dict[str, object]:
    if not hasattr(result, "probs") or result.probs is None:
        raise ValueError("Model output does not contain classification probabilities.")

    top1_index = int(result.probs.top1)
    top1_confidence = float(result.probs.top1conf)
    class_name = result.names[top1_index]
    normalized_name = normalize_class_name(class_name)
    remedy_text = get_remedy(class_name)

    return {
        "class_id": top1_index,
        "class_name": class_name,
        "normalized_class_name": normalized_name,
        "confidence": top1_confidence,
        "confidence_percentage": round(top1_confidence * 100, 2),
        "remedy": remedy_text,
    }


# ============================================================
# Legacy Root & Health Endpoints (Preserved for compatibility)
# ============================================================

@app.get("/", tags=["General"])
async def root() -> Dict[str, str]:
    return {
        "message": "Welcome to AgroVision API",
        "status": "online",
        "version": settings.VERSION,
        "docs": "/docs",
        "api_v1": f"{settings.API_V1_STR}",
    }


@app.get("/health", tags=["General"])
async def health() -> Dict[str, object]:
    return {
        "status": "healthy",
        "model_loaded": legacy_model is not None,
        "version": settings.VERSION,
    }


@app.get("/model-info", tags=["General"])
async def model_info() -> Dict[str, object]:
    if legacy_model is None:
        raise HTTPException(status_code=503, detail="Legacy model is not currently loaded.")
    return {
        "model_type": "YOLOv8 Classification",
        "number_of_classes": len(legacy_model.names),
        "classes": {str(i): name for i, name in legacy_model.names.items()},
    }


@app.post("/predict", tags=["General"])
async def predict(file: UploadFile = File(...)) -> Dict[str, object]:
    if legacy_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")

    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Unsupported file type. Supported types: JPG, JPEG, PNG, WEBP.",
        )

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Uploaded image is empty.")

    try:
        image = Image.open(BytesIO(image_bytes)).convert("RGB")
    except UnidentifiedImageError:
        raise HTTPException(status_code=400, detail="Unable to read the uploaded image.")
    except Exception:
        raise HTTPException(status_code=400, detail="Unable to read the uploaded image.")

    try:
        results = legacy_model.predict(image, verbose=False)
        if not results:
            raise RuntimeError("Model returned no prediction results.")

        prediction = extract_prediction(results[0])
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail="Prediction failed due to an internal error.",
        ) from exc

    return {
        "success": True,
        "filename": file.filename,
        "prediction": prediction,
    }
