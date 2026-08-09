import sqlite3

def run_migration():
    conn = sqlite3.connect('agrovision.db')
    cursor = conn.cursor()

    columns_to_add = [
        ("polygon_geojson", "TEXT"),
        ("area_sqm", "FLOAT"),
        ("area_hectares", "FLOAT"),
        ("perimeter_meters", "FLOAT"),
        ("length_meters", "FLOAT"),
        ("width_meters", "FLOAT")
    ]

    for col_name, col_type in columns_to_add:
        try:
            cursor.execute(f"ALTER TABLE farms ADD COLUMN {col_name} {col_type};")
            print(f"Added column {col_name}")
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e):
                print(f"Column {col_name} already exists.")
            else:
                print(f"Error adding {col_name}: {e}")

    conn.commit()
    conn.close()

if __name__ == "__main__":
    run_migration()
