from typing import List, Optional
from pydantic import BaseModel, Field


class CropRecommendationRequest(BaseModel):
    nitrogen: float = Field(default=80.0, ge=0, le=300, description="Nitrogen (N) kg/ha")
    phosphorus: float = Field(default=40.0, ge=0, le=200, description="Phosphorus (P) kg/ha")
    potassium: float = Field(default=40.0, ge=0, le=200, description="Potassium (K) kg/ha")
    ph: float = Field(default=6.8, ge=3.5, le=10.0, description="Soil pH value")
    temperature: float = Field(default=28.0, ge=-10, le=55, description="Average temperature °C")
    rainfall: float = Field(default=750.0, ge=0, le=3000, description="Annual rainfall mm")
    season: str = Field(default="Kharif", description="Kharif, Rabi, or Summer")
    soil_type: str = Field(default="Medium Black", description="Soil classification")
    irrigation_available: bool = Field(default=True, description="Whether assured irrigation is available")
    farm_id: Optional[int] = None


class CropRecommendationItem(BaseModel):
    crop_id: str
    name_en: str
    name_mr: str
    category: str
    match_score: float
    tier_en: str
    tier_mr: str
    badge_color: str
    duration_days: str
    estimated_yield_per_acre: str
    profit_potential_per_acre: str
    description_en: str
    description_mr: str
    advantages_en: List[str]
    advantages_mr: List[str]


class CropRecommendationResponse(BaseModel):
    recommendations: List[CropRecommendationItem]
    analyzed_season: str
    analyzed_soil: str
