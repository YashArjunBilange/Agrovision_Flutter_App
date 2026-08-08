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


def get_authenticated_headers():
    reg_payload = {
        "full_name": "Kisan Rao",
        "phone": "9123456780",
        "email": "kisan@example.com",
        "password": "farmpassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Solapur",
        "taluka": "Pandharpur",
        "village": "Kasegaon",
        "total_land_acres": 4.0,
    }
    resp = client.post("/api/v1/auth/register", json=reg_payload)
    assert resp.status_code == 201, resp.text
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def test_farm_crud_and_active_switch():
    headers = get_authenticated_headers()

    # 1. Create first farm (should auto-become primary)
    farm1_payload = {
        "name": "Gat No. 42 / शेत १",
        "area_acres": 2.5,
        "latitude": 17.6599,
        "longitude": 75.3256,
        "state": "Maharashtra",
        "district": "Solapur",
        "taluka": "Pandharpur",
        "village": "Kasegaon",
        "soil_type": "Black Cotton",
        "soil_ph": 7.2,
        "soil_organic_carbon": 0.62,
        "irrigation_type": "Drip",
        "water_source": "Well",
        "notes": "Main plot for Maize hybrid pioneer",
    }
    resp1 = client.post("/api/v1/farms", json=farm1_payload, headers=headers)
    assert resp1.status_code == 201, resp1.text
    farm1_data = resp1.json()
    assert farm1_data["name"] == "Gat No. 42 / शेत १"
    assert farm1_data["is_primary"] is True
    farm1_id = farm1_data["id"]

    # 2. Create second farm (should be is_primary=False by default)
    farm2_payload = {
        "name": "River Plot / नदीकाठचे शेत",
        "area_acres": 1.5,
        "latitude": 17.6610,
        "longitude": 75.3300,
        "state": "Maharashtra",
        "district": "Solapur",
        "taluka": "Pandharpur",
        "village": "Kasegaon",
        "soil_type": "Alluvial",
        "irrigation_type": "Flood",
        "water_source": "River",
    }
    resp2 = client.post("/api/v1/farms", json=farm2_payload, headers=headers)
    assert resp2.status_code == 201
    farm2_data = resp2.json()
    assert farm2_data["is_primary"] is False
    farm2_id = farm2_data["id"]

    # 3. List farms
    list_resp = client.get("/api/v1/farms", headers=headers)
    assert list_resp.status_code == 200
    farms_list = list_resp.json()
    assert len(farms_list) == 2
    assert farms_list[0]["id"] == farm1_id  # Primary first

    # 4. Update second farm
    update_resp = client.put(
        f"/api/v1/farms/{farm2_id}",
        json={"notes": "Prepared for rabi maize crop"},
        headers=headers,
    )
    assert update_resp.status_code == 200
    assert update_resp.json()["notes"] == "Prepared for rabi maize crop"

    # 5. Set second farm as active / primary
    active_resp = client.post(f"/api/v1/farms/{farm2_id}/set-active", headers=headers)
    assert active_resp.status_code == 200
    assert active_resp.json()["is_primary"] is True

    # Verify first farm is no longer primary
    get_farm1 = client.get(f"/api/v1/farms/{farm1_id}", headers=headers)
    assert get_farm1.json()["is_primary"] is False

    # 6. Delete farm
    del_resp = client.delete(f"/api/v1/farms/{farm1_id}", headers=headers)
    assert del_resp.status_code == 204

    # Verify 1 farm remaining
    list_resp2 = client.get("/api/v1/farms", headers=headers)
    assert len(list_resp2.json()) == 1
