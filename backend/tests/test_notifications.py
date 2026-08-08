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


def get_auth_token():
    reg_payload = {
        "full_name": "Sambhaji Raje",
        "phone": "9822998877",
        "password": "FarmPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Kolhapur",
        "taluka": "Karveer",
        "village": "Shiroli",
        "total_land_acres": 5.0,
    }
    reg_resp = client.post(f"{settings.API_V1_STR}/auth/register", json=reg_payload)
    return reg_resp.json()["access_token"]


def test_get_farm_alerts():
    token = get_auth_token()
    headers = {"Authorization": f"Bearer {token}"}

    res = client.get(f"{settings.API_V1_STR}/notifications/alerts", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert "alerts" in data
    assert len(data["alerts"]) >= 3
    assert data["unread_count"] >= 3
    # Verify presence of disease / FAW warning
    titles = [a["title_mr"] for a in data["alerts"]]
    assert any("लष्करी अळी" in t or "करपा" in t for t in titles)


def test_mark_alert_read():
    token = get_auth_token()
    headers = {"Authorization": f"Bearer {token}"}

    res = client.post(f"{settings.API_V1_STR}/notifications/alerts/1/read", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "ok"
    assert data["alert_id"] == 1
