from datetime import date
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.crop_cycle import CropCycle
from app.models.farm import Farm
from app.models.user import User
from app.schemas.assistant import (
    ChatMessageRequest,
    ChatMessageResponse,
    QuickPromptResponse,
)
from app.services.assistant_service import AssistantService
from app.services.crop_lifecycle_knowledge import get_current_stage

router = APIRouter()


@router.post("/chat", response_model=ChatMessageResponse, summary="Chat with AI Agronomist")
async def chat_with_agronomist(
    payload: ChatMessageRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    farm_context = None
    crop_cycle_context = None

    # Load Farm Context if farm_id specified or user's active farm
    farm_id = payload.farm_id
    farm_query = db.query(Farm).filter(Farm.user_id == current_user.id)
    if farm_id:
        farm = farm_query.filter(Farm.id == farm_id).first()
    else:
        farm = farm_query.filter(Farm.is_active == True).first()

    if farm:
        farm_context = {
            "id": farm.id,
            "name": farm.name,
            "area_acres": farm.area_acres,
            "crop_type": "Maize",
            "soil_type": farm.soil_type,
            "irrigation_type": farm.irrigation_type,
        }

        # Check for active crop cycle on this farm
        active_cycle = (
            db.query(CropCycle)
            .filter(CropCycle.farm_id == farm.id, CropCycle.status == "active")
            .order_by(CropCycle.id.desc())
            .first()
        )
        if active_cycle:
            days_since = max(0, (date.today() - active_cycle.sowing_date).days)
            stage_meta = get_current_stage(days_since)
            crop_cycle_context = {
                "sowing_date": active_cycle.sowing_date.isoformat(),
                "days_since_sowing": days_since,
                "current_stage": stage_meta,
            }

    result = await AssistantService.get_response(
        message=payload.message,
        language=payload.language,
        farm_context=farm_context,
        crop_cycle_context=crop_cycle_context,
    )

    return ChatMessageResponse(**result)


@router.get("/quick-prompts", response_model=List[QuickPromptResponse], summary="Get starter agronomy questions")
def get_quick_prompts():
    return AssistantService.get_quick_prompts()
