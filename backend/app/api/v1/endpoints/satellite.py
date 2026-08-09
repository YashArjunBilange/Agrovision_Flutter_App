from datetime import date
from typing import Any, List
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.api import deps
from app.models.user import User
from app.models.farm import Farm
from app.models.satellite import SatelliteObservation
from app.schemas.satellite import SatelliteObservationResponse, SatelliteHistoryResponse
from app.services.sentinel_service import SentinelService

router = APIRouter()

@router.get("/{farm_id}/latest", response_model=SatelliteObservationResponse)
async def get_latest_satellite_observation(
    farm_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get or fetch the latest satellite observation (True Color and NDVI) for a specific farm.
    """
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    if farm.user_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")
    
    if not farm.polygon_geojson:
        raise HTTPException(status_code=400, detail="Farm polygon is not defined. Please draw it on the map first.")
        
    # Check cache (e.g. within last 3 days)
    cached_obs = db.query(SatelliteObservation).filter(
        SatelliteObservation.farm_id == farm.id
    ).order_by(SatelliteObservation.observation_date.desc()).first()
    
    # Simple caching logic: if we have an observation from the last 3 days, return it.
    if cached_obs and (date.today() - cached_obs.observation_date).days <= 3:
        # Note: image_path is storing the base64 URI temporarily for this implementation to avoid file I/O complexity
        return {
            "id": cached_obs.id,
            "farm_id": cached_obs.farm_id,
            "observation_date": cached_obs.observation_date,
            "cloud_cover": cached_obs.cloud_cover,
            "satellite": cached_obs.satellite,
            "true_color_image_url": cached_obs.true_color_image_path,
            "ndvi_image_url": cached_obs.ndvi_image_path,
            "ndvi": {
                "mean": cached_obs.ndvi_mean or 0,
                "min": cached_obs.ndvi_min or 0,
                "max": cached_obs.ndvi_max or 0
            }
        }
    
    # Fetch from Sentinel API
    try:
        new_obs_data = await SentinelService.fetch_latest_observation(
            polygon_geojson=farm.polygon_geojson,
            max_cloud_cover=20.0
        )
    except HTTPException as e:
        # If API is missing config or fails, return the last cached version if available, or re-raise
        if cached_obs:
             return {
                "id": cached_obs.id,
                "farm_id": cached_obs.farm_id,
                "observation_date": cached_obs.observation_date,
                "cloud_cover": cached_obs.cloud_cover,
                "satellite": cached_obs.satellite,
                "true_color_image_url": cached_obs.true_color_image_path,
                "ndvi_image_url": cached_obs.ndvi_image_path,
                "ndvi": {
                    "mean": cached_obs.ndvi_mean or 0,
                    "min": cached_obs.ndvi_min or 0,
                    "max": cached_obs.ndvi_max or 0
                }
            }
        raise e
        
    # Create new observation
    new_obs = SatelliteObservation(
        farm_id=farm.id,
        observation_date=new_obs_data["observation_date"],
        cloud_cover=new_obs_data["cloud_cover"],
        satellite=new_obs_data["satellite"],
        true_color_image_path=new_obs_data["true_color_image_base64"],  # Storing as base64 in DB for this version
        ndvi_image_path=new_obs_data["ndvi_image_base64"],
        ndvi_mean=new_obs_data["ndvi_mean"],
        ndvi_min=new_obs_data["ndvi_min"],
        ndvi_max=new_obs_data["ndvi_max"],
    )
    
    db.add(new_obs)
    db.commit()
    db.refresh(new_obs)
    
    return {
        "id": new_obs.id,
        "farm_id": new_obs.farm_id,
        "observation_date": new_obs.observation_date,
        "cloud_cover": new_obs.cloud_cover,
        "satellite": new_obs.satellite,
        "true_color_image_url": new_obs.true_color_image_path,
        "ndvi_image_url": new_obs.ndvi_image_path,
        "ndvi": {
            "mean": new_obs.ndvi_mean or 0,
            "min": new_obs.ndvi_min or 0,
            "max": new_obs.ndvi_max or 0
        }
    }

@router.get("/{farm_id}/history", response_model=SatelliteHistoryResponse)
def get_satellite_history(
    farm_id: int,
    limit: int = 12,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(deps.get_current_active_user),
) -> Any:
    """
    Get history of satellite observations for NDVI trending.
    """
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    if farm.user_id != current_user.id:
        raise HTTPException(status_code=400, detail="Not enough permissions")
        
    observations = db.query(SatelliteObservation).filter(
        SatelliteObservation.farm_id == farm.id
    ).order_by(SatelliteObservation.observation_date.desc()).limit(limit).all()
    
    history_list = []
    for obs in observations:
        history_list.append({
            "id": obs.id,
            "farm_id": obs.farm_id,
            "observation_date": obs.observation_date,
            "cloud_cover": obs.cloud_cover,
            "satellite": obs.satellite,
            "true_color_image_url": obs.true_color_image_path,
            "ndvi_image_url": obs.ndvi_image_path,
            "ndvi": {
                "mean": obs.ndvi_mean or 0,
                "min": obs.ndvi_min or 0,
                "max": obs.ndvi_max or 0
            }
        })
        
    return {
        "farm_id": farm.id,
        "history": history_list
    }
