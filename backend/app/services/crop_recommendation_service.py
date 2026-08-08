import math
from typing import Any, Dict, List, Optional

CROPS_DATABASE = [
    {
        "crop_id": "maize",
        "name_en": "Maize (Corn)",
        "name_mr": "मका (Corn)",
        "category": "Cereals / धान्य",
        "optimal_n": 100,
        "optimal_p": 50,
        "optimal_k": 40,
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.5,
        "optimal_temp_min": 18,
        "optimal_temp_max": 34,
        "optimal_rainfall_min": 500,
        "optimal_rainfall_max": 900,
        "suitable_seasons": ["Kharif", "Rabi", "Summer"],
        "suitable_soils": ["Medium Black", "Black Cotton", "Loam", "Clay Loam", "Alluvial"],
        "duration_days": "100-115 days / दिवस",
        "estimated_yield_per_acre": "25 - 35 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹35,000 - ₹55,000",
        "description_en": "Excellent dual-purpose crop for grain and silage. Fast cash cycle with steady market demand.",
        "description_mr": "धान्य आणि जनावरांच्या चाऱ्यासाठी उत्कृष्ट पीक. कमी कालावधीत खात्रीशीर उत्पादन देणारे पीक.",
        "advantages_en": ["High yield potential", "Works well in Kharif and Rabi", "Low risk with hybrid varieties"],
        "advantages_mr": ["भरघोस उत्पादन क्षमता", "खरीप व रब्बी दोन्ही हंगामात योग्य", "चांगल्या संकरित वाणांमुळे कमी धोका"],
    },
    {
        "crop_id": "soybean",
        "name_en": "Soybean",
        "name_mr": "सोयाबीन",
        "category": "Oilseeds / गळीत धान्य",
        "optimal_n": 30,
        "optimal_p": 60,
        "optimal_k": 40,
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.5,
        "optimal_temp_min": 20,
        "optimal_temp_max": 32,
        "optimal_rainfall_min": 600,
        "optimal_rainfall_max": 1000,
        "suitable_seasons": ["Kharif"],
        "suitable_soils": ["Medium Black", "Black Cotton", "Loam"],
        "duration_days": "90-105 days / दिवस",
        "estimated_yield_per_acre": "10 - 14 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹30,000 - ₹45,000",
        "description_en": "Major oilseed crop enriching soil with atmospheric nitrogen fixation.",
        "description_mr": "जमिनीत नत्र स्थिरीकरण करून सुपीकता वाढवणारे प्रमुख खरीप तेलबिया पीक.",
        "advantages_en": ["Fixes nitrogen in soil", "Short duration", "Ideal predecessor for Rabi Wheat/Gram"],
        "advantages_mr": ["जमिनीची सुपीकता वाढवते", "कमी कालावधी", "रब्बी हरभरा किंवा गव्हासाठी उत्तम पूर्वपीक"],
    },
    {
        "crop_id": "gram",
        "name_en": "Gram / Chickpea (Harbara)",
        "name_mr": "हरभरा (चना)",
        "category": "Pulses / कडधान्य",
        "optimal_n": 25,
        "optimal_p": 50,
        "optimal_k": 25,
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 8.0,
        "optimal_temp_min": 14,
        "optimal_temp_max": 28,
        "optimal_rainfall_min": 350,
        "optimal_rainfall_max": 650,
        "suitable_seasons": ["Rabi"],
        "suitable_soils": ["Medium Black", "Black Cotton", "Clay", "Loam"],
        "duration_days": "95-110 days / दिवस",
        "estimated_yield_per_acre": "8 - 12 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹28,000 - ₹42,000",
        "description_en": "Leading pulse crop for Rabi season requiring low water and residual moisture.",
        "description_mr": "कमी पाण्यावर आणि जमिनीतील ओलाव्यावर येणारे रब्बी हंगामातील सर्वोत्तम कडधान्य पीक.",
        "advantages_en": ["Requires less water", "Good market support price (MSP)", "Enriches soil fertility"],
        "advantages_mr": ["कमी पाण्यावर येते", "शासकीय हमीभाव (MSP)", "जमिनीची सुपीकता वाढवते"],
    },
    {
        "crop_id": "cotton",
        "name_en": "Cotton (Kapus)",
        "name_mr": "कापूस (सफेद सोने)",
        "category": "Commercial / नगदी पीक",
        "optimal_n": 120,
        "optimal_p": 60,
        "optimal_k": 60,
        "optimal_ph_min": 6.5,
        "optimal_ph_max": 8.2,
        "optimal_temp_min": 22,
        "optimal_temp_max": 38,
        "optimal_rainfall_min": 500,
        "optimal_rainfall_max": 1100,
        "suitable_seasons": ["Kharif"],
        "suitable_soils": ["Black Cotton", "Medium Black", "Deep Black"],
        "duration_days": "150-180 days / दिवस",
        "estimated_yield_per_acre": "10 - 15 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹45,000 - ₹75,000",
        "description_en": "High-value commercial crop well-suited for deep black cotton soils with good drainage.",
        "description_mr": "काळ्या कसदार जमिनीसाठी उत्तम नगदी पीक. योग्य व्यवस्थापनाने चांगला नफा मिळतो.",
        "advantages_en": ["High market value", "Deep taproot system", "Multiple picking flushes"],
        "advantages_mr": ["उच्च बाजारमूल्य", "खोल जाणारी मुळे", "अनेक तोडण्यांमधून उत्पन्न"],
    },
    {
        "crop_id": "wheat",
        "name_en": "Wheat (Gahu)",
        "name_mr": "गहू",
        "category": "Cereals / धान्य",
        "optimal_n": 100,
        "optimal_p": 50,
        "optimal_k": 40,
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.5,
        "optimal_temp_min": 12,
        "optimal_temp_max": 25,
        "optimal_rainfall_min": 400,
        "optimal_rainfall_max": 750,
        "suitable_seasons": ["Rabi"],
        "suitable_soils": ["Medium Black", "Loam", "Clay Loam", "Alluvial"],
        "duration_days": "110-125 days / दिवस",
        "estimated_yield_per_acre": "18 - 24 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹30,000 - ₹48,000",
        "description_en": "Staple winter cereal crop requiring cool weather during vegetative and grain filling stages.",
        "description_mr": "थंड हवामानात उत्तम येणारे रब्बी धान्य पीक. खात्रीशीर घरगुती व व्यापारी उत्पन्न.",
        "advantages_en": ["Assured market demand", "Excellent straw fodder for cattle", "Stable yield"],
        "advantages_mr": ["खात्रीशीर मागणी", "जनावरांसाठी चांगला भुसा/चारा", "स्थिर उत्पादन"],
    },
    {
        "crop_id": "onion",
        "name_en": "Onion (Kanda)",
        "name_mr": "कांदा",
        "category": "Horticulture / भाजीपाला",
        "optimal_n": 80,
        "optimal_p": 50,
        "optimal_k": 60,
        "optimal_ph_min": 6.0,
        "optimal_ph_max": 7.2,
        "optimal_temp_min": 15,
        "optimal_temp_max": 30,
        "optimal_rainfall_min": 400,
        "optimal_rainfall_max": 750,
        "suitable_seasons": ["Kharif", "Rabi", "Summer"],
        "suitable_soils": ["Medium Black", "Sandy Loam", "Loam"],
        "duration_days": "110-130 days / दिवस",
        "estimated_yield_per_acre": "100 - 150 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹50,000 - ₹1,20,000",
        "description_en": "High return horticultural cash crop requiring well-drained loamy soil.",
        "description_mr": "योग्य बाजारभाव मिळाल्यास प्रचंड नफा देणारे नगदी भाजीपाला पीक.",
        "advantages_en": ["Exceptional profit potential", "Storage capacity (Rabi onion)", "Year-round demand"],
        "advantages_mr": ["भरघोस नफ्याची संधी", "चांगली साठवणूक क्षमता (रब्बी कांदा)", "वर्षभर सतत मागणी"],
    },
    {
        "crop_id": "bajra",
        "name_en": "Pearl Millet (Bajra)",
        "name_mr": "बाजरी",
        "category": "Millets / भरडधान्य",
        "optimal_n": 50,
        "optimal_p": 25,
        "optimal_k": 25,
        "optimal_ph_min": 5.5,
        "optimal_ph_max": 8.0,
        "optimal_temp_min": 22,
        "optimal_temp_max": 38,
        "optimal_rainfall_min": 300,
        "optimal_rainfall_max": 600,
        "suitable_seasons": ["Kharif", "Summer"],
        "suitable_soils": ["Sandy Loam", "Light Soil", "Medium Black", "Red Soil"],
        "duration_days": "75-85 days / दिवस",
        "estimated_yield_per_acre": "12 - 16 Quintals / क्विंटल",
        "profit_potential_per_acre": "₹20,000 - ₹32,000",
        "description_en": "Highly drought-resistant superfood millet thriving in light soils and low rainfall.",
        "description_mr": "कमी पाऊस आणि हलक्या जमिनीतही उत्तम येणारे दुष्काळ सहन करणारे पौष्टिक भरडधान्य.",
        "advantages_en": ["Drought hardy", "Lowest input cost", "Nutritious fodder"],
        "advantages_mr": ["दुष्काळ सहन करण्याची ताकद", "अत्यंत कमी खर्च", "पौष्टिक चारा"],
    },
]


