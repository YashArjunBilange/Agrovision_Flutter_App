import os
import pytest
from fastapi.testclient import TestClient

from main import app
from app.db.base_class import Base
from app.db.session import engine, init_db

client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_test_db():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


def test_farmer_registration_and_login():
    # 1. Register a new farmer
    reg_payload = {
        "full_name": "Ramesh Patil",
        "phone": "9876543210",
        "email": "ramesh@example.com",
        "password": "securepassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Pune",
        "taluka": "Baramati",
        "village": "Malegaon",
        "total_land_acres": 5.5,
    }
    response = client.post("/api/v1/auth/register", json=reg_payload)
    assert response.status_code == 201, response.text
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
    assert data["user"]["full_name"] == "Ramesh Patil"
    assert data["user"]["profile"]["district"] == "Pune"
    assert data["user"]["profile"]["preferred_language"] == "mr"

    access_token = data["access_token"]
    refresh_token = data["refresh_token"]

    # 2. Login with phone
    login_payload = {
        "identifier": "9876543210",
        "password": "securepassword123",
    }
    login_resp = client.post("/api/v1/auth/login", json=login_payload)
    assert login_resp.status_code == 200
    assert login_resp.json()["user"]["phone"] == "9876543210"

    # 3. Get /me
    me_resp = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert me_resp.status_code == 200
    assert me_resp.json()["full_name"] == "Ramesh Patil"

    # 4. Refresh token
    refresh_resp = client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh_token},
    )
    assert refresh_resp.status_code == 200
    new_access_token = refresh_resp.json()["access_token"]
    assert new_access_token is not None

    # 5. Update farmer profile
    update_resp = client.put(
        "/api/v1/auth/me/profile",
        json={"soil_type": "Black Cotton", "irrigation_type": "Drip"},
        headers={"Authorization": f"Bearer {new_access_token}"},
    )
    assert update_resp.status_code == 200
    assert update_resp.json()["profile"]["soil_type"] == "Black Cotton"
    assert update_resp.json()["profile"]["irrigation_type"] == "Drip"
