from app.db.session import engine
from app.db.base_class import Base
from app.models.satellite import SatelliteObservation

def migrate_satellite():
    print("Creating satellite_observations table if not exists...")
    Base.metadata.create_all(bind=engine, tables=[SatelliteObservation.__table__])
    print("Done!")

if __name__ == "__main__":
    migrate_satellite()
