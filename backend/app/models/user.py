from sqlalchemy import Boolean, Column, Float, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from app.db.base_class import Base


class User(Base):
    __tablename__ = "users"

    email = Column(String(255), unique=True, index=True, nullable=True)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    role = Column(String(50), default="farmer", nullable=False)

    profile = relationship("FarmerProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    farms = relationship("Farm", back_populates="user", cascade="all, delete-orphan")


class FarmerProfile(Base):
    __tablename__ = "farmer_profiles"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    preferred_language = Column(String(10), default="mr", nullable=False)  # 'mr' (Marathi), 'en' (English)
    state = Column(String(100), default="Maharashtra", nullable=False)
    district = Column(String(100), nullable=True)
    taluka = Column(String(100), nullable=True)
    village = Column(String(100), nullable=True)
    total_land_acres = Column(Float, default=0.0, nullable=False)
    soil_type = Column(String(100), nullable=True)  # e.g., 'Black Cotton', 'Red Loamy', 'Clay'
    irrigation_type = Column(String(100), nullable=True)  # e.g., 'Drip', 'Sprinkler', 'Canal', 'Rainfed'
    avatar_url = Column(String(500), nullable=True)

    user = relationship("User", back_populates="profile")
