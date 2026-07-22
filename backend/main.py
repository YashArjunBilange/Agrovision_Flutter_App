from io import BytesIO
from typing import Dict

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image, UnidentifiedImageError
from ultralytics import YOLO

import remedies

ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
}

CONFIDENCE_THRESHOLD = 0.0  # Set to 0.0 for now; can be raised later if needed.

app = FastAPI(
    title="AgroVision API",
    description="FastAPI backend for YOLOv8 plant disease classification.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    # TODO: For production, restrict allow_origins to the deployed Flutter Web domain.
    # For example: allow_origins=["https://agrovision-xxxx.onrender.com"]
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

try:
    model = YOLO("best.pt")
except Exception as exc:
    raise RuntimeError("Failed to load YOLO model from best.pt") from exc


def normalize_class_name(class_name: str) -> str:
    normalized = class_name.lower().replace("___", "_").replace(" ", "_")
    return normalized


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


@app.get("/")
async def root() -> Dict[str, str]:
    return {
        "message": "Welcome to AgroVision API",
        "status": "online",
        "version": "1.0.0",
    }


@app.get("/health")
async def health() -> Dict[str, object]:
    return {
        "status": "healthy",
        "model_loaded": True,
    }


@app.get("/model-info")
async def model_info() -> Dict[str, object]:
    return {
        "model_type": "YOLOv8 Classification",
        "number_of_classes": len(model.names),
        "classes": {str(i): name for i, name in model.names.items()},
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)) -> Dict[str, object]:
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
        results = model.predict(image, verbose=False)
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
