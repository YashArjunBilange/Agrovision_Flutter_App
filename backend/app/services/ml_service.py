import os
from io import BytesIO
from typing import Any, Dict, List, Optional
from PIL import Image, UnidentifiedImageError
from ultralytics import YOLO

from app.core.config import settings
from app.core.logging import logger
from app.services.disease_knowledge import get_disease_detail, normalize_disease_key


class MLService:
    _instance: Optional["MLService"] = None
    _model: Optional[YOLO] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MLService, cls).__new__(cls)
            cls._instance._load_model()
        return cls._instance

    def _load_model(self):
        model_path = settings.LEGACY_MODEL_PATH
        if os.path.exists(model_path):
            try:
                self._model = YOLO(model_path)
                logger.info(f"YOLO model loaded successfully from {model_path}")
            except Exception as e:
                logger.error(f"Failed to load YOLO model: {e}")
                self._model = None
        else:
            logger.warning(f"YOLO model file not found at {model_path}")
            self._model = None

    @property
    def is_loaded(self) -> bool:
        return self._model is not None

    def predict_image(
        self,
        image_bytes: bytes,
        language: str = "mr",
        top_k: int = 3,
    ) -> Dict[str, Any]:
        if not self._model:
            raise RuntimeError("YOLO ML model is not loaded.")

        try:
            image = Image.open(BytesIO(image_bytes)).convert("RGB")
        except UnidentifiedImageError:
            raise ValueError("Invalid image file format. Supported: JPG, PNG, WEBP.")
        except Exception as e:
            raise ValueError(f"Could not decode image: {e}")

        # Run inference
        results = self._model.predict(image, verbose=False)
        if not results or not hasattr(results[0], "probs") or results[0].probs is None:
            raise RuntimeError("Model returned empty prediction probabilities.")

        probs = results[0].probs
        top1_idx = int(probs.top1)
        top1_conf = float(probs.top1conf)
        top1_name = results[0].names[top1_idx]
        normalized_name = normalize_disease_key(top1_name)

        # Extract top-k probabilities
        top_predictions: List[Dict[str, Any]] = []
        if hasattr(probs, "top5") and probs.top5 is not None:
            for idx in probs.top5[:top_k]:
                idx_int = int(idx)
                c_name = results[0].names[idx_int]
                conf = float(probs.data[idx_int])
                top_predictions.append({
                    "class_id": idx_int,
                    "class_name": c_name,
                    "normalized_name": normalize_disease_key(c_name),
                    "confidence": round(conf, 4),
                    "confidence_percentage": round(conf * 100, 2),
                })

        # Fetch enriched knowledge & remedies
        disease_info = get_disease_detail(top1_name, language=language)

        return {
            "class_id": top1_idx,
            "class_name": top1_name,
            "normalized_name": normalized_name,
            "confidence": round(top1_conf, 4),
            "confidence_percentage": round(top1_conf * 100, 2),
            "is_healthy": "healthy" in normalized_name,
            "top_k_predictions": top_predictions,
            "diagnosis": disease_info,
        }


ml_service = MLService()
