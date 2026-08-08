from sqlalchemy import Boolean, Column, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from app.db.base_class import Base


class Farm(Base):
    __tablename__ = "farms"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(100), nullable=False)  # e.g., 'Gat No. 42 / शेत १'
    area_acres = Column(Float, nullable=False, default=1.0)
    
    # Geographic Location
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    state = Column(String(100), default="Maharashtra", nullable=False)
    district = Column(String(100), nullable=True)
    taluka = Column(String(100), nullable=True)
    village = Column(String(100), nullable=True)
    pincode = Column(String(10), nullable=True)
    survey_number = Column(String(50), nullable=True)  # e.g. Gat / Survey No.

    # Soil Properties
    soil_type = Column(String(100), nullable=True)  # Black Cotton, Red Loam, Sandy Loam, Clay, Alluvial
    soil_ph = Column(Float, nullable=True)
    soil_organic_carbon = Column(Float, nullable=True)

    # Irrigation & Water
    irrigation_type = Column(String(100), nullable=True)  # Drip, Sprinkler, Flood, Rainfed
    water_source = Column(String(100), nullable=True)  # Borewell, Well, Canal, River

    # Status
    is_active = Column(Boolean, default=True, nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    notes = Column(Text, nullable=True)

    # Relationships
    user = relationship("User", back_populates="farms")
