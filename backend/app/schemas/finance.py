from datetime import datetime
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class TransactionBase(BaseModel):
    farm_id: Optional[int] = None
    crop_cycle_id: Optional[int] = None
    type: str = Field(..., description="'expense' or 'income'")
    category: str = Field(..., description="Category like Seeds, Fertilizers, Harvest, Labor, etc.")
    title: str = Field(..., min_length=1, max_length=150)
    amount: float = Field(..., gt=0)
    date: Optional[datetime] = None
    notes: Optional[str] = None
    payment_method: Optional[str] = "Cash"
    quantity: Optional[float] = None
    unit: Optional[str] = None
    rate_per_unit: Optional[float] = None
    receipt_image_url: Optional[str] = None


class TransactionCreate(TransactionBase):
    pass


class TransactionUpdate(BaseModel):
    farm_id: Optional[int] = None
    crop_cycle_id: Optional[int] = None
    type: Optional[str] = None
    category: Optional[str] = None
    title: Optional[str] = None
    amount: Optional[float] = None
    date: Optional[datetime] = None
    notes: Optional[str] = None
    payment_method: Optional[str] = None
    quantity: Optional[float] = None
    unit: Optional[str] = None
    rate_per_unit: Optional[float] = None
    receipt_image_url: Optional[str] = None


class TransactionOut(TransactionBase):
    id: int
    user_id: int
    date: datetime
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class CategoryBreakdownItem(BaseModel):
    category: str
    amount: float
    percentage: float


class FinanceSummary(BaseModel):
    total_income: float
    total_expense: float
    net_profit: float
    profit_margin_percent: float
    expense_breakdown: List[CategoryBreakdownItem]
    income_breakdown: List[CategoryBreakdownItem]
    recent_transactions: List[TransactionOut]


class CropEconomicsReport(BaseModel):
    farm_id: Optional[int] = None
    farm_name: Optional[str] = None
    area_acres: float
    total_expense: float
    total_income: float
    net_profit: float
    cost_per_acre: float
    revenue_per_acre: float
    profit_per_acre: float
    roi_percent: float
    top_expense_categories: List[CategoryBreakdownItem]
