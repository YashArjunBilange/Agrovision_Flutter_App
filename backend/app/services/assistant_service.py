import logging
import os
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

# Curated agricultural knowledge base for offline or direct agronomy expert matching
AGRONOMY_KB = [
    {
        "keywords": ["fall armyworm", "faw", "armyworm", "लष्करी", "लष्करी अळी", "अळी", "spodoptera"],
        "en": (
            "**Fall Armyworm (Spodoptera frugiperda) Management:**\n\n"
            "1. **Early Stage (Whorl 15-30 days):** Spray **Emamectin Benzoate 5% SG** @ 0.4 g/L (6-8g per 15L pump) or **Chlorantraniliprole 18.5% SC (Coragen)** @ 0.4 ml/L (6ml per 15L pump).\n"
            "2. **Biological Control:** Spray *Bacillus thuringiensis* (Bt) @ 2g/L or *Metarhizium anisopliae* @ 5g/L.\n"
            "3. **Pheromone Traps:** Install 4-5 FAW pheromone traps per acre for early monitoring.\n"
            "4. **Poison Baiting (Late Stage):** Mix 10 kg rice bran + 1 kg jaggery + 100g Thiodicarb in water, ferment for 24h, and apply small pellets directly into the plant whorls in the evening."
        ),
        "mr": (
            "**मका पिकावरील लष्करी अळी (Fall Armyworm) नियंत्रण:**\n\n"
            "१. **सुरुवातीच्या टप्प्यात (१५ ते ३० दिवस):** **इमामेक्टिन बेन्झोएट ५% एसजी** (०.४ ग्रॅम/लिटर म्हणजेच ६ ग्रॅम प्रति १५ लि. पंप) किंवा **कोराजन (Chlorantraniliprole 18.5% SC)** (०.४ मिली/लिटर म्हणजेच ६ मिली प्रति १५ लि. पंप) फवारावे.\n"
            "२. **जैविक उपाय:** बुरशीजन्य कीटकनाशक *मेटारायझियम ॲनिसोपली* (५ ग्रॅम/लिटर) किंवा *बॅसिलस थुरिन्जिएन्सिस (Bt)* (२ ग्रॅम/लिटर) फवारा.\n"
            "३. **कामगंध सापळे:** एकरी ४ ते ५ लष्करी अळीचे कामगंध सापळे लावावेत.\n"
            "४. **विषारी आमिष (मोठी अळी असल्यास):** १० किलो भाताचा कोंडा + १ किलो गूळ + १०० ग्रॅम थायोडीकार्ब ७५% डब्ल्यूपी यांचे मिश्रण रात्रभर आंबवून संध्याकाळी मक्याच्या पोंग्यात टाकावे."
        ),
        "suggestions_en": ["What is the dosage of Coragen?", "How to make poison bait for FAW?", "When should I spray next?"],
        "suggestions_mr": ["कोराजनचे अचूक प्रमाण किती?", "विषारी आमिष कसे तयार करावे?", "पुढील फवारणी कधी करावी?"]
    },
    {
        "keywords": ["fertilizer", "urea", "dap", "npk", "potash", "zinc", "खत", "युरिया", "डीएपी", "पोटॅश", "झिंक", "खते"],
        "en": (
            "**Maize Balanced Fertilizer Regimen (Per Acre):**\n\n"
            "• **Total Dose:** 48 kg Nitrogen (N), 24 kg Phosphorus (P), 16 kg Potassium (K), and 10 kg Zinc Sulphate.\n"
            "• **Basal Dose (At Sowing):** Apply 50 kg DAP + 25 kg MOP (Potash) + 10 kg Zinc Sulphate + 15 kg Urea.\n"
            "• **1st Top Dressing (30-35 days / Knee-high):** 35 kg Urea at the base of plants before earthing up.\n"
            "• **2nd Top Dressing (50-55 days / Tasseling):** 30 kg Urea during flowering/tasseling with good soil moisture.\n\n"
            "⚠️ *Tip:* Always ensure adequate soil moisture before top-dressing urea to prevent nitrogen volatilization."
        ),
        "mr": (
            "**मका पिकाचे संतुलित खत व्यवस्थापन (प्रति एकर):**\n\n"
            "• **एकूण मात्रा:** ४८ किलो नत्र, २४ किलो स्फुरद, १६ किलो पालाश आणि १० किलो झिंक सल्फेट.\n"
            "• **पेरणीवेळी (Basal Dose):** ५० किलो डीएपी (DAP) + २५ किलो म्युरेट ऑफ पोटॅश (MOP) + १० किलो झिंक सल्फेट + १५ किलो युरिया.\n"
            "• **पहिली खताची मात्रा (३० ते ३५ दिवस - गुडघाभर उंची):** ३५ किलो युरिया झाडाच्या बुंध्याशी देऊन मातीची भर लावावी.\n"
            "• **दुसरी खताची मात्रा (५० ते ५५ दिवस - तुरा निघताना):** ३० किलो युरिया जमिनीत पुरेशा ओलाव्यावर द्यावा.\n\n"
            "⚠️ *महत्त्वाची सूचना:* युरिया देताना जमिनीत पुरेसा ओलावा असणे गरजेचे आहे."
        ),
        "suggestions_en": ["Calculate fertilizer for my farm size", "Should I apply Zinc Sulphate with DAP?", "How to spray 19:19:19?"],
        "suggestions_mr": ["माझ्या क्षेत्रासाठी खताचे प्रमाण काढा", "झिंक सल्फेट डीएपीसोबत देता येते का?", "१९:१९:१९ ची फवारणी कधी करावी?"]
    },
    {
        "keywords": ["water", "irrigation", "drip", "moisture", "पाणी", "सिंचन", "ठिबक", "पाण्याचे नियोजन", "ताण"],
        "en": (
            "**Maize Irrigation & Critical Water Stages:**\n\n"
            "Maize requires approximately 500-600 mm of water throughout its cycle. Water stress must be avoided during:\n\n"
            "1. **Knee-high Vegetative Stage (25-35 DAS):** Rapid stem elongation.\n"
            "2. **Tasseling & Silking Stage (50-65 DAS - MOST CRITICAL):** Water stress here can reduce cob grain setting by up to 50%!\n"
            "3. **Grain Filling / Dough Stage (70-85 DAS):** Crucial for bold, heavy grain weight.\n\n"
            "💧 **Drip Irrigation:** Run drip for 1.5 to 2 hours every 2-3 days in black soils."
        ),
        "mr": (
            "**मका पिकाचे पाणी व्यवस्थापन व संवेदनशील अवस्था:**\n\n"
            "मका पिकाला संपूर्ण कालावधीत ५०० ते ६०० मिमी पाण्याची गरज असते. खालील ३ टप्प्यांत पाण्याचा ताण अजिबात पडू देऊ नये:\n\n"
            "१. **गुडघाभर उंचीची अवस्था (२५ ते ३५ दिवस):** पिकाची जोमदार वाढ होण्यासाठी.\n"
            "२. **तुरा व कणसावर रेशीम येण्याची अवस्था (५० ते ६५ दिवस - अत्यंत संवेदनशील):** या वेळी ताण पडल्यास परागीभवन नीट होत नाही व दाणे भरत नाहीत (उत्पादनात ५०% पर्यंत घट).\n"
            "३. **दाणे भरण्याची अवस्था (७० ते ८५ दिवस):** दाणे टपोरे आणि वजनदार होण्यासाठी.\n\n"
            "💧 **ठिबक सिंचन:** मध्यम काळ्या जमिनीत दर २-३ दिवसांनी १.५ ते २ तास ठिबक चालवावे."
        ),
        "suggestions_en": ["How much water in sandy soil?", "What to do during waterlogging?", "Drip fertigation schedule"],
        "suggestions_mr": ["हलक्या जमिनीत पाण्याचे नियोजन कसे करावे?", "शेतात पाणी साचल्यास काय करावे?", "ठिबकमधून विद्राव्य खते कधी द्यावी?"]
    },
    {
        "keywords": ["weed", "herbicide", "atrazine", "laudis", "तण", "तणनाशक", "ॲट्राझिन", "लॉडीस"],
        "en": (
            "**Maize Weed Control:**\n\n"
            "1. **Pre-emergence (0-3 days after sowing):** Spray **Atrazine 50% WP** @ 1.0 kg/acre in 200 liters of water on moist soil.\n"
            "2. **Post-emergence (15-20 days):** If broadleaf and grassy weeds appear, spray **Tembotrione 34.4% SC (Laudis)** @ 115 ml/acre along with surfactant (1000ml/acre).\n"
            "3. **Interculture:** Perform hand weeding or hoeing (कोळपणी) at 20-25 days."
        ),
        "mr": (
            "**मका पिकातील तण व्यवस्थापन:**\n\n"
            "१. **पेरणीनंतर त्वरित (० ते ३ दिवसांत):** **ॲट्राझिन ५०% डब्ल्यूपी** (Atrazine 50% WP) १ किलो प्रति एकर २०० लिटर पाण्यात मिसळून ओलसर जमिनीवर फवारावे.\n"
            "२. **उगवणीनंतर (१५ ते २० दिवस):** गवतवर्गीय व रुंद पानांच्या तणांसाठी **लॉडीस (Tembotrione 34.4% SC)** ११५ मिली + सर्फॅक्टंट प्रति एकर फवारावे.\n"
            "३. **आंतरमशागत:** पेरणीनंतर २० ते २५ दिवसांनी एक कोळपणी व खुरपणी करावी."
        ),
        "suggestions_en": ["How to spray Atrazine safely?", "Can I mix Laudis with insecticide?", "When to do hoeing?"],
        "suggestions_mr": ["ॲट्राझिन फवारताना कोणती काळजी घ्यावी?", "लॉडीस कीटकनाशकासोबत मिसळता येते का?", "कोळपणी कधी करावी?"]
    },
    {
        "keywords": ["blight", "turcicum", "rust", "fungus", "disease", "करपा", "तुर्सिकम", "तांबेरा", "बुरशी", "रोग"],
        "en": (
            "**Maize Disease Management (Turcicum Blight & Rust):**\n\n"
            "• **Turcicum Leaf Blight:** Long elliptical greyish-green lesions on leaves. Spray **Mancozeb 75% WP** @ 2.5 g/L (35-40g/pump) or **Azoxystrobin 18.2% + Difenoconazole 11.4% SC (Amistar Top)** @ 1 ml/L.\n"
            "• **Common Rust:** Reddish-brown powdery pustules on leaf surface. Spray **Propiconazole 25% EC (Tilt)** @ 1 ml/L (15ml/pump).\n"
            "• **Stalk Rot:** Avoid excess nitrogen; ensure good drainage and apply Trichoderma viride in soil."
        ),
        "mr": (
            "**मका पिकावरील रोग व्यवस्थापन (तुर्सिकम करपा व तांबेरा):**\n\n"
            "• **तुर्सिकम पान करपा (Turcicum Leaf Blight):** पानांवर लांबट तपकिरी-राखाडी डाग पडतात. नियंत्रणासाठी **मॅन्कोझेब ७५% डब्ल्यूपी** (२.५ ग्रॅम/लिटर) किंवा **ॲमिस्टार टॉप (Azoxystrobin + Difenoconazole)** (१ मिली/लिटर) फवारावे.\n"
            "• **तांबेरा रोग (Common Rust):** पानांवर तांबूस-तपकिरी रंगाचे बारीक फोड येतात. **प्रोपिकोनाझोल २५% ईसी (Tilt)** (१ मिली/लिटर म्हणजेच १५ मिली प्रति पंप) फवारावे.\n"
            "• **खोड कुजव्या (Stalk Rot):** शेतात पाण्याचा उत्तम निचरा ठेवावा आणि जमिनीतून ट्रायकोडर्मा बुरशीची प्रक्रिया करावी."
        ),
        "suggestions_en": ["How to identify leaf blight vs rust?", "What is the dosage for Amistar Top?", "Preventive organic sprays for maize"],
        "suggestions_mr": ["करपा आणि तांबेरा यातील फरक कसा ओळखावा?", "ॲमिस्टार टॉपचे अचूक प्रमाण किती?", "मक्यासाठी सेंद्रिय बुरशीनाशके कोणती?"]
    },
]

