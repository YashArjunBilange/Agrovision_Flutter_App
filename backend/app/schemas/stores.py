from typing import List, Optional
from pydantic import BaseModel


class AgriStoreItem(BaseModel):
    id: int
    name_en: str
    name_mr: str
    dealer_name: str
    license_no: str
    phone: str
    alternate_phone: Optional[str] = None
    address_en: str
    address_mr: str
    taluka: str
    district: str
    pincode: str
    latitude: float
    longitude: float
    categories: List[str]
    rating: float
    is_verified: bool
    opening_hours: str
    distance_km: Optional[float] = None


class StoreListResponse(BaseModel):
    stores: List[AgriStoreItem]
    total_count: int
    user_latitude: Optional[float] = None
    user_longitude: Optional[float] = None
