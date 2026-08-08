from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_user_optional, get_db
from app.models.farm import Farm
from app.models.user import User
from app.schemas.stores import AgriStoreItem, StoreListResponse
from app.services.store_service import StoreService

router = APIRouter()


@router.get("", response_model=StoreListResponse, summary="Find nearby Krishi Seva Kendras and agricultural input stores")
def list_nearby_stores(
    lat: Optional[float] = Query(None, ge=-90, le=90),
    lon: Optional[float] = Query(None, ge=-180, le=180),
    farm_id: Optional[int] = Query(None),
    district: Optional[str] = Query(None),
    taluka: Optional[str] = Query(None),
    category: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    radius_km: float = Query(100.0, ge=1.0, le=500.0),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional),
):
    user_lat = lat
    user_lon = lon

    # Pre-fill coordinates and district from farm if farm_id given
    if farm_id and db:
        farm = db.query(Farm).filter(Farm.id == farm_id).first()
        if farm:
            if farm.latitude and farm.longitude:
                user_lat = farm.latitude
                user_lon = farm.longitude
            if not district and farm.district:
                district = farm.district
            if not taluka and farm.taluka:
                taluka = farm.taluka

    stores_data = StoreService.get_nearby_stores(
        user_lat=user_lat,
        user_lon=user_lon,
        district=district,
        taluka=taluka,
        category=category,
        search_query=search,
        max_radius_km=radius_km,
    )

    items = [AgriStoreItem(**s) for s in stores_data]

    return StoreListResponse(
        stores=items,
        total_count=len(items),
        user_latitude=user_lat,
        user_longitude=user_lon,
    )


@router.get("/{store_id}", response_model=AgriStoreItem, summary="Get store details by ID")
def get_store_details(store_id: int):
    store = StoreService.get_store_by_id(store_id)
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    return AgriStoreItem(**store)