DEFAULT_QUICK_PROMPTS = [
    {
        "title_en": "🌽 Fall Armyworm Control",
        "title_mr": "🌽 लष्करी अळी नियंत्रण",
        "prompt_en": "How can I protect my maize crop from Fall Armyworm?",
        "prompt_mr": "माझ्या मका पिकावरील लष्करी अळीचे नियंत्रण कसे करावे?",
    },
    {
        "title_en": "🌾 Fertilizer Schedule",
        "title_mr": "🌾 खत नियोजन व मात्रा",
        "prompt_en": "What is the complete NPK fertilizer schedule for 1 acre of maize?",
        "prompt_mr": "मका पिकासाठी एकरी खताचे संपूर्ण वेळापत्रक सांगा.",
    },
    {
        "title_en": "💧 Critical Irrigation Timing",
        "title_mr": "💧 पाणी व्यवस्थापन व ताण",
        "prompt_en": "Which stages in maize are most sensitive to water shortage?",
        "prompt_mr": "मक्याला कोणत्या अवस्थेत पाणी देणे सर्वात महत्त्वाचे आहे?",
    },
    {
        "title_en": "🌿 Weed Management",
        "title_mr": "🌿 तणनाशक फवारणी",
        "prompt_en": "What herbicide should I spray after sowing maize?",
        "prompt_mr": "मका पेरणीनंतर कोणते तणनाशक फवारावे?",
    },
]


