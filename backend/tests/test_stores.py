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


def test_list_all_stores():
    res = client.get(f"{settings.API_V1_STR}/stores")
    assert res.status_code == 200
    data = res.json()
    assert data["total_count"] >= 5
    assert len(data["stores"]) >= 5


def test_list_stores_with_coordinates_distance():
    # Coordinates of Shirur, Pune (18.8262, 74.3779)
    res = client.get(f"{settings.API_V1_STR}/stores?lat=18.8262&lon=74.3779")
    assert res.status_code == 200
    data = res.json()
    stores = data["stores"]
    assert len(stores) > 0
    # First store should be the Shirur store with distance ~0.0 km
    assert stores[0]["taluka"] == "Shirur"
    assert stores[0]["distance_km"] is not None
    assert stores[0]["distance_km"] < 5.0


def test_filter_stores_by_category():
    res = client.get(f"{settings.API_V1_STR}/stores?category=Drip Equipment")
    assert res.status_code == 200
    data = res.json()
    for s in data["stores"]:
        assert "Drip Equipment" in s["categories"]


def test_get_store_by_id():
    res = client.get(f"{settings.API_V1_STR}/stores/1")
    assert res.status_code == 200
    store = res.json()
    assert store["id"] == 1
    assert "किसान कृषी सेवा केंद्र" in store["name_mr"]
    assert store["phone"] == "+919822334455"
