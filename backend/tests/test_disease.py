from io import BytesIO
import pytest
from fastapi.testclient import TestClient
from PIL import Image

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


def create_dummy_image_bytes() -> bytes:
    img = Image.new("RGB", (224, 224), color=(34, 139, 34))
    buf = BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


def get_auth_token():
    register_payload = {
        "full_name": "Ramesh Patil",
        "phone": "9876543210",
        "password": "FarmerPassword123",
        "preferred_language": "mr",
        "state": "Maharashtra",
        "district": "Pune",
        "taluka": "Baramati",
        "village": "Malegaon",
        "total_land_acres": 4.5,
    }
    resp = client.post(f"{settings.API_V1_STR}/auth/register", json=register_payload)
    assert resp.status_code == 201, resp.text
    return resp.json()["access_token"]


def test_disease_catalog():
    res = client.get(f"{settings.API_V1_STR}/disease/catalog?language=mr")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert len(data) > 0
    assert any("corn" in item["key"] for item in data)


def test_disease_remedy_lookup():
    res = client.get(f"{settings.API_V1_STR}/disease/remedies/corn_common_rust?language=mr")
    assert res.status_code == 200
    data = res.json()
    assert data["key"] == "corn_common_rust"
    assert "तांबेरा" in data["name"]
    assert len(data["chemical_treatment"]) > 0
    assert len(data["biological_treatment"]) > 0


def test_diagnose_endpoint_with_valid_image():
    token = get_auth_token()
    img_bytes = create_dummy_image_bytes()
    files = {"file": ("test_leaf.jpg", img_bytes, "image/jpeg")}
    data = {"language": "mr"}
    headers = {"Authorization": f"Bearer {token}"}

    res = client.post(
        f"{settings.API_V1_STR}/disease/diagnose",
        files=files,
        data=data,
        headers=headers,
    )
    assert res.status_code == 200
    result = res.json()
    assert result["success"] is True
    assert "class_name" in result
    assert "confidence" in result
    assert "diagnosis" in result
    assert result["scan_id"] is not None


def test_scan_history_endpoint():
    token = get_auth_token()
    headers = {"Authorization": f"Bearer {token}"}

    # Perform a scan first
    img_bytes = create_dummy_image_bytes()
    files = {"file": ("maize_leaf.jpg", img_bytes, "image/jpeg")}
    client.post(
        f"{settings.API_V1_STR}/disease/diagnose",
        files=files,
        data={"language": "mr"},
        headers=headers,
    )

    # Fetch history
    res = client.get(f"{settings.API_V1_STR}/disease/history", headers=headers)
    assert res.status_code == 200
    history = res.json()
    assert len(history) >= 1
    assert history[0]["image_filename"] == "maize_leaf.jpg"
