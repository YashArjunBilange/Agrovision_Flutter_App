from datetime import date, timedelta
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


def get_auth_token_and_farm_id():
    reg_payload = {
        "full_name": "Balasaheb Thorat",
        "phone": "9822334455",
        "password": "FarmPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Nashik",
        "taluka": "Yeola",
        "village": "Mukhed",
        "total_land_acres": 5.0,
    }
    reg_resp = client.post(f"{settings.API_V1_STR}/auth/register", json=reg_payload)
    token = reg_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    farm_payload = {
        "name": "Plot A / मका शिवार",
        "area_acres": 3.0,
        "crop_type": "Maize",
        "soil_type": "Medium Black / मध्यम काळी",
        "irrigation_type": "Drip Irrigation / ठिबक सिंचन",
        "is_active": True,
    }
    farm_resp = client.post(f"{settings.API_V1_STR}/farms", json=farm_payload, headers=headers)
    farm_id = farm_resp.json()["id"]

    return token, farm_id


def test_get_stages_catalog():
    res = client.get(f"{settings.API_V1_STR}/crops/stages")
    assert res.status_code == 200
    stages = res.json()
    assert len(stages) == 6
    assert stages[0]["stage_id"] == "sowing_germination"
    assert "पेरणी" in stages[0]["name_mr"]


def test_calculate_fertilizer():
    payload = {
        "stage_id": "knee_high_vegetative",
        "acreage": 2.0,
    }
    res = client.post(f"{settings.API_V1_STR}/crops/calculate-fertilizer", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["acreage"] == 2.0
    assert "Urea" in data["fertilizers_kg"]
    # 45 kg * 2 = 90.0 kg Urea
    assert data["fertilizers_kg"]["Urea"] == 90.0


def test_crop_cycle_create_active_and_task_toggle():
    token, farm_id = get_auth_token_and_farm_id()
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Create a crop cycle sown 20 days ago (Knee-high stage)
    sowing = (date.today() - timedelta(days=20)).isoformat()
    cycle_payload = {
        "farm_id": farm_id,
        "crop_name": "Maize",
        "variety_name": "Pioneer 3396",
        "season": "Kharif",
        "sowing_date": sowing,
    }
    create_res = client.post(f"{settings.API_V1_STR}/crops", json=cycle_payload, headers=headers)
    assert create_res.status_code == 201
    cycle_data = create_res.json()
    assert cycle_data["farm_id"] == farm_id
    assert cycle_data["days_since_sowing"] == 20
    assert cycle_data["current_stage"]["stage_id"] == "knee_high_vegetative"
    assert len(cycle_data["tasks"]) > 0

    first_task = cycle_data["tasks"][0]
    task_id = first_task["id"]
    assert first_task["is_completed"] is False

    # 2. Get active crop cycle
    active_res = client.get(f"{settings.API_V1_STR}/crops/active", headers=headers)
    assert active_res.status_code == 200
    active_data = active_res.json()
    assert active_data["id"] == cycle_data["id"]

    # 3. Toggle task completion
    toggle_res = client.put(f"{settings.API_V1_STR}/crops/tasks/{task_id}/toggle", headers=headers)
    assert toggle_res.status_code == 200
    assert toggle_res.json()["is_completed"] is True
