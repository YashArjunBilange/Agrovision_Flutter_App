from datetime import datetime
from typing import Any, Dict, List, Optional
from sqlalchemy.orm import Session

from app.models.crop_cycle import CropCycle, CropTask
from app.models.farm import Farm
from app.models.user import User


class AlertService:
    @classmethod
    def generate_alerts_for_user(
        cls,
        user: User,
        farm_id: Optional[int] = None,
        db: Optional[Session] = None,
    ) -> List[Dict[str, Any]]:
        alerts = []
        now_str = datetime.utcnow().isoformat()

        # 1. Weather & High Humidity Fungal Alert
        alerts.append({
            "id": 1,
            "title_en": "Fungal Blight Risk Warning 🍄",
            "title_mr": "करपा रोगाचा संभाव्य इशारा 🍄",
            "message_en": "Cloudy weather and high humidity (>80%) favor Northern Corn Leaf Blight. Check lower leaves for cigar-shaped lesions.",
            "message_mr": "ढगाळ हवामान व जास्त आर्द्रतेमुळे मका पिकावर करपा रोगाचा प्रादुर्भाव संभवतो. पानांची पाहणी करून मँकोझेब किंवा अझॉक्सीस्ट्रोबिन फवारणीची पूर्वतयारी ठेवा.",
            "type": "weather",
            "severity": "high",
            "action_route": "/more/weather",
            "is_read": False,
            "created_at": now_str,
        })

        # 2. FAW Pest Surveillance Advisory
        alerts.append({
            "id": 2,
            "title_en": "Fall Armyworm (FAW) Vigilance 🐛",
            "title_mr": "लष्करी अळी (FAW) सावधगिरी सल्ला 🐛",
            "message_en": "Maize vegetative whorl stage is highly vulnerable to FAW larvae. Look for pinholes and sawdust-like frass.",
            "message_mr": "मका पोंग्यात बारीक छिद्रे किंवा भुसा दिसल्यास तात्काळ कोराजेन (०.४ मिली/लीटर) किंवा इमामेक्टिन बेन्झोएट (०.५ ग्रॅ/लीटर) फवारणी करा.",
            "type": "advisory",
            "severity": "high",
            "action_route": "/scan",
            "is_read": False,
            "created_at": now_str,
        })

        # 3. Fertilizer Top-Dressing Reminder
        alerts.append({
            "id": 3,
            "title_en": "Nitrogen Top-Dressing Reminder 🌱",
            "title_mr": "युरिया खताची दुसरी मात्रा (Top Dressing) 🌱",
            "message_en": "At 30-35 days after sowing (V6-V8 stage), apply second split dose of Urea (50 kg/acre) before irrigation.",
            "message_mr": "पेरणीनंतर ३०-३५ दिवसांनी मक्याला युरिया ५० किलो प्रति एकर या प्रमाणात मातीची ओल असताना द्या.",
            "type": "task",
            "severity": "medium",
            "action_route": "/more/lifecycle",
            "is_read": False,
            "created_at": now_str,
        })

        # 4. Agri Store Stock & Input Support
        alerts.append({
            "id": 4,
            "title_en": "Fertilizer & Pesticide Availability 🏪",
            "title_mr": "कृषी सेवा केंद्र खत उपलब्ध माहिती 🏪",
            "message_en": "Find verified Krishi Seva Kendras near your farm for authorized seeds, fertilizers, and sprays.",
            "message_mr": "तुमच्या तालुक्यातील शासकीय परवानाधारक कृषी सेवा केंद्रांची यादी व संपर्क क्रमांक तपासा.",
            "type": "advisory",
            "severity": "low",
            "action_route": "/more/stores",
            "is_read": False,
            "created_at": now_str,
        })

        return alerts
