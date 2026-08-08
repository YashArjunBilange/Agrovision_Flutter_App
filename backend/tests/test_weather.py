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
        "full_name": "Kishor Patil",
        "phone": "9766554433",
        "password": "FarmPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Aurangabad",
        "taluka": "Gangapur",
        "village": "Bhenda",
        "total_land_acres": 4.0,
    }
    reg_resp = client.post(f"{settings.API_V1_STR}/auth/register", json=reg_payload)
    token = reg_resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    farm_payload = {
        "name": "Gangapur Maize Plot / गंगापूर शेत",
        "area_acres": 4.0,
        "crop_type": "Maize",
        "soil_type": "Medium Black / मध्यम काळी",
        "irrigation_type": "Drip Irrigation / ठिबक",
        "latitude": 19.6983,
        "longitude": 75.0117,
        "is_active": True,
    }
    farm_resp = client.post(f"{settings.API_V1_STR}/farms", json=farm_payload, headers=headers)
    farm_id = farm_resp.json()["id"]

    return token, farm_id


def test_get_weather_coordinates():
    res = client.get(f"{settings.API_V1_STR}/weather?latitude=19.8762&longitude=75.3433")
    assert res.status_code == 200
    data = res.json()
    assert "current" in data
    assert "temperature" in data["current"]
    assert "spray_advisory" in data
    assert len(data["hourly_forecast"]) > 0
    assert len(data["daily_forecast"]) > 0


def test_spray_advisory_logic():
    # Ideal condition: 25C, 8 km/h wind, 0% rain
    ideal_res = client.get(f"{settings.API_V1_STR}/weather/spray-advisory?temp=25.0&wind_speed=8.0&rain_prob=0&precipitation=0.0")
    assert ideal_res.status_code == 200
    ideal_data = ideal_res.json()
    assert ideal_data["status"] == "ideal"
    assert ideal_data["score"] >= 75

    # Unfavorable condition: High wind (24 km/h) & Rain
    bad_res = client.get(f"{settings.API_V1_STR}/weather/spray-advisory?temp=36.0&wind_speed=24.0&rain_prob=80&precipitation=2.5")
    assert bad_res.status_code == 200
    bad_data = bad_res.json()
    assert bad_data["status"] == "unfavorable"
    assert bad_data["score"] < 45


def test_get_weather_for_farm():
    token, farm_id = get_auth_token_and_farm()
    headers = {"Authorization": f"Bearer {token}"}

    res = client.get(f"{settings.API_V1_STR}/weather/farm/{farm_id}", headers=headers)
    assert res.status_code == 200
    data = res.json()
    assert data["farm_id"] == farm_id
    assert "Gangapur" in data["farm_name"]
    assert data["current"]["temperature"] is not None
