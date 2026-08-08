import math
from typing import Any, Dict, List, Optional

STORES_DATABASE = [
    {
        "id": 1,
        "name_en": "Kisan Krishi Seva Kendra",
        "name_mr": "किसान कृषी सेवा केंद्र",
        "dealer_name": "Sanjay Jagtap",
        "license_no": "PUN/AGRI/2019/882",
        "phone": "+919822334455",
        "alternate_phone": "+919822334456",
        "address_en": "Main Market Yard, Near APMC Gate, Shirur, Pune",
        "address_mr": "मुख्य बाजारपेठ, एपीएमसी गेटजवळ, शिरूर, पुणे",
        "taluka": "Shirur",
        "district": "Pune",
        "pincode": "412210",
        "latitude": 18.8262,
        "longitude": 74.3779,
        "categories": ["Seeds", "Fertilizers", "Pesticides", "Bio-Fertilizers"],
        "rating": 4.8,
        "is_verified": True,
        "opening_hours": "08:00 AM - 08:30 PM",
    },
    {
        "id": 2,
        "name_en": "Baliraja Krishi Udyog & Seeds",
        "name_mr": "बळीराजा कृषी उद्योग व बियाणे",
        "dealer_name": "Mahesh Patil",
        "license_no": "PUN/AGRI/2021/304",
        "phone": "+919423112233",
        "alternate_phone": None,
        "address_en": "Station Road, Baramati, Pune",
        "address_mr": "स्टेशन रोड, बारामती, पुणे",
        "taluka": "Baramati",
        "district": "Pune",
        "pincode": "413102",
        "latitude": 18.1517,
        "longitude": 74.5770,
        "categories": ["Seeds", "Fertilizers", "Drip Equipment", "Pesticides"],
        "rating": 4.6,
        "is_verified": True,
        "opening_hours": "07:30 AM - 08:00 PM",
    },
    {
        "id": 3,
        "name_en": "Shree Ganesh Agri Inputs & Fertilisers",
        "name_mr": "श्री गणेश कृषी सेवा केंद्र",
        "dealer_name": "Vikas Shinde",
        "license_no": "SOL/AGRI/2018/119",
        "phone": "+919850123456",
        "alternate_phone": "+919850123457",
        "address_en": "Karkhana Road, Kasegaon, Pandharpur, Solapur",
        "address_mr": "कारखाना रोड, कासेगाव, पंढरपूर, सोलापूर",
        "taluka": "Pandharpur",
        "district": "Solapur",
        "pincode": "413304",
        "latitude": 17.6766,
        "longitude": 75.3218,
        "categories": ["Seeds", "Fertilizers", "Pesticides", "Sprayers"],
        "rating": 4.9,
        "is_verified": True,
        "opening_hours": "08:00 AM - 09:00 PM",
    },
    {
        "id": 4,
        "name_en": "Mahalaxmi Krishi Vikas Kendra",
        "name_mr": "महालक्ष्मी कृषी विकास केंद्र",
        "dealer_name": "Anandrao Desai",
        "license_no": "KOL/AGRI/2020/551",
        "phone": "+919890234567",
        "alternate_phone": None,
        "address_en": "Market Yard, Shiroli Pulachi, Karveer, Kolhapur",
        "address_mr": "मार्केट यार्ड, शिरोली पुलाची, करवीर, कोल्हापूर",
        "taluka": "Karveer",
        "district": "Kolhapur",
        "pincode": "416122",
        "latitude": 16.7450,
        "longitude": 74.2750,
        "categories": ["Fertilizers", "Pesticides", "Bio-Fertilizers", "Drip Equipment"],
        "rating": 4.7,
        "is_verified": True,
        "opening_hours": "08:00 AM - 08:00 PM",
    },
    {
        "id": 5,
        "name_en": "Godavari Agri Biotech & Seeds",
        "name_mr": "गोदावरी ॲग्री बायोटेक व बियाणे केंद्र",
        "dealer_name": "Pravin Kulkarni",
        "license_no": "NSK/AGRI/2022/902",
        "phone": "+919765432109",
        "alternate_phone": "+919765432110",
        "address_en": "Old Agra Road, Near Krishi Bhavan, Niphad, Nashik",
        "address_mr": "जुना आग्रा रोड, कृषी भवनजवळ, निफाड, नाशिक",
        "taluka": "Niphad",
        "district": "Nashik",
        "pincode": "422303",
        "latitude": 20.0847,
        "longitude": 74.1084,
        "categories": ["Seeds", "Pesticides", "Plant Growth Regulators", "Sprayers"],
        "rating": 4.8,
        "is_verified": True,
        "opening_hours": "08:00 AM - 08:30 PM",
    },
    {
        "id": 6,
        "name_en": "Jai Kisan Fertilizer & Pesticide Mall",
        "name_mr": "जय किसान खत व कीटकनाशक मॉल",
        "dealer_name": "Rameshwar More",
        "license_no": "AHM/AGRI/2017/412",
        "phone": "+919921876543",
        "alternate_phone": None,
        "address_en": "Nagar-Pune Highway, Supa, Parner, Ahmednagar",
        "address_mr": "नगर-पुणे महामार्ग, सुपा, पारनेर, अहमदनगर",
        "taluka": "Parner",
        "district": "Ahmednagar",
        "pincode": "414301",
        "latitude": 18.9667,
        "longitude": 74.5333,
        "categories": ["Seeds", "Fertilizers", "Pesticides", "Bio-Fertilizers", "Drip Equipment"],
        "rating": 4.5,
        "is_verified": True,
        "opening_hours": "07:00 AM - 09:00 PM",
    },
]