class AssistantService:
    @classmethod
    async def get_response(
        cls,
        message: str,
        language: str = "mr",
        farm_context: Optional[Dict[str, Any]] = None,
        crop_cycle_context: Optional[Dict[str, Any]] = None,
        weather_context: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """Generates context-aware, bilingual agronomic advice for the farmer."""
        lower_msg = message.lower()

        # Check for context personalization
        context_summary = []
        if farm_context:
            name = farm_context.get("name", "Farm")
            acres = farm_context.get("area_acres", 2.0)
            soil = farm_context.get("soil_type", "Black soil")
            context_summary.append(f"शेत: {name} ({acres} एकर, {soil})" if language == "mr" else f"Farm: {name} ({acres} Acres, {soil})")

        if crop_cycle_context:
            stage = crop_cycle_context.get("current_stage", {})
            stage_name = stage.get("name_mr" if language == "mr" else "name_en", "Vegetative")
            days = crop_cycle_context.get("days_since_sowing", 0)
            context_summary.append(f"पिकाचा टप्पा: {stage_name} (दिवस {days})" if language == "mr" else f"Crop Stage: {stage_name} (Day {days})")

        # 1. Match with expert agronomy knowledge base
        best_match = None
        for item in AGRONOMY_KB:
            for kw in item["keywords"]:
                if kw in lower_msg:
                    best_match = item
                    break
            if best_match:
                break

        if best_match:
            reply_text = best_match["mr"] if language == "mr" else best_match["en"]
            suggestions = best_match["suggestions_mr"] if language == "mr" else best_match["suggestions_en"]
        else:
            # General helpful Agronomist response
            if language == "mr":
                reply_text = (
                    f"नमस्कार शेतकरी मित्र! 🙏\n\n"
                    f"आपण विचारलेल्या प्रश्नाबाबत: **'{message}'**\n\n"
                    f"मका पिकाच्या अधिक माहितीसाठी तुम्ही खालील विषयांवर मार्गदर्शन मिळवू शकता:\n"
                    f"• **लष्करी अळी नियंत्रण (FAW Spray)**\n"
                    f"• **खतांचे वेळापत्रक (युरिया, डीएपी, पोटॅश मात्रा)**\n"
                    f"• **पाणी व ठिबक सिंचन नियोजन**\n"
                    f"• **तणनाशक व बुरशीनाशक फवारणी**\n\n"
                    f"कृपा करून वरील पर्यायांपैकी एक निवडा किंवा अधिक तपशील विचारा."
                )
                suggestions = ["लष्करी अळीवर औषध", "खताचे वेळापत्रक", "पाण्याचे नियोजन", "तणनाशक फवारणी"]
            else:
                reply_text = (
                    f"Namaste Farmer Friend! 🙏\n\n"
                    f"Regarding your query: **'{message}'**\n\n"
                    f"For best maize crop yield, here are key agronomy areas you can explore:\n"
                    f"• **Fall Armyworm Management (FAW)**\n"
                    f"• **Balanced NPK & Zinc Fertilizer Schedule**\n"
                    f"• **Critical Irrigation & Moisture Management**\n"
                    f"• **Atrazine / Laudis Weed Control**\n\n"
                    f"Please ask any specific question or choose a suggested topic below."
                )
                suggestions = ["Fall Armyworm Control", "Fertilizer Schedule", "Irrigation Timing", "Weed Spray"]

        # Add farm context header if available
        if context_summary:
            header = f"🌱 *[{' • '.join(context_summary)}]*\n\n"
            reply_text = header + reply_text

        return {
            "reply": reply_text,
            "language": language,
            "suggestions": suggestions,
            "context_used": bool(context_summary),
        }

    @classmethod
    def get_quick_prompts(cls) -> List[Dict[str, str]]:
        return DEFAULT_QUICK_PROMPTS
