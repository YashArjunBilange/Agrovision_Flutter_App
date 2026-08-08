from typing import Any, Dict, List
import remedies

# Enriched agricultural knowledge repository for Indian crops (Specialized for Maize / Corn)
DISEASE_KNOWLEDGE_BASE: Dict[str, Dict[str, Any]] = {
    "corn_cercospora_leaf_spot": {
        "name_en": "Cercospora Leaf Spot (Grey Spot)",
        "name_mr": "मका सर्कोस्पोरा पानांवरील ठिपके",
        "crop_en": "Maize / Corn",
        "crop_mr": "मका",
        "severity_level": "moderate",
        "symptoms_en": "Small, tan-colored rectangular spots on lower leaves with dark borders. Spots elongate between leaf veins.",
        "symptoms_mr": "पानांच्या शिरांच्या मध्ये लांबट, तपकिरी-राखाडी रंगाचे चौकोनी ठिपके पडतात. रोग वाढल्यास पाने करपतात.",
        "chemical_treatment": [
            {
                "name_en": "Azoxystrobin 18.2% + Difenoconazole 11.4% SC (Amistar Top)",
                "name_mr": "अॅझॉक्सीस्ट्रॉबिन १८.२% + डायफेनोकोनाझोल ११.४% एससी (अमिस्टार टॉप)",
                "dosage_per_liter": "1.0 ml / L",
                "dosage_15l_pump": "15 ml प्रति १५ लिटर पंप",
                "waiting_period_days": 15,
            },
            {
                "name_en": "Mancozeb 75% WP (Dithane M-45)",
                "name_mr": "मॅन्कोझेब ७५% डब्ल्यूपी (डायथेन एम-४५)",
                "dosage_per_liter": "2.5 g / L",
                "dosage_15l_pump": "35-40 ग्रॅम प्रति १५ लिटर पंप",
                "waiting_period_days": 10,
            },
        ],
        "biological_treatment": [
            {
                "name_en": "Trichoderma viride 1% WP",
                "name_mr": "ट्रायकोडर्मा व्हिरिडी १% डब्ल्यूपी (जैविक बुरशीनाशक)",
                "dosage_per_liter": "5 g / L",
                "dosage_15l_pump": "७५ ग्रॅम प्रति १५ लिटर पंप",
            },
            {
                "name_en": "Neem Oil 10,000 PPM",
                "name_mr": "निम अर्क / निंबोळी तेल १०,००० पीपीएम",
                "dosage_per_liter": "2.5 ml / L",
                "dosage_15l_pump": "३५-४० मिली प्रति १५ लिटर पंप",
            },
        ],
        "cultural_preventions_en": [
            "Practice minimum 2-year crop rotation with non-host crops like Soybean or Pulses.",
            "Incorporate crop residue deeply after harvest.",
            "Maintain optimal plant spacing to avoid dense canopy humidity.",
        ],
        "cultural_preventions_mr": [
            "मका पिकाची फेरपालट सोयाबीन किंवा कडधान्य पिकांसोबत करा.",
            "कापणीनंतर पिकाचे अवशेष जमिनीत खोल गाडा.",
            "हवा खेळती राहण्यासाठी दोन ओळींमध्ये योग्य अंतर ठेवा.",
        ],
        "urgency_action_en": "Spray recommended fungicide within 48 hours if spots appear before silking stage.",
        "urgency_action_mr": "तुरा येण्यापूर्वी प्रादुर्भाव दिसल्यास ४८ तासांच्या आत शिफारशीत बुरशीनाशकाची फवारणी करा.",
    },
    "corn_common_rust": {
        "name_en": "Common Rust (Puccinia sorghi)",
        "name_mr": "मका तांबेरा रोग",
        "crop_en": "Maize / Corn",
        "crop_mr": "मका",
        "severity_level": "moderate",
        "symptoms_en": "Golden brown to reddish-brown powdery pustules on both upper and lower leaf surfaces.",
        "symptoms_mr": "पानांच्या दोन्ही बाजूंवर तांबूस-तपकिरी रंगाचे लहान पुरळ (फोड) येतात. हात लावल्यास बुरशीची भुकटी हाताला लागते.",
        "chemical_treatment": [
            {
                "name_en": "Tebuconazole 25.9% EC (Folicur)",
                "name_mr": "टेब्युकोनाझोल २५.९% ईसी (फॉलिक्युर)",
                "dosage_per_liter": "1.0 to 1.25 ml / L",
                "dosage_15l_pump": "१५-१८ मिली प्रति १५ लिटर पंप",
                "waiting_period_days": 14,
            },
            {
                "name_en": "Propiconazole 25% EC (Tilt)",
                "name_mr": "प्रॉपिकोनाझोल २५% ईसी (टिल्ट)",
                "dosage_per_liter": "1.0 ml / L",
                "dosage_15l_pump": "१५ मिली प्रति १५ लिटर पंप",
                "waiting_period_days": 14,
            },
        ],
        "biological_treatment": [
            {
                "name_en": "Pseudomonas fluorescens 1% WP",
                "name_mr": "स्यूडोमोनास फ्लूरोसेन्स १% डब्ल्यूपी",
                "dosage_per_liter": "5 g / L",
                "dosage_15l_pump": "७५ ग्रॅम प्रति १५ लिटर पंप",
            },
            {
                "name_en": "Cow Urine (Gomutra) 10% + Dashparni Kadha",
                "name_mr": "१०% गोमूत्र अर्क + दशपर्णी काढा फवारणी",
                "dosage_per_liter": "100 ml / L",
                "dosage_15l_pump": "१.५ लिटर प्रति १५ लिटर पंप",
            },
        ],
        "cultural_preventions_en": [
            "Plant resistant maize hybrids recommended by MPKV Rahuri / VNMKV Parbhani.",
            "Avoid excessive nitrogen fertilization; balance with Potash.",
            "Early sowing in Kharif avoids high rust spore pressure.",
        ],
        "cultural_preventions_mr": [
            "कृषी विद्यापीठाने शिफारस केलेले तांबेरा प्रतिकारक मका वाण वापरा.",
            "नत्राचा (युरिया) अतिवापर टाळा व पालाश (पोटॅश) योग्य प्रमाणात द्या.",
            "हंगामाच्या सुरुवातीला वेळेवर पेरणी केल्यास रोगाचा प्रादुर्भाव कमी होतो.",
        ],
        "urgency_action_en": "Immediate spray required if pustules appear on upper canopy leaves before grain filling.",
        "urgency_action_mr": "दाणे भरण्याच्या आधी वरच्या पानांवर तांबेरा दिसल्यास त्वरित फवारणी करा.",
    },
    "corn_gray_leaf_spot": {
        "name_en": "Gray Leaf Spot (Cercospora zeae-maydis)",
        "name_mr": "मका राखाडी करपा रोग",
        "crop_en": "Maize / Corn",
        "crop_mr": "मका",
        "severity_level": "severe",
        "symptoms_en": "Long, narrow rectangular lesions that turn gray with yellow halo. Blighted leaves die prematurely.",
        "symptoms_mr": "पानांवर लांबट राखाडी-तपकिरी रंगाचे चट्टे पडतात. गंभीर अवस्थेत संपूर्ण पाने वाळतात व दाणे बारीक राहतात.",
        "chemical_treatment": [
            {
                "name_en": "Pyraclostrobin 133 g/L + Epoxiconazole 50 g/L (Opera)",
                "name_mr": "पायराक्लोस्ट्रॉबिन + एपोक्सीकोनाझोल (ऑपेरा)",
                "dosage_per_liter": "1.5 ml / L",
                "dosage_15l_pump": "२०-२२ मिली प्रति १५ लिटर पंप",
                "waiting_period_days": 21,
            },
            {
                "name_en": "Hexaconazole 5% SC (Contaf)",
                "name_mr": "हेक्साकोनाझोल ५% एससी (कॉन्टाफ)",
                "dosage_per_liter": "2.0 ml / L",
                "dosage_15l_pump": "३० मिली प्रति १५ लिटर पंप",
                "waiting_period_days": 14,
            },
        ],
        "biological_treatment": [
            {
                "name_en": "Bacillus subtilis formulation",
                "name_mr": "बॅसिलस सबटिलिस जैविक द्रावण",
                "dosage_per_liter": "5 ml / L",
                "dosage_15l_pump": "७५ मिली प्रति १५ लिटर पंप",
            },
        ],
        "cultural_preventions_en": [
            "Adopt crop rotation and avoid planting maize consecutively in the same plot.",
            "Destroy infected maize stubbles after harvest.",
        ],
        "cultural_preventions_mr": [
            "एकाच शेतात सलग मका घेणे टाळा, पिकांची फेरपालट करा.",
            "कापणीनंतर जमिनीतील पिकाचे अवशेष जाळून किंवा खोल नांगरट करून नष्ट करा.",
        ],
        "urgency_action_en": "Apply systemic fungicide at first sign to prevent leaf canopy collapse.",
        "urgency_action_mr": "पानांवर चट्टे दिसताच त्वरित आंतरप्रवाही बुरशीनाशकाची फवारणी करा.",
    },
    "corn_northern_leaf_blight": {
        "name_en": "Northern Corn Leaf Blight (Exserohilum turcicum)",
        "name_mr": "मका तुरा करपा (मोठा करपा)",
        "crop_en": "Maize / Corn",
        "crop_mr": "मका",
        "severity_level": "severe",
        "symptoms_en": "Large cigar-shaped elliptical grayish-green or tan lesions (2.5 to 15 cm long).",
        "symptoms_mr": "पानांवर सिगारच्या आकाराचे मोठे लांबट लंबगोलाकार राखाडी-तपकिरी डाग पडतात (२.५ ते १५ सेमी लांब).",
        "chemical_treatment": [
            {
                "name_en": "Azoxystrobin 23% SC (Amistar)",
                "name_mr": "अॅझॉक्सीस्ट्रॉबिन २३% एससी (अमिस्टार)",
                "dosage_per_liter": "1.0 ml / L",
                "dosage_15l_pump": "१५ मिली प्रति १५ लिटर पंप",
                "waiting_period_days": 15,
            },
            {
                "name_en": "Carbendazim 12% + Mancozeb 63% WP (Saaf)",
                "name_mr": "कार्बेन्डाझिम १२% + मॅन्कोझेब ६३% डब्ल्यूपी (साफ)",
                "dosage_per_liter": "2.0 g / L",
                "dosage_15l_pump": "३० ग्रॅम प्रति १५ लिटर पंप",
                "waiting_period_days": 10,
            },
        ],
        "biological_treatment": [
            {
                "name_en": "Trichoderma harzianum 2% WP",
                "name_mr": "ट्रायकोडर्मा हार्झियानम २% डब्ल्यूपी",
                "dosage_per_liter": "5 g / L",
                "dosage_15l_pump": "७५ ग्रॅम प्रति १५ लिटर पंप",
            },
        ],
        "cultural_preventions_en": [
            "Use certified disease-free seeds and seed treatment with Thiram @ 3g/kg.",
            "Maintain soil drainage to prevent high humidity in root and canopy zone.",
        ],
        "cultural_preventions_mr": [
            "पेरणीपूर्वी थायरम बुरशीनाशकाची बीजप्रक्रिया (३ ग्रॅम प्रति किलो) करा.",
            "पाण्याचा निचरा चांगला ठेवा, शेतात पाणी साचू देऊ नका.",
        ],
        "urgency_action_en": "Critical: Spray within 24-48 hours if lesions appear near the cob/ear leaf.",
        "urgency_action_mr": "कणसाजवळच्या पानांवर डाग आल्यास २४ ते ४८ तासांच्या आत फवारणी करणे अनिवार्य आहे.",
    },
    "healthy_corn": {
        "name_en": "Healthy Maize Crop",
        "name_mr": "निरोगी मका पीक",
        "crop_en": "Maize / Corn",
        "crop_mr": "मका",
        "severity_level": "healthy",
        "symptoms_en": "Vibrant green leaves, uniform growth, robust stalk, no fungal or pest damage detected.",
        "symptoms_mr": "पाने हिरवीगार, जोमदार वाढ, कोणतीही कीड अथवा रोगाचा प्रादुर्भाव नाही.",
        "chemical_treatment": [],
        "biological_treatment": [
            {
                "name_en": "19:19:19 NPK Water Soluble Foliar Spray",
                "name_mr": "१९:१९:१९ विद्राव्य खताची फवारणी (पोषण वाढीसाठी)",
                "dosage_per_liter": "5.0 g / L",
                "dosage_15l_pump": "७५ ग्रॅम प्रति १५ लिटर पंप",
            },
        ],
        "cultural_preventions_en": [
            "Continue scheduled irrigation every 8-10 days depending on soil moisture.",
            "Apply top-dressing Urea and Potash at Knee-high and Tasseling stages.",
        ],
        "cultural_preventions_mr": [
            "जमिनीतील ओलावा पाहून ८ ते १० दिवसांच्या अंतराने नियमित पाणी द्या.",
            "गुडघाभर उंचीच्या टप्प्यावर युरिया व पोटॅश खताचा दुसरा हप्ता द्या.",
        ],
        "urgency_action_en": "No chemical intervention needed. Maintain routine agronomic practices.",
        "urgency_action_mr": "कोणत्याही औषध फवारणीची गरज नाही. नियमित पाणी व खत व्यवस्थापन चालू ठेवा.",
    },
    "cotton_army_worm": {
        "name_en": "Fall Armyworm / Spodoptera frugiperda",
        "name_mr": "मका व कापूस लष्करी अळी (फॉलो आर्मीवर्म)",
        "crop_en": "Maize & Cotton",
        "crop_mr": "मका व कपाशी",
        "severity_level": "severe",
        "symptoms_en": "Ragged whorl feeding holes, sawdust-like fecal matter inside whorl, chewed central growing shoot.",
        "symptoms_mr": "मक्याच्या पोंग्यात मोठी छिद्रे, पानांची चाळण, पोंग्यात लाकडाच्या भुशासारखी विष्ठा आणि गाभ्यातील कोंब कुरतडणे.",
        "chemical_treatment": [
            {
                "name_en": "Chlorantraniliprole 18.5% SC (Coragen)",
                "name_mr": "क्लोरअँट्रानिलीप्रोल १८.५% एससी (कोराजन)",
                "dosage_per_liter": "0.4 ml / L",
                "dosage_15l_pump": "६ मिली प्रति १५ लिटर पंप (थेट पोंग्यात फवारणी)",
                "waiting_period_days": 14,
            },
            {
                "name_en": "Emamectin Benzoate 5% SG (Proclaim)",
                "name_mr": "इमामेक्टिन बेन्झोएट ५% एसजी (प्रोक्लेम)",
                "dosage_per_liter": "0.5 g / L",
                "dosage_15l_pump": "८-१० ग्रॅम प्रति १५ लिटर पंप",
                "waiting_period_days": 7,
            },
        ],
        "biological_treatment": [
            {
                "name_en": "Metarhizium anisopliae / Nomuraea rileyi",
                "name_mr": "मेटारायझियम अॅनिसोप्ली / नोमुरिया रिलेई (जैविक बुरशी)",
                "dosage_per_liter": "5 g / L",
                "dosage_15l_pump": "७५ ग्रॅम प्रति १५ लिटर पंप",
            },
            {
                "name_en": "Neem Seed Kernel Extract (NSKE 5%)",
                "name_mr": "५% निंबोळी अर्क (एनएसकेई)",
                "dosage_per_liter": "50 ml / L",
                "dosage_15l_pump": "७५० मिली प्रति १५ लिटर पंप",
            },
        ],
        "cultural_preventions_en": [
            "Install Pheromone Traps @ 5 traps per acre for pest monitoring.",
            "Apply sand mixed with lime (9:1) or wood ash into whorls.",
        ],
        "cultural_preventions_mr": [
            "शेतात एकरी ५ कामगंध सापळे (फेरोमोन ट्रॅप्स) लावा.",
            "लहान अवस्थेत पोंग्यात बारीक वाळू आणि चुन्याचे मिश्रण (९:१) किंवा लाकडी राख टाका.",
        ],
        "urgency_action_en": "Direct high-volume spray directly into the whorl early morning or evening.",
        "urgency_action_mr": "सकाळी किंवा संध्याकाळी नोझल पोंग्यावर ठेवून थेट पोंग्यात फवारणी करा.",
    },
}


