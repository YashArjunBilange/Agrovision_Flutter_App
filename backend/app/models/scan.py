from sqlalchemy import Boolean, Column, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from app.db.base_class import Base


class ScanHistory(Base):
    __tablename__ = "scan_history"

    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id", ondelete="SET NULL"), nullable=True, index=True)
    
    image_filename = Column(String(255), nullable=True)
    disease_key = Column(String(100), nullable=False)
    disease_name_en = Column(String(200), nullable=False)
    disease_name_mr = Column(String(200), nullable=False)
    crop_name = Column(String(100), default="Maize", nullable=False)
    confidence = Column(Float, nullable=False)
    severity_level = Column(String(50), default="moderate", nullable=False)  # healthy, low, moderate, severe
    is_healthy = Column(Boolean, default=False, nullable=False)
    remedy_summary = Column(Text, nullable=True)

    # Relationships
    user = relationship("User")
    farm = relationship("Farm")
