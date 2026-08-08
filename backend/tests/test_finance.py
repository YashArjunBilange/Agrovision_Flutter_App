import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.db.base_class import Base
from app.db.session import engine
from main import app

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_test_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield


def get_auth_token_and_farm():
    reg_payload = {
        "full_name": "Balasaheb Patil",
        "phone": "9822114455",
        "password": "FarmPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Kolhapur",
        "taluka": "Karveer",
        "village": "Shiroli",
        "total_land_acres": 4.0,
    }
    reg_resp = client.post(f"{settings.API_V1_STR}/auth/register", json=reg_payload)
    token = reg_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    farm_payload = {
        "name": "Shiroli Maize Farm",
        "area_acres": 4.0,
        "soil_type": "Medium Black",
        "irrigation_type": "Drip",
        "is_active": True,
    }
    farm_resp = client.post(f"{settings.API_V1_STR}/farms", json=farm_payload, headers=headers)
    farm_id = farm_resp.json()["id"]

    return token, farm_id


def test_create_expense_transaction():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "farm_id": farm_id,
        "type": "expense",
        "category": "Fertilizers",
        "title": "DAP 18:46:00 2 Bags / २ गोणी डीएपी",
        "amount": 2700.0,
        "quantity": 2.0,
        "unit": "Bags",
        "rate_per_unit": 1350.0,
        "payment_method": "UPI",
    }
    res = client.post(f"{settings.API_V1_STR}/finance/transactions", json=payload, headers=headers)
    assert res.status_code == 201
    data = res.json()
    assert data["amount"] == 2700.0
    assert data["category"] == "Fertilizers"
    assert data["farm_id"] == farm_id


def test_create_income_transaction():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "farm_id": farm_id,
        "type": "income",
        "category": "Crop Harvest",
        "title": "Maize Grain Sale to APMC / मका धान्य विक्री",
        "amount": 65000.0,
        "quantity": 30.0,
        "unit": "Quintals",
        "rate_per_unit": 2166.6,
        "payment_method": "Bank Transfer",
    }
    res = client.post(f"{settings.API_V1_STR}/finance/transactions", json=payload, headers=headers)
    assert res.status_code == 201
    data = res.json()
    assert data["amount"] == 65000.0
    assert data["type"] == "income"


def test_finance_summary_and_reports():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    # Add Expense 1 (Seeds)
    client.post(
        f"{settings.API_V1_STR}/finance/transactions",
        json={"farm_id": farm_id, "type": "expense", "category": "Seeds", "title": "Pioneer Hybrid Seed", "amount": 3500.0},
        headers=headers,
    )
    # Add Expense 2 (Pesticides)
    client.post(
        f"{settings.API_V1_STR}/finance/transactions",
        json={"farm_id": farm_id, "type": "expense", "category": "Pesticides", "title": "Coragen FAW Spray", "amount": 1800.0},
        headers=headers,
    )
    # Add Income (Harvest)
    client.post(
        f"{settings.API_V1_STR}/finance/transactions",
        json={"farm_id": farm_id, "type": "income", "category": "Crop Harvest", "title": "Silage Fodder Sale", "amount": 25000.0},
        headers=headers,
    )

    # Test summary
    sum_res = client.get(f"{settings.API_V1_STR}/finance/summary?farm_id={farm_id}", headers=headers)
    assert sum_res.status_code == 200
    summary = sum_res.json()
    assert summary["total_income"] == 25000.0
    assert summary["total_expense"] == 5300.0
    assert summary["net_profit"] == 19700.0
    assert len(summary["expense_breakdown"]) == 2

    # Test economics report
    eco_res = client.get(f"{settings.API_V1_STR}/finance/economics-report?farm_id={farm_id}", headers=headers)
    assert eco_res.status_code == 200
    report = eco_res.json()
    assert report["area_acres"] == 4.0
    assert report["cost_per_acre"] == 5300.0 / 4.0
    assert report["profit_per_acre"] == 19700.0 / 4.0
    assert report["roi_percent"] > 300.0


def test_delete_transaction():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    create_res = client.post(
        f"{settings.API_V1_STR}/finance/transactions",
        json={"farm_id": farm_id, "type": "expense", "category": "Labor", "title": "Weeding Labor", "amount": 1200.0},
        headers=headers,
    )
    txn_id = create_res.json()["id"]

    del_res = client.delete(f"{settings.API_V1_STR}/finance/transactions/{txn_id}", headers=headers)
    assert del_res.status_code == 204

    # Verify not found
    get_res = client.get(f"{settings.API_V1_STR}/finance/transactions/{txn_id}", headers=headers)
    assert get_res.status_code == 404
