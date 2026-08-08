from typing import List, Optional
from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_active_user, get_db
from app.core.logging import logger
from app.models.scan import ScanHistory
from app.models.user import User
from app.schemas.disease import (
    DiagnosisResponse,
    DiseaseDetailSchema,
    ScanHistoryResponse,
)
from app.services.disease_knowledge import (
    DISEASE_KNOWLEDGE_BASE,
    get_disease_detail,
    normalize_disease_key,
)
from app.services.ml_service import ml_service

router = APIRouter()

ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/jpg", "image/png", "image/webp"}


@router.post("/diagnose", response_model=DiagnosisResponse, summary="Analyze plant leaf image for diseases")
async def diagnose_leaf_image(
    file: UploadFile = File(...),
    farm_id: Optional[int] = Form(None),
    language: str = Form("mr"),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_active_user),
):
    """Upload a plant leaf image to run AI disease diagnosis with full remedies."""
    if file.content_type not in ALLOWED_IMAGE_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format. Allowed: JPG, JPEG, PNG, WEBP.",
        )

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Uploaded file is empty.",
        )

    try:
        prediction_result = ml_service.predict_image(
            image_bytes=image_bytes,
            language=language,
            top_k=3,
        )
    except ValueError as val_err:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(val_err),
        )
    except Exception as exc:
        logger.error(f"Inference error: {exc}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Disease diagnosis could not be completed.",
        )

    # Save to ScanHistory if authenticated user
    scan_id = None
    if current_user:
        diag = prediction_result["diagnosis"]
        scan_record = ScanHistory(
            user_id=current_user.id,
            farm_id=farm_id,
            image_filename=file.filename,
            disease_key=prediction_result["normalized_name"],
            disease_name_en=diag["name_en"],
            disease_name_mr=diag["name_mr"],
            crop_name=diag["crop"],
            confidence=prediction_result["confidence"],
            severity_level=diag["severity_level"],
            is_healthy=prediction_result["is_healthy"],
            remedy_summary=diag["urgency_action"],
        )
        db.add(scan_record)
        db.commit()
        db.refresh(scan_record)
        scan_id = scan_record.id

    return DiagnosisResponse(
        success=True,
        class_id=prediction_result["class_id"],
        class_name=prediction_result["class_name"],
        normalized_name=prediction_result["normalized_name"],
        confidence=prediction_result["confidence"],
        confidence_percentage=prediction_result["confidence_percentage"],
        is_healthy=prediction_result["is_healthy"],
        scan_id=scan_id,
        farm_id=farm_id,
        top_k_predictions=prediction_result["top_k_predictions"],
        diagnosis=DiseaseDetailSchema(**prediction_result["diagnosis"]),
    )


@router.get("/history", response_model=List[ScanHistoryResponse], summary="Get farmer scan history")
def get_scan_history(
    farm_id: Optional[int] = Query(None),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Retrieve historical leaf scans and diagnosis results."""
    query = db.query(ScanHistory).filter(ScanHistory.user_id == current_user.id)
    if farm_id:
        query = query.filter(ScanHistory.farm_id == farm_id)

    records = query.order_by(ScanHistory.created_at.desc()).limit(limit).all()
    return records


@router.get("/remedies/{disease_key}", response_model=DiseaseDetailSchema, summary="Lookup remedy for a disease")
def get_remedy_details(
    disease_key: str,
    language: str = Query("mr", pattern="^(en|mr)$"),
):
    """Fetch complete treatment, chemical dosages, and cultural controls for a disease."""
    return DiseaseDetailSchema(**get_disease_detail(disease_key, language=language))


@router.get("/catalog", response_model=List[DiseaseDetailSchema], summary="List all supported disease diagnoses")
def get_disease_catalog(
    language: str = Query("mr", pattern="^(en|mr)$"),
):
    """Return agricultural knowledge catalog of all detectable diseases."""
    results = []
    for key in DISEASE_KNOWLEDGE_BASE.keys():
        detail = get_disease_detail(key, language=language)
        results.append(DiseaseDetailSchema(**detail))
    return results
