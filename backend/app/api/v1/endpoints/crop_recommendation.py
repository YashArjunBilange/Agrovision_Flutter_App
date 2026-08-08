from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.farm import Farm
from app.models.user import User
from app.schemas.crop_recommendation import (
    CropRecommendationItem,
    CropRecommendationRequest,
    CropRecommendationResponse,
)
from app.services.crop_recommendation_service import CropRecommendationService

router = APIRouter()


@router.post("/recommend", response_model=CropRecommendationResponse, summary="Get AI-driven crop suitability recommendations")
def get_crop_recommendations(
    payload: CropRecommendationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    soil_type = payload.soil_type
    ph = payload.ph
    irrigation_available = payload.irrigation_available

    # If farm_id provided, pre-fill missing or real farm parameters
    if payload.farm_id:
        farm = db.query(Farm).filter(Farm.id == payload.farm_id, Farm.user_id == current_user.id).first()
        if farm:
            if farm.soil_type:
                soil_type = farm.soil_type
            if farm.soil_ph:
                ph = farm.soil_ph
            if farm.irrigation_type:
                irrigation_available = "rainfed" not in farm.irrigation_type.lower()

    results = CropRecommendationService.recommend_crops(
        nitrogen=payload.nitrogen,
        phosphorus=payload.phosphorus,
        potassium=payload.potassium,
        ph=ph,
        temperature=payload.temperature,
        rainfall=payload.rainfall,
        season=payload.season,
        soil_type=soil_type,
        irrigation_available=irrigation_available,
    )

    items = [CropRecommendationItem(**item) for item in results]

    return CropRecommendationResponse(
        recommendations=items,
        analyzed_season=payload.season,
        analyzed_soil=soil_type,
    )


@router.get("/supported", summary="List all supported crop types with optimal baseline parameters")
def get_supported_crops():
    return CropRecommendationService.get_supported_crops()
