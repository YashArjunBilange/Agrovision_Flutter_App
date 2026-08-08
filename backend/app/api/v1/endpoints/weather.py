from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.farm import Farm
from app.models.user import User
from app.schemas.weather import (
    SprayAdvisorySchema,
    WeatherForecastResponse,
)
from app.services.weather_service import WeatherService

router = APIRouter()


@router.get("", response_model=WeatherForecastResponse, summary="Get weather forecast & agricultural alerts by coordinates")
async def get_weather_by_coordinates(
    latitude: float = Query(19.7515, description="Latitude (defaults to Maharashtra)"),
    longitude: float = Query(75.7139, description="Longitude"),
    farm_name: Optional[str] = Query(None, description="Optional farm name for display"),
):
    weather_data = await WeatherService.fetch_weather_forecast(latitude, longitude)
    weather_data["farm_name"] = farm_name
    return WeatherForecastResponse(**weather_data)


@router.get("/farm/{farm_id}", response_model=WeatherForecastResponse, summary="Get weather forecast for specific user farm")
async def get_weather_for_farm(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found or access denied.",
        )

    lat = farm.latitude if farm.latitude is not None else 19.7515
    lon = farm.longitude if farm.longitude is not None else 75.7139

    weather_data = await WeatherService.fetch_weather_forecast(lat, lon)
    weather_data["farm_name"] = farm.name
    weather_data["farm_id"] = farm.id

    return WeatherForecastResponse(**weather_data)


@router.get("/spray-advisory", response_model=SprayAdvisorySchema, summary="Calculate pesticide/fertilizer spray suitability")
def get_spray_advisory(
    temp: float = Query(..., description="Temperature in Celsius"),
    wind_speed: float = Query(..., description="Wind speed in km/h"),
    rain_prob: int = Query(0, ge=0, le=100, description="Precipitation probability %"),
    precipitation: float = Query(0.0, ge=0, description="Current precipitation in mm"),
):
    result = WeatherService.calculate_spray_advisory(
        temp=temp,
        wind_speed=wind_speed,
        rain_prob=rain_prob,
        precipitation=precipitation,
    )
    return SprayAdvisorySchema(**result)
