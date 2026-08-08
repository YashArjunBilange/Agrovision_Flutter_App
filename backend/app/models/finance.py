from datetime import datetime
from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class FarmTransaction(Base):
    __tablename__ = "farm_transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id"), nullable=True, index=True)
    crop_cycle_id = Column(Integer, ForeignKey("crop_cycles.id"), nullable=True)

    type = Column(String(20), nullable=False)  # "expense" or "income"
    category = Column(String(50), nullable=False)  # e.g., "Seeds", "Fertilizers", "Harvest"
    title = Column(String(150), nullable=False)
    amount = Column(Float, nullable=False)
    date = Column(DateTime, default=datetime.utcnow, nullable=False)
    notes = Column(Text, nullable=True)
    payment_method = Column(String(30), default="Cash", nullable=True)

    quantity = Column(Float, nullable=True)
    unit = Column(String(30), nullable=True)
    rate_per_unit = Column(Float, nullable=True)
    receipt_image_url = Column(String(255), nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    user = relationship("User", backref="transactions")
    farm = relationship("Farm", backref="transactions")
    crop_cycle = relationship("CropCycle", backref="transactions")
