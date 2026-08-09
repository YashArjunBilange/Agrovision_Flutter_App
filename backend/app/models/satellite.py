from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String, Text, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base_class import Base

class SatelliteObservation(Base):
    __tablename__ = "satellite_observations"

    id = Column(Integer, primary_key=True, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id", ondelete="CASCADE"), nullable=False, index=True)
    
    observation_date = Column(Date, nullable=False)
    cloud_cover = Column(Float, nullable=False)
    satellite = Column(String(50), default="Sentinel-2", nullable=False)
    
    true_color_image_path = Column(String(255), nullable=True)
    ndvi_image_path = Column(String(255), nullable=True)
    
    ndvi_mean = Column(Float, nullable=True)
    ndvi_min = Column(Float, nullable=True)
    ndvi_max = Column(Float, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    farm = relationship("Farm")
