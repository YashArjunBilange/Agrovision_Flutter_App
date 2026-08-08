from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_active_user, get_db
from app.core.logging import logger
from app.models.farm import Farm
from app.models.user import User
from app.schemas.farm import FarmCreate, FarmResponse, FarmUpdate

router = APIRouter()


@router.get("", response_model=List[FarmResponse], summary="List all farms for the current user")
def list_farms(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Retrieve all farm plots registered by the authenticated farmer."""
    farms = (
        db.query(Farm)
        .filter(Farm.user_id == current_user.id)
        .order_by(Farm.is_primary.desc(), Farm.created_at.desc())
        .all()
    )
    return farms


@router.post("", response_model=FarmResponse, status_code=status.HTTP_201_CREATED, summary="Create a new farm plot")
def create_farm(
    farm_in: FarmCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Register a new farm plot with area, GIS coordinates, soil & irrigation properties."""
    existing_count = db.query(Farm).filter(Farm.user_id == current_user.id).count()
    
    # If this is the farmer's first farm or marked as primary, make it primary
    is_primary = farm_in.is_primary or (existing_count == 0)

    if is_primary and existing_count > 0:
        # Reset previous primary flags
        db.query(Farm).filter(Farm.user_id == current_user.id).update({"is_primary": False})

    farm_data = farm_in.model_dump()
    farm_data["is_primary"] = is_primary
    farm_data["user_id"] = current_user.id

    farm = Farm(**farm_data)
    db.add(farm)
    db.commit()
    db.refresh(farm)

    logger.info(f"Farm '{farm.name}' (ID: {farm.id}) created for user {current_user.id}")
    return farm


@router.get("/{farm_id}", response_model=FarmResponse, summary="Get details of a specific farm")
def get_farm(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Get farm parcel details by ID."""
    farm = (
        db.query(Farm)
        .filter(Farm.id == farm_id, Farm.user_id == current_user.id)
        .first()
    )
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found.",
        )
    return farm


@router.put("/{farm_id}", response_model=FarmResponse, summary="Update farm details")
def update_farm(
    farm_id: int,
    farm_in: FarmUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Update properties of an existing farm parcel."""
    farm = (
        db.query(Farm)
        .filter(Farm.id == farm_id, Farm.user_id == current_user.id)
        .first()
    )
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found.",
        )

    update_data = farm_in.model_dump(exclude_unset=True)

    if update_data.get("is_primary") is True:
        # Set all other farms of this user to not primary
        db.query(Farm).filter(Farm.user_id == current_user.id, Farm.id != farm_id).update({"is_primary": False})

    for field, value in update_data.items():
        setattr(farm, field, value)

    db.commit()
    db.refresh(farm)
    logger.info(f"Farm ID {farm.id} updated by user {current_user.id}")
    return farm


@router.delete("/{farm_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete a farm")
def delete_farm(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Delete a farm parcel."""
    farm = (
        db.query(Farm)
        .filter(Farm.id == farm_id, Farm.user_id == current_user.id)
        .first()
    )
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found.",
        )

    was_primary = farm.is_primary
    db.delete(farm)
    db.commit()

    # If the deleted farm was primary, promote the most recent remaining farm to primary
    if was_primary:
        next_primary = (
            db.query(Farm)
            .filter(Farm.user_id == current_user.id)
            .order_by(Farm.created_at.desc())
            .first()
        )
        if next_primary:
            next_primary.is_primary = True
            db.commit()

    logger.info(f"Farm ID {farm_id} deleted by user {current_user.id}")
    return None


@router.post("/{farm_id}/set-active", response_model=FarmResponse, summary="Set farm as active primary context")
def set_active_farm(
    farm_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user),
):
    """Make this farm the active / primary farm for all agronomic context."""
    farm = (
        db.query(Farm)
        .filter(Farm.id == farm_id, Farm.user_id == current_user.id)
        .first()
    )
    if not farm:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Farm not found.",
        )

    # Set all other user farms to not primary
    db.query(Farm).filter(Farm.user_id == current_user.id).update({"is_primary": False})
    farm.is_primary = True
    db.commit()
    db.refresh(farm)

    logger.info(f"Farm ID {farm_id} marked as active primary farm for user {current_user.id}")
    return farm