class CropRecommendationService:
    @classmethod
    def recommend_crops(
        cls,
        nitrogen: float = 80.0,
        phosphorus: float = 40.0,
        potassium: float = 40.0,
        ph: float = 6.8,
        temperature: float = 28.0,
        rainfall: float = 750.0,
        season: str = "Kharif",
        soil_type: str = "Medium Black",
        irrigation_available: bool = True,
    ) -> List[Dict[str, Any]]:
        results = []

        for crop in CROPS_DATABASE:
            score = 100.0

            # 1. Season Compatibility (30% weight)
            if season not in crop["suitable_seasons"]:
                score -= 35.0

            # 2. Soil Type Compatibility (20% weight)
            if not any(st.lower() in soil_type.lower() for st in crop["suitable_soils"]):
                score -= 20.0

            # 3. pH Compatibility (15% weight)
            if ph < crop["optimal_ph_min"] or ph > crop["optimal_ph_max"]:
                diff = min(abs(ph - crop["optimal_ph_min"]), abs(ph - crop["optimal_ph_max"]))
                score -= min(15.0, diff * 10.0)

            # 4. Temperature Compatibility (15% weight)
            if temperature < crop["optimal_temp_min"] or temperature > crop["optimal_temp_max"]:
                temp_diff = min(abs(temperature - crop["optimal_temp_min"]), abs(temperature - crop["optimal_temp_max"]))
                score -= min(15.0, temp_diff * 2.0)

            # 5. Rainfall & Irrigation (10% weight)
            if not irrigation_available and rainfall < crop["optimal_rainfall_min"]:
                score -= 15.0

            # 6. NPK distance factor (10% weight)
            n_diff = abs(nitrogen - crop["optimal_n"]) / max(1.0, crop["optimal_n"])
            p_diff = abs(phosphorus - crop["optimal_p"]) / max(1.0, crop["optimal_p"])
            k_diff = abs(potassium - crop["optimal_k"]) / max(1.0, crop["optimal_k"])
            npk_penalty = min(10.0, (n_diff + p_diff + k_diff) * 2.5)
            score -= npk_penalty

            score = max(10.0, min(99.0, score))
            final_score = round(score, 1)

            if final_score >= 80.0:
                tier_en = "Highly Recommended"
                tier_mr = "अत्यंत अनुकूल व शिफारस केलेले ⭐"
                badge_color = "#2E7D32"
            elif final_score >= 60.0:
                tier_en = "Moderately Suitable"
                tier_mr = "मध्यम अनुकूल (योग्य व्यवस्थापन आवश्यक) ✔️"
                badge_color = "#F57F17"
            else:
                tier_en = "Less Suitable"
                tier_mr = "कमी अनुकूल (इतर पर्याय निवडा) ⚠️"
                badge_color = "#C62828"

            results.append({
                "crop_id": crop["crop_id"],
                "name_en": crop["name_en"],
                "name_mr": crop["name_mr"],
                "category": crop["category"],
                "match_score": final_score,
                "tier_en": tier_en,
                "tier_mr": tier_mr,
                "badge_color": badge_color,
                "duration_days": crop["duration_days"],
                "estimated_yield_per_acre": crop["estimated_yield_per_acre"],
                "profit_potential_per_acre": crop["profit_potential_per_acre"],
                "description_en": crop["description_en"],
                "description_mr": crop["description_mr"],
                "advantages_en": crop["advantages_en"],
                "advantages_mr": crop["advantages_mr"],
            })

        # Sort descending by match score
        results.sort(key=lambda x: x["match_score"], reverse=True)
        return results

    @classmethod
    def get_supported_crops(cls) -> List[Dict[str, Any]]:
        return CROPS_DATABASE
