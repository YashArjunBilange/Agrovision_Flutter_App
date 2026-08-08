from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base_class import Base


class CropCycle(Base):
    __tablename__ = "crop_cycles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    farm_id = Column(Integer, ForeignKey("farms.id", ondelete="CASCADE"), nullable=False, index=True)

    crop_name = Column(String(100), default="Maize", nullable=False)
    variety_name = Column(String(100), nullable=True)
    season = Column(String(50), default="Kharif", nullable=False)
    sowing_date = Column(Date, nullable=False)
    expected_harvest_date = Column(Date, nullable=True)
    status = Column(String(50), default="active", nullable=False)  # active, completed, archived

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    tasks = relationship("CropTask", back_populates="crop_cycle", cascade="all, delete-orphan", order_by="CropTask.due_days_after_sowing")
    farm = relationship("Farm")


class CropTask(Base):
    __tablename__ = "crop_tasks"

    id = Column(Integer, primary_key=True, index=True)
    crop_cycle_id = Column(Integer, ForeignKey("crop_cycles.id", ondelete="CASCADE"), nullable=False, index=True)

    stage_id = Column(String(100), nullable=False)
    stage_name_en = Column(String(150), nullable=False)
    stage_name_mr = Column(String(150), nullable=False)
    title_en = Column(String(255), nullable=False)
    title_mr = Column(String(255), nullable=False)
    task_type = Column(String(50), nullable=False)  # fertilizer, irrigation, spray, cultural, harvest
    due_days_after_sowing = Column(Integer, nullable=False)
    due_date = Column(Date, nullable=True)
    is_completed = Column(Boolean, default=False, nullable=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    notes = Column(Text, nullable=True)

    crop_cycle = relationship("CropCycle", back_populates="tasks")
