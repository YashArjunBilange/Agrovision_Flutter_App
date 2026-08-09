from datetime import date, datetime
from typing import Optional, List
from pydantic import BaseModel, ConfigDict

class NDVIData(BaseModel):
    mean: float
    min: float
    max: float

class SatelliteObservationBase(BaseModel):
    observation_date: date
    cloud_cover: float
    satellite: str = "Sentinel-2"

class SatelliteObservationResponse(SatelliteObservationBase):
    id: int
    farm_id: int
    true_color_image_url: Optional[str] = None
    ndvi_image_url: Optional[str] = None
    ndvi: Optional[NDVIData] = None
    
    model_config = ConfigDict(from_attributes=True)

class SatelliteHistoryResponse(BaseModel):
    farm_id: int
    history: List[SatelliteObservationResponse]
