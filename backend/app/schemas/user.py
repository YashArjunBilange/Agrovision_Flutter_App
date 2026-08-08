from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


# --- Farmer Profile Schemas ---

class FarmerProfileBase(BaseModel):
    preferred_language: str = Field(default="mr", description="Preferred UI language: 'mr' or 'en'")
    state: str = Field(default="Maharashtra")
    district: Optional[str] = None
    taluka: Optional[str] = None
    village: Optional[str] = None
    total_land_acres: float = Field(default=0.0, ge=0.0)
    soil_type: Optional[str] = None
    irrigation_type: Optional[str] = None
    avatar_url: Optional[str] = None


class FarmerProfileCreate(FarmerProfileBase):
    pass


class FarmerProfileUpdate(BaseModel):
    preferred_language: Optional[str] = None
    state: Optional[str] = None
    district: Optional[str] = None
    taluka: Optional[str] = None
    village: Optional[str] = None
    total_land_acres: Optional[float] = Field(default=None, ge=0.0)
    soil_type: Optional[str] = None
    irrigation_type: Optional[str] = None
    avatar_url: Optional[str] = None


class FarmerProfileResponse(FarmerProfileBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


# --- User & Auth Schemas ---

class UserBase(BaseModel):
    full_name: str = Field(min_length=2, max_length=100)
    phone: str = Field(min_length=10, max_length=15)
    email: Optional[str] = None


class UserCreate(UserBase):
    password: str = Field(min_length=6, max_length=100)
    preferred_language: str = "mr"
    state: str = "Maharashtra"
    district: Optional[str] = None
    taluka: Optional[str] = None
    village: Optional[str] = None
    total_land_acres: float = 0.0


class UserLogin(BaseModel):
    identifier: str = Field(description="Phone number or Email address")
    password: str = Field(min_length=1)


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None


class UserResponse(UserBase):
    id: int
    is_active: bool
    is_verified: bool
    role: str
    profile: Optional[FarmerProfileResponse] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse


class RefreshTokenRequest(BaseModel):
    refresh_token: str
