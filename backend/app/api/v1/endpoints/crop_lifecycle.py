from datetime import date, datetime, timedelta
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.crop_cycle import CropCycle, CropTask
from app.models.farm import Farm
from app.models.user import User
from app.schemas.crop_cycle import (
    CropCycleCreate,
    CropCycleResponse,
    CropTaskResponse,
    FertilizerCalculationResponse,
    FertilizerDosageCalculation,
)
from app.services.crop_lifecycle_knowledge import (
    MAIZE_LIFECYCLE_STAGES,
    calculate_fertilizer_dosage_for_acres,
    get_current_stage,
)

router = APIRouter()


def _format_crop_cycle_response(cycle: CropCycle) -> Dict[str, Any]:
    today = date.today()
    days_since_sowing = max(0, (today - cycle.sowing_date).days)
    current_stage = get_current_stage(days_since_sowing)

    # Progress percentage out of standard 115-day cycle
    progress = min(100.0, round((days_since_sowing / 115.0) * 100.0, 1))

    return {
        "id": cycle.id,
        "user_id": cycle.user_id,
        "farm_id": cycle.farm_id,
        "crop_name": cycle.crop_name,
        "variety_name": cycle.variety_name,
        "season": cycle.season,
        "sowing_date": cycle.sowing_date,
        "expected_harvest_date": cycle.expected_harvest_date,
        "status": cycle.status,
        "days_since_sowing": days_since_sowing,
        "progress_percentage": progress,
        "current_stage": current_stage,
        "tasks": cycle.tasks,
    }


@router.post("", response_model=CropCycleResponse, status_code=status.HTTP_201_CREATED, summary="Start a new crop cycle")
def create_crop_cycle(
    payload: CropCycleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Verify farm ownership
    farm = db.query(Farm).filter(Farm.id == payload.farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found or access denied.",
        )

    # Archive previous active cycle for this farm if any
    active_prev = (
        db.query(CropCycle)
        .filter(CropCycle.farm_id == payload.farm_id, CropCycle.status == "active")
        .all()
    )
    for prev in active_prev:
        prev.status = "archived"

    expected_harvest = payload.sowing_date + timedelta(days=115)

    new_cycle = CropCycle(
        user_id=current_user.id,
        farm_id=payload.farm_id,
        crop_name=payload.crop_name,
        variety_name=payload.variety_name,
        season=payload.season,
        sowing_date=payload.sowing_date,
        expected_harvest_date=expected_harvest,
        status="active",
    )
    db.add(new_cycle)
    db.flush()

    # Generate all default stage tasks
    for stage in MAIZE_LIFECYCLE_STAGES:
        for t in stage.get("default_tasks", []):
            task_due_date = payload.sowing_date + timedelta(days=t["due_days"])
            crop_task = CropTask(
                crop_cycle_id=new_cycle.id,
                stage_id=stage["stage_id"],
                stage_name_en=stage["name_en"],
                stage_name_mr=stage["name_mr"],
                title_en=t["title_en"],
                title_mr=t["title_mr"],
                task_type=t["task_type"],
                due_days_after_sowing=t["due_days"],
                due_date=task_due_date,
                is_completed=False,
            )
            db.add(crop_task)

    db.commit()
    db.refresh(new_cycle)

    return _format_crop_cycle_response(new_cycle)


@router.get("/active", response_model=Optional[CropCycleResponse], summary="Get active crop cycle for farm")
def get_active_crop_cycle(
    farm_id: Optional[int] = Query(None, description="Optional farm ID. Defaults to active/primary farm."),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(CropCycle).filter(
        CropCycle.user_id == current_user.id,
        CropCycle.status == "active",
    )

    if farm_id:
        query = query.filter(CropCycle.farm_id == farm_id)
    else:
        # Check if user has an active farm
        primary_farm = db.query(Farm).filter(Farm.user_id == current_user.id, Farm.is_active == True).first()
        if primary_farm:
            query = query.filter(CropCycle.farm_id == primary_farm.id)

    cycle = query.order_by(CropCycle.id.desc()).first()
    if not cycle:
        return None

    return _format_crop_cycle_response(cycle)


@router.get("/stages", response_model=List[Dict[str, Any]], summary="Get all reference maize growth stages")
def get_stages_catalog():
    return MAIZE_LIFECYCLE_STAGES


@router.post("/calculate-fertilizer", response_model=FertilizerCalculationResponse, summary="Calculate fertilizer quantity by acreage")
def calculate_fertilizer(
    payload: FertilizerDosageCalculation,
):
    result = calculate_fertilizer_dosage_for_acres(payload.acreage, payload.stage_id)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Stage '{payload.stage_id}' not found or has no fertilizer recommendation.",
        )
    return FertilizerCalculationResponse(**result)


@router.put("/tasks/{task_id}/toggle", response_model=CropTaskResponse, summary="Toggle task completion status")
def toggle_task_status(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    task = (
        db.query(CropTask)
        .join(CropCycle)
        .filter(CropTask.id == task_id, CropCycle.user_id == current_user.id)
        .first()
    )
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found or access denied.",
        )

    task.is_completed = not task.is_completed
    task.completed_at = datetime.utcnow() if task.is_completed else None

    db.commit()
    db.refresh(task)
    return task
