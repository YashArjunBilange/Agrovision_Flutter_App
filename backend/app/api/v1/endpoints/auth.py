from fastapi import APIRouter, Depends, HTTPException, status
import jwt
from sqlalchemy.orm import Session, joinedload

from app.api.deps import get_current_active_user
from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_password_hash,
    verify_password,
)
from app.db.session import get_db
from app.models.user import FarmerProfile, User
from app.schemas.user import (
    FarmerProfileUpdate,
    RefreshTokenRequest,
    TokenResponse,
    UserCreate,
    UserLogin,
    UserResponse,
)

router = APIRouter()


@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register_farmer(
    user_in: UserCreate,
    db: Session = Depends(get_db),
):
    """Register a new farmer account and profile."""
    # Check phone number uniqueness
    existing_phone = db.query(User).filter(User.phone == user_in.phone).first()
    if existing_phone:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this phone number is already registered.",
        )

    # Check email uniqueness if provided
    if user_in.email:
        existing_email = db.query(User).filter(User.email == user_in.email).first()
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email address is already registered.",
            )

    # Create User
    new_user = User(
        full_name=user_in.full_name,
        phone=user_in.phone,
        email=user_in.email,
        hashed_password=get_password_hash(user_in.password),
        is_active=True,
        is_verified=False,
        role="farmer",
    )
    db.add(new_user)
    db.flush()

    # Create Farmer Profile
    profile = FarmerProfile(
        user_id=new_user.id,
        preferred_language=user_in.preferred_language,
        state=user_in.state,
        district=user_in.district,
        taluka=user_in.taluka,
        village=user_in.village,
        total_land_acres=user_in.total_land_acres,
    )
    db.add(profile)
    db.commit()
    db.refresh(new_user)

    # Generate tokens
    access_token = create_access_token(new_user.id)
    refresh_token = create_refresh_token(new_user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=UserResponse.model_validate(new_user),
    )


@router.post("/login", response_model=TokenResponse)
def login_farmer(
    login_data: UserLogin,
    db: Session = Depends(get_db),
):
    """Login with phone number or email and password."""
    identifier = login_data.identifier.strip()

    # Search by phone or email
    user = (
        db.query(User)
        .options(joinedload(User.profile))
        .filter((User.phone == identifier) | (User.email == identifier))
        .first()
    )

    if not user or not verify_password(login_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone/email or password.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This account is deactivated. Please contact support.",
        )

    access_token = create_access_token(user.id)
    refresh_token = create_refresh_token(user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.post("/refresh", response_model=TokenResponse)
def refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db),
):
    """Obtain a new access token using a valid refresh token."""
    try:
        payload = decode_token(request.refresh_token)
        user_id = payload.get("sub")
        token_type = payload.get("type")

        if user_id is None or token_type != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token.",
            )
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token has expired. Please log in again.",
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token.",
        )

    user = (
        db.query(User)
        .options(joinedload(User.profile))
        .filter(User.id == int(user_id))
        .first()
    )
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User no longer exists or is inactive.",
        )

    access_token = create_access_token(user.id)
    new_refresh_token = create_refresh_token(user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
        user=UserResponse.model_validate(user),
    )


@router.get("/me", response_model=UserResponse)
def get_me(
    current_user: User = Depends(get_current_active_user),
):
    """Retrieve profile and account details for currently authenticated farmer."""
    return current_user


@router.put("/me/profile", response_model=UserResponse)
def update_profile(
    profile_in: FarmerProfileUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """Update farmer profile settings (language, district, land area, soil, etc.)."""
    profile = current_user.profile
    if not profile:
        profile = FarmerProfile(user_id=current_user.id)
        db.add(profile)

    update_data = profile_in.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)

    db.commit()
    db.refresh(current_user)
    return current_user
