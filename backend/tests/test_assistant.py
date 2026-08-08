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
        "full_name": "Suresh Shinde",
        "phone": "9855443322",
        "password": "FarmPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Pune",
        "taluka": "Shirur",
        "village": "Nhavare",
        "total_land_acres": 3.0,
    }
    reg_resp = client.post(f"{settings.API_V1_STR}/auth/register", json=reg_payload)
    token = reg_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    farm_payload = {
        "name": "Shirur Farm / शिरूर शेत",
        "area_acres": 3.0,
        "soil_type": "Medium Black",
        "irrigation_type": "Drip",
        "is_active": True,
    }
    farm_resp = client.post(f"{settings.API_V1_STR}/farms", json=farm_payload, headers=headers)
    farm_id = farm_resp.json()["id"]

    return token, farm_id


def test_get_quick_prompts():
    res = client.get(f"{settings.API_V1_STR}/assistant/quick-prompts")
    assert res.status_code == 200
    prompts = res.json()
    assert len(prompts) >= 4
    assert "लष्करी" in prompts[0]["title_mr"]


def test_chat_faw_query():
    token, _ = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "message": "मक्यावरील लष्करी अळीवर कोणते औषध फवारावे?",
        "language": "mr",
    }
    res = client.post(f"{settings.API_V1_STR}/assistant/chat", json=payload, headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert "reply" in data
    assert "इमामेक्टिन" in data["reply"] or "कोराजन" in data["reply"]
    assert len(data["suggestions"]) > 0


def test_chat_with_farm_context():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    payload = {
        "message": "What is the fertilizer schedule?",
        "language": "en",
        "farm_id": farm_id,
    }
    res = client.post(f"{settings.API_V1_STR}/assistant/chat", json=payload, headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["context_used"] is True
    assert "DAP" in data["reply"] or "Urea" in data["reply"]
