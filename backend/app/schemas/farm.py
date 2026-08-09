from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class FarmBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    area_acres: float = Field(default=1.0, gt=0.0)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    state: str = "Maharashtra"
    district: Optional[str] = None
    taluka: Optional[str] = None
    village: Optional[str] = None
    pincode: Optional[str] = None
    survey_number: Optional[str] = None
    soil_type: Optional[str] = None
    soil_ph: Optional[float] = Field(None, ge=3.0, le=11.0)
    soil_organic_carbon: Optional[float] = Field(None, ge=0.0, le=10.0)
    irrigation_type: Optional[str] = None
    water_source: Optional[str] = None
    is_active: bool = True
    is_primary: bool = False
    notes: Optional[str] = None

    # New fields
    polygon_geojson: Optional[str] = None
    area_sqm: Optional[float] = None
    area_hectares: Optional[float] = None
    perimeter_meters: Optional[float] = None
    length_meters: Optional[float] = None
    width_meters: Optional[float] = None


class FarmCreate(FarmBase):
    pass


class FarmUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    area_acres: Optional[float] = Field(None, gt=0.0)
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    state: Optional[str] = None
    district: Optional[str] = None
    taluka: Optional[str] = None
    village: Optional[str] = None
    pincode: Optional[str] = None
    survey_number: Optional[str] = None
    soil_type: Optional[str] = None
    soil_ph: Optional[float] = Field(None, ge=3.0, le=11.0)
    soil_organic_carbon: Optional[float] = Field(None, ge=0.0, le=10.0)
    irrigation_type: Optional[str] = None
    water_source: Optional[str] = None
    is_active: Optional[bool] = None
    is_primary: Optional[bool] = None
    notes: Optional[str] = None
    polygon_geojson: Optional[str] = None
    area_sqm: Optional[float] = None
    area_hectares: Optional[float] = None
    perimeter_meters: Optional[float] = None
    length_meters: Optional[float] = None
    width_meters: Optional[float] = None


class FarmResponse(FarmBase):
    id: int
    user_id: int
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)
