from typing import List, Optional
from pydantic import BaseModel, Field


class CurrentWeatherSchema(BaseModel):
    temperature: float
    humidity: int
    precipitation: float
    wind_speed: float
    wind_direction: float
    weather_code: int
    condition_en: str
    condition_mr: str
    icon: str


class SprayAdvisorySchema(BaseModel):
    status: str  # ideal, caution, unfavorable
    score: int
    title_en: str
    title_mr: str
    badge_color: str
    reasons_en: List[str]
    reasons_mr: List[str]


class AgriAlertSchema(BaseModel):
    type: str  # disease_risk, heat_stress, excess_rain, wind_lodging
    severity: str  # high, warning, info
    title_en: str
    title_mr: str
    description_en: str
    description_mr: str
    action_en: str
    action_mr: str


class HourlyForecastSchema(BaseModel):
    time: str
    temperature: float
    humidity: int
    precipitation_probability: int
    weather_code: int
    condition_en: str
    condition_mr: str
    icon: str
    wind_speed: float


class DailyForecastSchema(BaseModel):
    date: str
    temp_max: float
    temp_min: float
    precipitation_sum: float
    precipitation_probability: int
    weather_code: int
    condition_en: str
    condition_mr: str
    icon: str
    wind_speed_max: float


class WeatherForecastResponse(BaseModel):
    latitude: float
    longitude: float
    farm_name: Optional[str] = None
    farm_id: Optional[int] = None
    current: CurrentWeatherSchema
    spray_advisory: SprayAdvisorySchema
    agricultural_alerts: List[AgriAlertSchema] = []
    hourly_forecast: List[HourlyForecastSchema] = []
    daily_forecast: List[DailyForecastSchema] = []
