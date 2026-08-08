from typing import List, Optional
from pydantic import BaseModel


class FarmAlertItem(BaseModel):
    id: int
    title_en: str
    title_mr: str
    message_en: str
    message_mr: str
    type: str  # "weather", "advisory", "task", "warning"
    severity: str  # "high", "medium", "low"
    action_route: Optional[str] = None
    is_read: bool = False
    created_at: str


class AlertListResponse(BaseModel):
    alerts: List[FarmAlertItem]
    unread_count: int
