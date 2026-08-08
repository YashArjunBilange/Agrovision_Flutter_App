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
        "full_name": "Ramesh Jadhav",
        "phone": "9922334455",
        "password": "FarmPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Solapur",
        "taluka": "Pandharpur",
        "village": "Kasegaon",
        "total_land_acres": 5.0,
    }
    reg_resp = client.post(f"{settings.API_V1_STR}/auth/register", json=reg_payload)
    token = reg_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    farm_payload = {
        "name": "Pandharpur Plot / पंढरपूर शेत",
        "area_acres": 5.0,
        "soil_type": "Medium Black",
        "irrigation_type": "Drip",
        "is_active": True,
    }
    farm_resp = client.post(f"{settings.API_V1_STR}/farms", json=farm_payload, headers=headers)
    farm_id = farm_resp.json()["id"]

    return token, farm_id


def test_get_supported_crops():
    res = client.get(f"{settings.API_V1_STR}/recommendations/supported")
    assert res.status_code == 200
    crops = res.json()
    assert len(crops) >= 6
    assert any(c["crop_id"] == "maize" for c in crops)


def test_recommend_kharif_maize():
    token, _ = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "nitrogen": 100.0,
        "phosphorus": 50.0,
        "potassium": 40.0,
        "ph": 6.8,
        "temperature": 28.0,
        "rainfall": 750.0,
        "season": "Kharif",
        "soil_type": "Medium Black",
        "irrigation_available": True,
    }
    res = client.post(f"{settings.API_V1_STR}/recommendations/recommend", json=payload, headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert len(data["recommendations"]) > 0
    top_crop = data["recommendations"][0]
    assert top_crop["crop_id"] == "maize"
    assert top_crop["match_score"] >= 85.0
    assert "₹" in top_crop["profit_potential_per_acre"]


def test_recommend_rabi_season():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "nitrogen": 30.0,
        "phosphorus": 50.0,
        "potassium": 30.0,
        "ph": 7.0,
        "temperature": 20.0,
        "rainfall": 450.0,
        "season": "Rabi",
        "soil_type": "Medium Black",
        "irrigation_available": True,
        "farm_id": farm_id,
    }
    res = client.post(f"{settings.API_V1_STR}/recommendations/recommend", json=payload, headers=headers)
    assert res.status_code == 200
    data = res.json()
    top_crops = [c["crop_id"] for c in data["recommendations"][:3]]
    assert "gram" in top_crops or "wheat" in top_crops or "maize" in top_crops
