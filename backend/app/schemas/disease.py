from datetime import datetime
from typing import Any, List, Optional
from pydantic import BaseModel, ConfigDict


class ChemicalTreatmentItem(BaseModel):
    name_en: str
    name_mr: str
    dosage_per_liter: str
    dosage_15l_pump: str
    waiting_period_days: Optional[int] = None


class BiologicalTreatmentItem(BaseModel):
    name_en: str
    name_mr: str
    dosage_per_liter: str
    dosage_15l_pump: str


class DiseaseDetailSchema(BaseModel):
    key: str
    name: str
    name_en: str
    name_mr: str
    crop: str
    severity_level: str
    symptoms: str
    chemical_treatment: List[ChemicalTreatmentItem] = []
    biological_treatment: List[BiologicalTreatmentItem] = []
    cultural_preventions: List[str] = []
    urgency_action: str


class TopPredictionItem(BaseModel):
    class_id: int
    class_name: str
    normalized_name: str
    confidence: float
    confidence_percentage: float


class DiagnosisResponse(BaseModel):
    success: bool = True
    class_id: int
    class_name: str
    normalized_name: str
    confidence: float
    confidence_percentage: float
    is_healthy: bool
    scan_id: Optional[int] = None
    farm_id: Optional[int] = None
    top_k_predictions: List[TopPredictionItem] = []
    diagnosis: DiseaseDetailSchema


class ScanHistoryResponse(BaseModel):
    id: int
    user_id: int
    farm_id: Optional[int] = None
    image_filename: Optional[str] = None
    disease_key: str
    disease_name_en: str
    disease_name_mr: str
    crop_name: str
    confidence: float
    severity_level: str
    is_healthy: bool
    remedy_summary: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
