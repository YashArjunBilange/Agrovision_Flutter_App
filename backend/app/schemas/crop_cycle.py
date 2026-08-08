from datetime import date, datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field


class CropTaskBase(BaseModel):
    title_en: str
    title_mr: str
    task_type: str
    due_days_after_sowing: int
    due_date: Optional[date] = None
    is_completed: bool = False
    notes: Optional[str] = None


class CropTaskResponse(CropTaskBase):
    id: int
    crop_cycle_id: int
    stage_id: str
    stage_name_en: str
    stage_name_mr: str
    completed_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)


class CropCycleCreate(BaseModel):
    farm_id: int
    crop_name: str = Field(default="Maize")
    variety_name: Optional[str] = Field(default=None, description="e.g. Pioneer 3396 / संकरित मका")
    season: str = Field(default="Kharif", description="Kharif, Rabi, or Summer")
    sowing_date: date = Field(default_factory=date.today)


class CropCycleResponse(BaseModel):
    id: int
    user_id: int
    farm_id: int
    crop_name: str
    variety_name: Optional[str] = None
    season: str
    sowing_date: date
    expected_harvest_date: Optional[date] = None
    status: str
    days_since_sowing: int
    progress_percentage: float
    current_stage: Dict[str, Any]
    tasks: List[CropTaskResponse] = []

    model_config = ConfigDict(from_attributes=True)


class FertilizerDosageCalculation(BaseModel):
    stage_id: str
    acreage: float = Field(..., gt=0)


class FertilizerCalculationResponse(BaseModel):
    title_en: Optional[str] = None
    title_mr: Optional[str] = None
    acreage: float
    fertilizers_kg: Dict[str, float]
    instruction_en: Optional[str] = None
    instruction_mr: Optional[str] = None
