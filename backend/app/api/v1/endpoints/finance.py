from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.models.farm import Farm
from app.models.finance import FarmTransaction
from app.models.user import User
from app.schemas.finance import (
    CategoryBreakdownItem,
    CropEconomicsReport,
    FinanceSummary,
    TransactionCreate,
    TransactionOut,
    TransactionUpdate,
)

router = APIRouter()


@router.post("/transactions", response_model=TransactionOut, status_code=status.HTTP_201_CREATED, summary="Log a new farm income or expense")
def create_transaction(
    payload: TransactionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if payload.farm_id:
        farm = db.query(Farm).filter(Farm.id == payload.farm_id, Farm.user_id == current_user.id).first()
        if not farm:
            raise HTTPException(status_code=404, detail="Farm not found")

    txn_data = payload.model_dump()
    if not txn_data.get("date"):
        txn_data["date"] = datetime.utcnow()

    txn = FarmTransaction(
        user_id=current_user.id,
        **txn_data,
    )
    db.add(txn)
    db.commit()
    db.refresh(txn)
    return txn


@router.get("/transactions", response_model=List[TransactionOut], summary="List farm transactions")
def list_transactions(
    farm_id: Optional[int] = Query(None),
    type: Optional[str] = Query(None, pattern="^(expense|income)$"),
    category: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(FarmTransaction).filter(FarmTransaction.user_id == current_user.id)

    if farm_id:
        query = query.filter(FarmTransaction.farm_id == farm_id)
    if type:
        query = query.filter(FarmTransaction.type == type)
    if category:
        query = query.filter(FarmTransaction.category == category)

    return query.order_by(FarmTransaction.date.desc()).limit(limit).all()


@router.get("/transactions/{transaction_id}", response_model=TransactionOut, summary="Get single transaction")
def get_transaction(
    transaction_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    txn = db.query(FarmTransaction).filter(
        FarmTransaction.id == transaction_id,
        FarmTransaction.user_id == current_user.id,
    ).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return txn


@router.put("/transactions/{transaction_id}", response_model=TransactionOut, summary="Update transaction")
def update_transaction(
    transaction_id: int,
    payload: TransactionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    txn = db.query(FarmTransaction).filter(
        FarmTransaction.id == transaction_id,
        FarmTransaction.user_id == current_user.id,
    ).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")

    update_data = payload.model_dump(exclude_unset=True)
    for field, val in update_data.items():
        setattr(txn, field, val)

    db.commit()
    db.refresh(txn)
    return txn


@router.delete("/transactions/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete transaction")
def delete_transaction(
    transaction_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    txn = db.query(FarmTransaction).filter(
        FarmTransaction.id == transaction_id,
        FarmTransaction.user_id == current_user.id,
    ).first()
    if not txn:
        raise HTTPException(status_code=404, detail="Transaction not found")

    db.delete(txn)
    db.commit()
    return None


@router.get("/summary", response_model=FinanceSummary, summary="Get aggregated financial summary and category breakdown")
def get_finance_summary(
    farm_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(FarmTransaction).filter(FarmTransaction.user_id == current_user.id)
    if farm_id:
        query = query.filter(FarmTransaction.farm_id == farm_id)

    all_txns = query.all()

    total_income = sum(t.amount for t in all_txns if t.type == "income")
    total_expense = sum(t.amount for t in all_txns if t.type == "expense")
    net_profit = total_income - total_expense

    margin = (net_profit / total_income * 100.0) if total_income > 0 else 0.0

    # Expense Category breakdown
    expense_cats = {}
    for t in all_txns:
        if t.type == "expense":
            expense_cats[t.category] = expense_cats.get(t.category, 0.0) + t.amount

    expense_breakdown = [
        CategoryBreakdownItem(
            category=cat,
            amount=round(amt, 2),
            percentage=round((amt / total_expense * 100.0) if total_expense > 0 else 0.0, 1),
        )
        for cat, amt in sorted(expense_cats.items(), key=lambda x: x[1], reverse=True)
    ]

    # Income Category breakdown
    income_cats = {}
    for t in all_txns:
        if t.type == "income":
            income_cats[t.category] = income_cats.get(t.category, 0.0) + t.amount

    income_breakdown = [
        CategoryBreakdownItem(
            category=cat,
            amount=round(amt, 2),
            percentage=round((amt / total_income * 100.0) if total_income > 0 else 0.0, 1),
        )
        for cat, amt in sorted(income_cats.items(), key=lambda x: x[1], reverse=True)
    ]

    recent_txns = sorted(all_txns, key=lambda x: x.date, reverse=True)[:10]

    return FinanceSummary(
        total_income=round(total_income, 2),
        total_expense=round(total_expense, 2),
        net_profit=round(net_profit, 2),
        profit_margin_percent=round(margin, 1),
        expense_breakdown=expense_breakdown,
        income_breakdown=income_breakdown,
        recent_transactions=recent_txns,
    )


@router.get("/economics-report", response_model=CropEconomicsReport, summary="Get per-acre unit economics report")
def get_economics_report(
    farm_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    area_acres = 1.0
    farm_name = "All Farms"

    if farm_id:
        farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
        if farm:
            area_acres = farm.area_acres if farm.area_acres > 0 else 1.0
            farm_name = farm.name
    else:
        # Sum total land of user
        farms = db.query(Farm).filter(Farm.user_id == current_user.id).all()
        if farms:
            total_acres = sum(f.area_acres for f in farms)
            if total_acres > 0:
                area_acres = total_acres

    query = db.query(FarmTransaction).filter(FarmTransaction.user_id == current_user.id)
    if farm_id:
        query = query.filter(FarmTransaction.farm_id == farm_id)

    all_txns = query.all()

    total_income = sum(t.amount for t in all_txns if t.type == "income")
    total_expense = sum(t.amount for t in all_txns if t.type == "expense")
    net_profit = total_income - total_expense

    cost_per_acre = total_expense / area_acres
    revenue_per_acre = total_income / area_acres
    profit_per_acre = net_profit / area_acres
    roi = ((net_profit / total_expense) * 100.0) if total_expense > 0 else 0.0

    expense_cats = {}
    for t in all_txns:
        if t.type == "expense":
            expense_cats[t.category] = expense_cats.get(t.category, 0.0) + t.amount

    top_expenses = [
        CategoryBreakdownItem(
            category=cat,
            amount=round(amt, 2),
            percentage=round((amt / total_expense * 100.0) if total_expense > 0 else 0.0, 1),
        )
        for cat, amt in sorted(expense_cats.items(), key=lambda x: x[1], reverse=True)[:5]
    ]

    return CropEconomicsReport(
        farm_id=farm_id,
        farm_name=farm_name,
        area_acres=round(area_acres, 2),
        total_expense=round(total_expense, 2),
        total_income=round(total_income, 2),
        net_profit=round(net_profit, 2),
        cost_per_acre=round(cost_per_acre, 2),
        revenue_per_acre=round(revenue_per_acre, 2),
        profit_per_acre=round(profit_per_acre, 2),
        roi_percent=round(roi, 1),
        top_expense_categories=top_expenses,
    )
