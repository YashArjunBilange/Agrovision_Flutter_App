from fastapi import APIRouter
from app.api.v1.endpoints import (
    auth,
    farms,
    crops,
    disease,
    weather,
    assistant,
    recommendations,
    finance,
    stores,
    notifications,
    satellite,
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(farms.router, prefix="/farms", tags=["Farms & Fields"])
api_router.include_router(crops.router, prefix="/crops", tags=["Crop Lifecycle"])
api_router.include_router(satellite.router, prefix="/satellite", tags=["Satellite Imagery"])
api_router.include_router(disease.router, prefix="/disease", tags=["Maize Disease Detection"])
api_router.include_router(weather.router, prefix="/weather", tags=["Weather Intelligence & Alerts"])
api_router.include_router(assistant.router, prefix="/assistant", tags=["AI Agricultural Assistant"])
api_router.include_router(recommendations.router, prefix="/recommendations", tags=["Crop Recommendations"])
api_router.include_router(finance.router, prefix="/finance", tags=["Farm Economics & Accounting"])
api_router.include_router(stores.router, prefix="/stores", tags=["Nearby Agri Stores"])
api_router.include_router(notifications.router, prefix="/notifications", tags=["Farmer Notifications"])
