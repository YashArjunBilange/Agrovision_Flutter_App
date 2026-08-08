from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.user import User
from app.schemas.notification import AlertListResponse, FarmAlertItem
from app.services.alert_service import AlertService

router = APIRouter()


@router.get("/alerts", response_model=AlertListResponse, summary="Get real-time farm alerts and advisories")
def get_farm_alerts(
    farm_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    alerts_data = AlertService.generate_alerts_for_user(
        user=current_user,
        farm_id=farm_id,
        db=db,
    )
    items = [FarmAlertItem(**a) for a in alerts_data]
    unread = len([a for a in items if not a.is_read])
    return AlertListResponse(alerts=items, unread_count=unread)


@router.post("/alerts/{alert_id}/read", summary="Mark an alert as read")
def mark_alert_read(
    alert_id: int,
    current_user: User = Depends(get_current_user),
):
    return {"status": "ok", "alert_id": alert_id, "is_read": True}