def calculate_haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculates distance between two coordinates in Kilometers."""
    r = 6371.0  # Earth's radius in km
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = math.sin(delta_phi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return round(r * c, 2)


class StoreService:
    @classmethod
    def get_nearby_stores(
        cls,
        user_lat: Optional[float] = None,
        user_lon: Optional[float] = None,
        district: Optional[str] = None,
        taluka: Optional[str] = None,
        category: Optional[str] = None,
        search_query: Optional[str] = None,
        max_radius_km: float = 100.0,
    ) -> List[Dict[str, Any]]:
        results = []

        for store in STORES_DATABASE:
            # Filter by district if provided
            if district and district.lower() not in store["district"].lower():
                continue

            # Filter by taluka if provided
            if taluka and taluka.lower() not in store["taluka"].lower():
                continue

            # Filter by category if provided
            if category and not any(category.lower() in c.lower() for c in store["categories"]):
                continue

            # Filter by search query if provided
            if search_query:
                q = search_query.lower()
                matches_name = q in store["name_en"].lower() or q in store["name_mr"].lower()
                matches_dealer = q in store["dealer_name"].lower()
                matches_address = q in store["address_en"].lower() or q in store["address_mr"].lower()
                if not (matches_name or matches_dealer or matches_address):
                    continue

            # Compute distance if lat/lon provided
            dist_km = None
            if user_lat is not None and user_lon is not None:
                dist_km = calculate_haversine_distance(user_lat, user_lon, store["latitude"], store["longitude"])
                if dist_km > max_radius_km and not (district or taluka):
                    continue

            store_copy = dict(store)
            store_copy["distance_km"] = dist_km
            results.append(store_copy)

        # If user coordinates available, sort by distance
        if user_lat is not None and user_lon is not None:
            results.sort(key=lambda x: x["distance_km"] if x["distance_km"] is not None else 9999.0)
        else:
            results.sort(key=lambda x: x["rating"], reverse=True)

        return results

    @classmethod
    def get_store_by_id(cls, store_id: int) -> Optional[Dict[str, Any]]:
        for store in STORES_DATABASE:
            if store["id"] == store_id:
                return store
        return None
