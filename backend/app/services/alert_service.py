from datetime import date, datetime
from typing import Any, Dict, List, Optional
from sqlalchemy.orm import Session

from app.models.crop_cycle import CropCycle
from app.models.farm import Farm
from app.models.user import User
from app.services.crop_lifecycle_knowledge import get_current_stage


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
        
        if not db:
            return alerts
            
        # 1. Fetch Active Crop Cycle
        query = db.query(CropCycle).filter(CropCycle.user_id == user.id, CropCycle.status == "active")
        if farm_id:
            query = query.filter(CropCycle.farm_id == farm_id)
        else:
            primary_farm = db.query(Farm).filter(Farm.user_id == user.id, Farm.is_active == True).first()
            if primary_farm:
                query = query.filter(CropCycle.farm_id == primary_farm.id)
                
        active_cycle = query.order_by(CropCycle.id.desc()).first()
        
        # Base Alerts (Always applicable)
        alerts.append({
            "id": 1,
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
        
        if not active_cycle:
            return alerts
            
        # Calculate Current Stage
        days_since_sowing = max(0, (date.today() - active_cycle.sowing_date).days)
        current_stage = get_current_stage(days_since_sowing)
        
        # 2. Stage-Aware Irrigation Alert
        irrigation_en = current_stage.get("irrigation_advice_en")
        irrigation_mr = current_stage.get("irrigation_advice_mr")
        water_sens = current_stage.get("water_sensitivity", "Low")
        
        if irrigation_en and water_sens in ["Critical", "High"]:
            alerts.append({
                "id": len(alerts) + 1,
                "title_en": f"Critical Irrigation Needed ({current_stage['name_en'].split(' -')[0]}) 💧",
                "title_mr": f"महत्त्वाचे पाणी नियोजन ({current_stage['name_mr'].split(' -')[0]}) 💧",
                "message_en": irrigation_en,
                "message_mr": irrigation_mr,
                "type": "weather",
                "severity": "high" if water_sens == "Critical" else "medium",
                "action_route": "/more/lifecycle",
                "is_read": False,
                "created_at": now_str,
            })
            
        # 3. Stage-Aware Pest & Disease Watch
        pest_watch = current_stage.get("pest_disease_watch", [])
        for idx, pest in enumerate(pest_watch):
            alerts.append({
                "id": len(alerts) + 1,
                "title_en": f"Pest Watch: {pest['threat_en']} 🐛",
                "title_mr": f"कीड सावधगिरी: {pest['threat_mr']} 🐛",
                "message_en": pest['action_en'],
                "message_mr": pest['action_mr'],
                "type": "advisory",
                "severity": "high",
                "action_route": "/scan",
                "is_read": False,
                "created_at": now_str,
            })
            
        # 4. Stage-Aware NPK Recommendation
        npk = current_stage.get("npk_recommendation")
        if npk:
            alerts.append({
                "id": len(alerts) + 1,
                "title_en": f"Fertilizer: {npk['title_en']} 🌱",
                "title_mr": f"खत मात्रा: {npk['title_mr']} 🌱",
                "message_en": npk['instruction_en'],
                "message_mr": npk['instruction_mr'],
                "type": "task",
                "severity": "medium",
                "action_route": "/more/lifecycle",
                "is_read": False,
                "created_at": now_str,
            })
            
        return alerts