def normalize_disease_key(name: str) -> str:
    return name.lower().replace("___", "_").replace(" ", "_").strip()


def get_disease_detail(class_name: str, language: str = "mr") -> Dict[str, Any]:
    key = normalize_disease_key(class_name)
    
    # 1. Exact match in specialized enriched base
    if key in DISEASE_KNOWLEDGE_BASE:
        info = DISEASE_KNOWLEDGE_BASE[key]
        return {
            "key": key,
            "name": info[f"name_{language}"] if f"name_{language}" in info else info["name_en"],
            "name_en": info["name_en"],
            "name_mr": info["name_mr"],
            "crop": info[f"crop_{language}"] if f"crop_{language}" in info else info["crop_en"],
            "severity_level": info["severity_level"],
            "symptoms": info[f"symptoms_{language}"] if f"symptoms_{language}" in info else info["symptoms_en"],
            "chemical_treatment": info["chemical_treatment"],
            "biological_treatment": info["biological_treatment"],
            "cultural_preventions": info[f"cultural_preventions_{language}"] if f"cultural_preventions_{language}" in info else info["cultural_preventions_en"],
            "urgency_action": info[f"urgency_action_{language}"] if f"urgency_action_{language}" in info else info["urgency_action_en"],
        }
    
    # 2. Match from general remedies.py with structured formatting
    raw_remedy = remedies.remedies.get(key, "Regular farm hygiene and crop inspection recommended.")
    is_healthy = "healthy" in key
    parts = key.split("_")
    crop_name = parts[0].capitalize() if parts else "Crop"
    disease_title = " ".join(parts[1:]).title() if len(parts) > 1 else key.title()
    
    if is_healthy:
        disease_title = f"Healthy {crop_name}"
        severity = "healthy"
    else:
        severity = "moderate"

    return {
        "key": key,
        "name": f"{crop_name} - {disease_title}",
        "name_en": f"{crop_name} - {disease_title}",
        "name_mr": f"{crop_name} - {disease_title}",
        "crop": crop_name,
        "severity_level": severity,
        "symptoms": "Leaf spots, discoloration, or lesions characteristic of fungal or pest infection." if not is_healthy else "Normal healthy leaf tissue.",
        "chemical_treatment": [
            {
                "name_en": raw_remedy,
                "name_mr": raw_remedy,
                "dosage_per_liter": "As per label recommendation",
                "dosage_15l_pump": "As per product pack label",
                "waiting_period_days": 10,
            }
        ] if not is_healthy else [],
        "biological_treatment": [
            {
                "name_en": "Neem Oil 10,000 PPM (2.5 ml / L)",
                "name_mr": "निम अर्क / निंबोळी तेल (२.५ मिली प्रति लिटर)",
                "dosage_per_liter": "2.5 ml / L",
                "dosage_15l_pump": "३५ मिली प्रति १५ लिटर पंप",
            }
        ] if not is_healthy else [],
        "cultural_preventions": [
            "Maintain adequate spacing between rows for ventilation.",
            "Remove and destroy infected plant debris promptly.",
        ],
        "urgency_action": "Inspect surrounding plants and apply preventative bio-fungicide." if not is_healthy else "No immediate action required.",
    }
