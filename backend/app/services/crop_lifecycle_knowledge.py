from typing import Any, Dict, List

MAIZE_LIFECYCLE_STAGES: List[Dict[str, Any]] = [
    {
        "stage_id": "sowing_germination",
        "order": 1,
        "name_en": "Sowing & Germination",
        "name_mr": "पेरणी व उगवण टप्पा",
        "day_range_min": 0,
        "day_range_max": 15,
        "description_en": "Seed germination, radicle emergence, and first true leaf development.",
        "description_mr": "बियाणे उगवण, मुळांची स्थापना आणि पहिली २ ते ४ पाने बाहेर येणे.",
        "npk_recommendation": {
            "title_en": "Basal Fertilizer Dose (At Sowing)",
            "title_mr": "पायाभूत खत मात्रा (पेरणीवेळी)",
            "per_acre_kg": {
                "DAP_18_46_0": 50,
                "MOP_0_0_60": 30,
                "Zinc_Sulphate": 10,
                "Urea": 25,
            },
            "alternate_npk_10_26_26_kg": 75,
            "instruction_en": "Apply basal fertilizers 5 cm away and below seed level. Do not mix zinc with phosphorus directly.",
            "instruction_mr": "पेरणीच्या वेळी रासायनिक खते बियाण्याखाली ५ सेमी खोल द्या. झिंक सल्फेट फॉस्फरस खतामध्ये मिसळू नये.",
        },
        "irrigation_advice_en": "Apply light first irrigation immediately after sowing. Second light irrigation at 4-5 days if topsoil is crusty.",
        "irrigation_advice_mr": "पेरणीनंतर लगेच हलके पाणी (ओलवणी) द्या. जमीन टणक झाल्यास ४-५ दिवसांनी दुसरे हलके पाणी द्या.",
        "water_sensitivity": "Moderate",
        "pest_disease_watch": [
            {
                "threat_en": "Seed rot / Damping off",
                "threat_mr": "उगवणीतील कूज व बुरशी",
                "action_en": "Treat seeds with Thiram @ 3g/kg or Trichoderma @ 10g/kg.",
                "action_mr": "पेरणीपूर्वी थायरम ३ ग्रॅम किंवा ट्रायकोडर्मा १० ग्रॅम प्रति किलो बियाण्यास चोळा.",
            },
            {
                "threat_en": "Fall Armyworm (FAW) Egg masses",
                "threat_mr": "लष्करी अळीचे अंडीपुंज",
                "action_en": "Scout underside of leaves. Install 5 pheromone traps per acre.",
                "action_mr": "पानांच्या खालच्या बाजूस अंड्यांचे निरीक्षण करा. एकरी ५ फेरोमोन ट्रॅप लावा.",
            },
        ],
        "default_tasks": [
            {
                "title_en": "Seed Treatment with Trichoderma / Thiram",
                "title_mr": "पेरणीपूर्वी थायरम किंवा ट्रायकोडर्माने बीजप्रक्रिया करणे",
                "task_type": "cultural",
                "due_days": 0,
            },
            {
                "title_en": "Basal Dose Application (DAP + MOP + Zinc)",
                "title_mr": "पायाभूत खत देणे (डीएपी + पोटॅश + झिंक सल्फेट)",
                "task_type": "fertilizer",
                "due_days": 1,
            },
            {
                "title_en": "Pre-emergence Weed Control (Atrazine @ 1 kg/acre)",
                "title_mr": "तण नियंत्रण (अॅट्राझिन १ किलो प्रति एकर फवारणी - ४८ तासांच्या आत)",
                "task_type": "spray",
                "due_days": 2,
            },
            {
                "title_en": "Install Pheromone Traps for FAW Monitoring",
                "title_mr": "लष्करी अळी नियंत्रणासाठी एकरी ५ कामगंध सापळे लावणे",
                "task_type": "cultural",
                "due_days": 10,
            },
        ],
    },
    {
        "stage_id": "knee_high_vegetative",
        "order": 2,
        "name_en": "Knee-High (Vegetative Growth)",
        "name_mr": "गुडघाभर उंची (वाढीचा टप्पा)",
        "day_range_min": 16,
        "day_range_max": 35,
        "description_en": "Rapid stem elongation, root nodal expansion, and 6 to 8 leaves unfurled (V6-V8).",
        "description_mr": "पिकाची जलद शाकीय वाढ, खोड जाड होणे आणि ६ ते ८ पाने पूर्ण उघडणे.",
        "npk_recommendation": {
            "title_en": "First Top-Dressing (30-35 Days)",
            "title_mr": "पहिली खताची मात्रा (३० ते ३५ दिवस)",
            "per_acre_kg": {
                "Urea": 45,
                "Magnesium_Sulphate": 10,
            },
            "instruction_en": "Top-dress Urea followed by earthing up / hoeing and immediate irrigation.",
            "instruction_mr": "युरिया खताचा हप्ता झाडांच्या बुंध्यापासून बाजूला देऊन लगेच मातीची भर लावा व पाणी द्या.",
        },
        "irrigation_advice_en": "Irrigate every 8-10 days depending on soil moisture. Avoid standing water in heavy clay soils.",
        "irrigation_advice_mr": "जमिनीतील ओलावा पाहून ८ ते १० दिवसांनी पाणी द्या. शेतात पाणी साचू देऊ नका.",
        "water_sensitivity": "High",
        "pest_disease_watch": [
            {
                "threat_en": "Fall Armyworm Whorl Feeding",
                "threat_mr": "मक्याच्या पोंग्यातील लष्करी अळी",
                "action_en": "Spray Chlorantraniliprole 18.5% SC @ 0.4 ml/L directly into whorl if damage > 5%.",
                "action_mr": "पोंग्यात प्रादुर्भाव दिसल्यास कोराजन ६ मिली प्रति १५ लिटर पंप थेट पोंग्यात फवारा.",
            },
            {
                "threat_en": "Stem Borer (Chilo partellus)",
                "threat_mr": "खोडकिडा प्रादुर्भाव",
                "action_en": "Apply Carbofuran 3G granules or Neem seed kernel extract 5%.",
                "action_mr": "५% निंबोळी अर्क फवारणी करा किंवा कार्बोफ्युरान दाणेदार खत वापरा.",
            },
        ],
        "default_tasks": [
            {
                "title_en": "First Intercultivation / Hoeing & Earthing Up",
                "title_mr": "पहिली कोळपणी व झाडांना मातीची भर देणे",
                "task_type": "cultural",
                "due_days": 20,
            },
            {
                "title_en": "First Top Dressing with Urea (45 kg/acre)",
                "title_mr": "युरिया खताचा पहिला हप्ता देणे (४५ किलो प्रति एकर)",
                "task_type": "fertilizer",
                "due_days": 30,
            },
            {
                "title_en": "Whorl Spray against Fall Armyworm",
                "title_mr": "लष्करी अळी नियंत्रणासाठी पोंग्यात औषध फवारणी",
                "task_type": "spray",
                "due_days": 25,
            },
        ],
    },
    {
        "stage_id": "tasseling_flowering",
        "order": 3,
        "name_en": "Tasseling (Flowering Initiation)",
        "name_mr": "तुरा येणे व फुलोरा टप्पा",
        "day_range_min": 36,
        "day_range_max": 55,
        "description_en": "Tassel emerges at top of plant and begins shedding pollen grains.",
        "description_mr": "झाडाच्या शेंड्यावरून तुरा (नर फूल) बाहेर पडतो व परागीभवन सुरू होते.",
        "npk_recommendation": {
            "title_en": "Second Top-Dressing (At Tasseling)",
            "title_mr": "दुसरी खताची मात्रा (तुरा येताना)",
            "per_acre_kg": {
                "Urea": 35,
                "MOP_0_0_60": 20,
            },
            "instruction_en": "Apply Potash alongside Urea to strengthen stalk against lodging and boost grain weight.",
            "instruction_mr": "खोड मजबूत होण्यासाठी व दाण्यांच्या वजनासाठी युरियासोबत पोटॅश खताचा हप्ता द्या.",
        },
        "irrigation_advice_en": "CRITICAL MOISTURE PERIOD: Water stress during tasseling can reduce yield by up to 40%. Ensure steady irrigation.",
        "irrigation_advice_mr": "अतिसंवेदनशील टप्पा: तुरा येताना पाण्याचा ताण पडल्यास उत्पन्नात ४०% पर्यंत घट येऊ शकते. वेळेवर पाणी द्या.",
        "water_sensitivity": "Critical",
        "pest_disease_watch": [
            {
                "threat_en": "Northern Corn Leaf Blight & Rust",
                "threat_mr": "तुरा करपा व तांबेरा रोग",
                "action_en": "Foliar spray of Azoxystrobin + Difenoconazole @ 1 ml/L at first appearance of spots.",
                "action_mr": "पानांवर ठिपके दिसताच अमिस्टार टॉप १५ मिली प्रति १५ लिटर पंपाने फवारा.",
            },
        ],
        "default_tasks": [
            {
                "title_en": "Second Top-Dressing with Urea + Potash",
                "title_mr": "युरिया (३५ किलो) + पोटॅश (२० किलो) चा दुसरा हप्ता देणे",
                "task_type": "fertilizer",
                "due_days": 45,
            },
            {
                "title_en": "Critical Tasseling Irrigation",
                "title_mr": "तुरा अवस्थेतील अत्यंत महत्त्वाचे पाणी देणे",
                "task_type": "irrigation",
                "due_days": 48,
            },
            {
                "title_en": "Preventive Fungicide Spray for Leaf Blight",
                "title_mr": "करपा व तांबेरा प्रतिबंधासाठी बुरशीनाशक फवारणी",
                "task_type": "spray",
                "due_days": 50,
            },
        ],
    },
    {
        "stage_id": "silking_cob_formation",
        "order": 4,
        "name_en": "Silking & Cob Formation",
        "name_mr": "कणीस तयार होणे व दाणे भरणे",
        "day_range_min": 56,
        "day_range_max": 75,
        "description_en": "Silks emerge from ear tip, pollination completes, and young kernels form inside cob.",
        "description_mr": "कणसातून रेशीम (केस) बाहेर पडतात, परागीभवन पूर्ण होऊन लहान दाणे तयार होतात.",
        "npk_recommendation": {
            "title_en": "Foliar Micronutrient & Potassium Spray",
            "title_mr": "दाणे भरण्यासाठी विद्राव्य खताची फवारणी",
            "per_acre_kg": {
                "NPK_0_0_50_or_13_0_45": 2,
                "Boron_20_percent": 0.25,
            },
            "instruction_en": "Foliar spray of 0:0:50 (Potassium Sulphate @ 5g/L) + Boron (1g/L) enhances grain size and shine.",
            "instruction_mr": "००:००:५० (५ ग्रॅम/लिटर) + बोरॉन (१ ग्रॅम/लिटर) फवारणी केल्याने दाणे टपोरे व चमकदार भरतात.",
        },
        "irrigation_advice_en": "CRITICAL MOISTURE PERIOD: Maintain continuous soil moisture until kernels fill out.",
        "irrigation_advice_mr": "अतिसंवेदनशील टप्पा: दाणे भरेपर्यंत शेतात ओलावा टिकवून ठेवा.",
        "water_sensitivity": "Critical",
        "pest_disease_watch": [
            {
                "threat_en": "Cob Borer / Earworm entering tip",
                "threat_mr": "कणसातील दाणे खाणारी अळी",
                "action_en": "Apply Emamectin Benzoate 5% SG @ 0.5 g/L on silks if larvae detected.",
                "action_mr": "रेशमावर अळी आढळल्यास प्रोक्लेम ८ ग्रॅम प्रति १५ लिटर पंप फवारा.",
            },
        ],
        "default_tasks": [
            {
                "title_en": "Foliar Spray of 0:0:50 + Boron for Grain Filling",
                "title_mr": "००:००:५० (७५ ग्रॅम) + बोरॉन (१५ ग्रॅम) विद्राव्य खत फवारणी",
                "task_type": "spray",
                "due_days": 65,
            },
            {
                "title_en": "Cob Formation Irrigation",
                "title_mr": "दाणे भरण्याच्या अवस्थेत वेळेवर पाणी देणे",
                "task_type": "irrigation",
                "due_days": 62,
            },
        ],
    },
    {
        "stage_id": "grain_filling_dough",
        "order": 5,
        "name_en": "Dough / Grain Hardening",
        "name_mr": "दाणे पक्व होणे (दुधाळ ते टणक अवस्था)",
        "day_range_min": 76,
        "day_range_max": 95,
        "description_en": "Kernel starch solidifies from milky texture to firm dough stage. Cobs gain maximum weight.",
        "description_mr": "दाण्यातील दूध घट्ट होऊन पीठ तयार होते आणि दाणे टणक होतात. कणीस वजनदार बनते.",
        "npk_recommendation": {
            "title_en": "No Chemical Fertilizers Required",
            "title_mr": "रासायनिक खतांची आवश्यकता नाही",
            "per_acre_kg": {},
            "instruction_en": "Plant uptake has shifted to mobilization of nutrients from stalk to cob.",
            "instruction_mr": "या टप्प्यावर खते देण्याची गरज नसते, झाडातील अन्नद्रव्ये दाण्यांमध्ये साठवली जातात.",
        },
        "irrigation_advice_en": "Moderate irrigation at 10-12 day intervals. Gradually reduce watering towards the end of this stage.",
        "irrigation_advice_mr": "१० ते १२ दिवसांच्या अंतराने मध्यम पाणी द्या. टप्प्याच्या शेवटी पाणी कमी करा.",
        "water_sensitivity": "Moderate",
        "pest_disease_watch": [
            {
                "threat_en": "Bird damage to cobs",
                "threat_mr": "पक्ष्यांचा प्रादुर्भाव",
                "action_en": "Use reflective ribbons or bio-acoustic deterrents.",
                "action_mr": "चमकदार रिबिन किंवा आवाज करणारी साधने वापरून पक्षी पळवा.",
            },
        ],
        "default_tasks": [
            {
                "title_en": "Last Light Irrigation before Ripening",
                "title_mr": "दाणे पूर्ण भरल्यावर शेवटचे हलके पाणी देणे",
                "task_type": "irrigation",
                "due_days": 82,
            },
            {
                "title_en": "Bird Protection Measures in Plot",
                "title_mr": "कणसांचे पक्ष्यांपासून संरक्षणाची व्यवस्था करणे",
                "task_type": "cultural",
                "due_days": 85,
            },
        ],
    },
    {
        "stage_id": "physiological_maturity_harvest",
        "order": 6,
        "name_en": "Maturity & Harvesting",
        "name_mr": "पक्वता व काढणी टप्पा",
        "day_range_min": 96,
        "day_range_max": 120,
        "description_en": "Black layer forms at the kernel tip, husks turn dry straw yellow, moisture drops to 15-20%.",
        "description_mr": "दाण्याच्या तळाशी काळा ठिपका (Black Layer) तयार होतो, कणसाची टरफले पिवळी-पांढरी वाळतात.",
        "npk_recommendation": {
            "title_en": "Harvest Stage - Zero Fertilizer",
            "title_mr": "काढणी टप्पा - खतांची गरज नाही",
            "per_acre_kg": {},
            "instruction_en": "Prepare drying yard and storage bins with pest protection.",
            "instruction_mr": "कणीस सुकवण्यासाठी खळे आणि धान्य साठवणुकीसाठी पोती स्वच्छ करा.",
        },
        "irrigation_advice_en": "Stop all irrigation 10-15 days prior to harvest to facilitate uniform cob drying.",
        "irrigation_advice_mr": "काढणीपूर्वी १० ते १५ दिवस आधी पाणी पूर्णपणे बंद करा जेणेकरून कणसे व्यवस्थित सुकतील.",
        "water_sensitivity": "None",
        "pest_disease_watch": [
            {
                "threat_en": "Stored grain weevil & Mold in damp cobs",
                "threat_mr": "साठवणीतील कीड व बुरशी",
                "action_en": "Dry grain under sun until moisture is below 12% before bagging.",
                "action_mr": "दाण्यातील ओलावा १२% पेक्षा कमी होईपर्यंत उन्हात चांगले वाळवा.",
            },
        ],
        "default_tasks": [
            {
                "title_en": "Stop All Irrigation (10-15 Days Before Harvest)",
                "title_mr": "काढणीपूर्वी पाणी देणे पूर्णपणे बंद करणे",
                "task_type": "irrigation",
                "due_days": 98,
            },
            {
                "title_en": "Cob Harvesting & De-husking",
                "title_mr": "मका कणसांची तोडणी व टरफले काढणे",
                "task_type": "harvest",
                "due_days": 105,
            },
            {
                "title_en": "Sun Drying Grain to 12% Moisture & Bagging",
                "title_mr": "दाणे १२% ओलाव्यापर्यंत उन्हात सुकवून साठवणूक करणे",
                "task_type": "harvest",
                "due_days": 110,
            },
        ],
    },
]


def get_current_stage(days_since_sowing: int) -> Dict[str, Any]:
    for stage in MAIZE_LIFECYCLE_STAGES:
        if stage["day_range_min"] <= days_since_sowing <= stage["day_range_max"]:
            return stage
    # If beyond 120 days, return maturity stage
    return MAIZE_LIFECYCLE_STAGES[-1]


def calculate_fertilizer_dosage_for_acres(acreage: float, stage_id: str) -> Dict[str, Any]:
    stage = next((s for s in MAIZE_LIFECYCLE_STAGES if s["stage_id"] == stage_id), None)
    if not stage or "npk_recommendation" not in stage:
        return {}

    npk = stage["npk_recommendation"]
    per_acre = npk.get("per_acre_kg", {})
    calculated = {}
    for fert_name, kg_per_acre in per_acre.items():
        calculated[fert_name] = round(kg_per_acre * acreage, 1)

    return {
        "title_en": npk.get("title_en"),
        "title_mr": npk.get("title_mr"),
        "acreage": acreage,
        "fertilizers_kg": calculated,
        "instruction_en": npk.get("instruction_en"),
        "instruction_mr": npk.get("instruction_mr"),
    }
