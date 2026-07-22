package com.agrovision.app.repository

import com.agrovision.app.model.DiseaseInfo

object RemediesRepository {

    private val diseaseDatabase: Map<String, DiseaseInfo> = mapOf(
        "corn_cercospora_leaf_spot" to DiseaseInfo(
            key = "corn_cercospora_leaf_spot",
            nameEn = "Corn Cercospora Leaf Spot",
            nameMr = "मक्याचा सर्कोस्पोरा पानांवरील ठिपके रोग",
            category = "Corn (मका)",
            chemicalRemedyEn = "Apply fungicides like Azoxystrobin or Pyraclostrobin. Spray at initial symptom appearance.",
            chemicalRemedyMr = "ॲझॉक्सीस्ट्रोबिन किंवा पायराक्लोस्ट्रोबिन सारख्या बुरशीनाशकांची फवारणी करा.",
            organicRemedyEn = "Spray Neem oil (5ml/L) or copper oxychloride. Ensure good sanitation.",
            organicRemedyMr = "कडुनिंबाचे तेल (५ मि.ली./लीटर) किंवा तांब्याची बुरशीनाशके वापरा.",
            preventionEn = "Practice crop rotation with non-host crops and remove infected plant debris.",
            preventionMr = "पिकांची आलटपालट करा आणि शेतातील बाधित अवशेष नष्ट करा."
        ),
        "corn_common_rust" to DiseaseInfo(
            key = "corn_common_rust",
            nameEn = "Corn Common Rust",
            nameMr = "मक्याचा तांबेरा रोग (Common Rust)",
            category = "Corn (मका)",
            chemicalRemedyEn = "Apply fungicides such as Tebuconazole or Mancozeb at early outbreak.",
            chemicalRemedyMr = "टेबुकॉनेझोल किंवा मँकोझेबची सुरुवातीलाच फवारणी करा.",
            organicRemedyEn = "Spray sulfur-based bio-fungicides or Trichoderma viride.",
            organicRemedyMr = "गंधक आधारित जैव-बुरशीनाशक किंवा ट्रायकोडेर्मा फवारा.",
            preventionEn = "Plant resistant corn hybrids and manage field humidity.",
            preventionMr = "रोगप्रतिकारक वाणांची निवड करा व शेतात योग्य हवा खेळती ठेवा."
        ),
        "corn_gray_leaf_spot" to DiseaseInfo(
            key = "corn_gray_leaf_spot",
            nameEn = "Corn Gray Leaf Spot",
            nameMr = "मक्याचा करपा रोग (Gray Leaf Spot)",
            category = "Corn (मका)",
            chemicalRemedyEn = "Use strobilurin or triazole fungicides during early silking phase.",
            chemicalRemedyMr = "स्ट्रोबिल्युरिन किंवा ट्रायझोल बुरशीनाशकांची फवारणी करा.",
            organicRemedyEn = "Use compost tea and bio-agents like Pseudomonas fluorescens.",
            organicRemedyMr = "कंपोस्ट टी आणि सेंद्रिय जिवाणू फवारणी करा.",
            preventionEn = "Use resistant varieties and practice minimum tillage with debris removal.",
            preventionMr = "प्रतिकारक वाण वापरा आणि पिकाचे अवशेष शेतात राहू देऊ नका."
        ),
        "corn_northern_leaf_blight" to DiseaseInfo(
            key = "corn_northern_leaf_blight",
            nameEn = "Corn Northern Leaf Blight",
            nameMr = "मक्याचा उत्तर पर्ण करपा (Northern Blight)",
            category = "Corn (मका)",
            chemicalRemedyEn = "Spray Propiconazole or Chlorothalonil before disease spreads.",
            chemicalRemedyMr = "प्रोपिकॉनेझोल किंवा क्लोरोथॅलोनिल बुरशीनाशक फवारा.",
            organicRemedyEn = "Apply Bacillus subtilis formulation on foliage.",
            organicRemedyMr = "बॅसिलस सुब्टिलिस या जिवाणूजन्य औषधाची फवारणी करा.",
            preventionEn = "Rotate crops for 2 years and clean harvest residue.",
            preventionMr = "२ वर्षे पिकांची फेरपालट करा आणि स्वच्छता ठेवा."
        ),
        "cotton_aphids" to DiseaseInfo(
            key = "cotton_aphids",
            nameEn = "Cotton Aphids Infestation",
            nameMr = "कापसावरील मावा कीड (Cotton Aphids)",
            category = "Cotton (कापूस)",
            chemicalRemedyEn = "Spray Imidacloprid 17.8 SL (3ml/10L) or Acetamiprid 20 SP.",
            chemicalRemedyMr = "इमिडाक्लोप्रिड १७.८ एसएल (३ मि.ली./१० लीटर) किंवा ॲसिटामिप्रिड फवारा.",
            organicRemedyEn = "Spray Neem seed kernel extract (NSKE 5%) or release Ladybird beetles.",
            organicRemedyMr = "निंबोळी अर्क (५%) ची फवारणी करा किंवा लेडीबर्ड भुंग्यांचा वापर करा.",
            preventionEn = "Avoid excessive nitrogen fertilizer and set up yellow sticky traps.",
            preventionMr = "नत्रयुक्त खतांचा अतिवापर टाळा आणि पिवळे चिकट सापळे लावा."
        ),
        "cotton_army_worm" to DiseaseInfo(
            key = "cotton_army_worm",
            nameEn = "Cotton Army Worm",
            nameMr = "कापसावरील लश्करी अळी (Army Worm)",
            category = "Cotton (कापूस)",
            chemicalRemedyEn = "Spray Emamectin Benzoate 5% SG or Chlorantraniliprole 18.5 SC.",
            chemicalRemedyMr = "इमामेक्टिन बेन्झोएट ५% एसजी किंवा क्लोरँट्रा्रानिलीप्रोल फवारा.",
            organicRemedyEn = "Use Bacillus thuringiensis (Bt) spray or Pheromone traps (5/acre).",
            organicRemedyMr = "बीटी (Bt) जिवाणू कीटकनाशक किंवा कामगंध सापळे (५ प्रति एकर) वापरा.",
            preventionEn = "Deep summer ploughing and destroy weed hosts around fields.",
            preventionMr = "उन्हाळ्यात खोल नांगरट करा व शेताच्या बांधावरील तण नष्ट करा."
        ),
        "cotton_bacterial_blight" to DiseaseInfo(
            key = "cotton_bacterial_blight",
            nameEn = "Cotton Bacterial Blight",
            nameMr = "कापसाचा जिवाणूजन्य करपा (Blackarm)",
            category = "Cotton (कापूस)",
            chemicalRemedyEn = "Spray Copper Oxychloride 50% WP (25g) + Streptocycline (1g) in 10L water.",
            chemicalRemedyMr = "कॉपर ऑक्सिक्लोराईड २५ ग्रॅम + स्ट्रिप्टोसायक्लीन १ ग्रॅम १० लीटर पाण्यात मिसळून फवारा.",
            organicRemedyEn = "Seed treatment with Pseudomonas fluorescens (10g/kg seed).",
            organicRemedyMr = "बियाण्यास सुडोमोनास फ्लूरोसन्सची (१० ग्रॅम/किग्रॅ) बीजप्रक्रिया करा.",
            preventionEn = "Use certified disease-free seeds and balanced potash fertilization.",
            preventionMr = "प्रमाणित बियाणे वापरा आणि पालाशयुक्त खतांचा वापर करा."
        ),
        "cotton_powdery_mildew" to DiseaseInfo(
            key = "cotton_powdery_mildew",
            nameEn = "Cotton Powdery Mildew",
            nameMr = "कापसावरील भुरी रोग (Powdery Mildew)",
            category = "Cotton (कापूस)",
            chemicalRemedyEn = "Spray Water Soluble Sulfur 80% WP (30g/10L) or Hexaconazole.",
            chemicalRemedyMr = "विद्राव्य गंधक ८०% डब्ल्यू.पी. (३० ग्रॅम/१० लीटर) किंवा हेक्साकोनॅझोल फवारा.",
            organicRemedyEn = "Spray Cow milk diluted in water (1:9) or baking soda solution.",
            organicRemedyMr = "गाईचे दूध व पाणी (१:९) चे द्रावण किंवा बेकिंग सोडा फवारा.",
            preventionEn = "Maintain proper spacing for sunlight and air flow.",
            preventionMr = "पिकात योग्य अंतर ठेवून सूर्यप्रकाश व हवा खेळती ठेवा."
        ),
        "cotton_target_spot" to DiseaseInfo(
            key = "cotton_target_spot",
            nameEn = "Cotton Target Spot",
            nameMr = "कापसावरील टार्गेट स्पॉट रोग",
            category = "Cotton (कापूस)",
            chemicalRemedyEn = "Apply Azoxystrobin or Fluxapyroxad fungicides.",
            chemicalRemedyMr = "ॲझॉक्सीस्ट्रोबिन किंवा फ्लक्सॅपायरोक्सॅड बुरशीनाशक फवारा.",
            organicRemedyEn = "Spray Trichoderma viride culture and prune lower yellowing foliage.",
            organicRemedyMr = "ट्रायकोडेर्मा विरिडी फवारा आणि खालील पिवळी पाने काढून टाका.",
            preventionEn = "Avoid dense planting and maintain canopy ventilation.",
            preventionMr = "दाट लागवड टाळा व पिकाच्या पानांमध्ये हवा खेळती ठेवा."
        ),
        "grape_black_rot" to DiseaseInfo(
            key = "grape_black_rot",
            nameEn = "Grape Black Rot",
            nameMr = "द्राक्षाचा काळा सड रोग (Black Rot)",
            category = "Grape (द्राक्ष)",
            chemicalRemedyEn = "Spray Mancozeb 75% WP or Myclobutanil early in the season.",
            chemicalRemedyMr = "मँकोझेब ७५% डब्ल्यू.पी. किंवा मायक्लोब्युटॅनिल फवारा.",
            organicRemedyEn = "Spray Copper liquid sprays and prune mummified berries.",
            organicRemedyMr = "तांब्याची बुरशीनाशके फवारा व सुकलेली द्राक्ष फळे काढून टाका.",
            preventionEn = "Remove all overwintering mummies and infected canes during pruning.",
            preventionMr = "छाटणीच्या वेळी वाळलेली फळे आणि बाधित काड्या नष्ट करा."
        ),
        "grape_esca_black_measles" to DiseaseInfo(
            key = "grape_esca_black_measles",
            nameEn = "Grape Esca (Black Measles)",
            nameMr = "द्राक्षावरील इस्का रोग (Black Measles)",
            category = "Grape (द्राक्ष)",
            chemicalRemedyEn = "Protect pruning wounds with fungicide pastes like Thiophanate-methyl.",
            chemicalRemedyMr = "छाटणीच्या जखमांवर थायोफॅनेट-मिथाईल लेप लावा.",
            organicRemedyEn = "Apply Trichoderma harzianum paste on pruning cuts.",
            organicRemedyMr = "छाटलेल्या काड्यांवर ट्रायकोडेर्मा हार्झियानम चा लेप लावा.",
            preventionEn = "Prune during dry weather and replace heavily trunk-cankered vines.",
            preventionMr = "कोरड्या हवामानात छाटणी करा व बाधित झाडे बदला."
        ),
        "grape_leaf_blight" to DiseaseInfo(
            key = "grape_leaf_blight",
            nameEn = "Grape Leaf Blight",
            nameMr = "द्राक्षाचा पानांवरील करपा (Leaf Blight)",
            category = "Grape (द्राक्ष)",
            chemicalRemedyEn = "Spray Bordeaux mixture 1% or Copper Oxychloride 50% WP.",
            chemicalRemedyMr = "बोर्डो मिश्रण १% किंवा कॉपर ऑक्सिक्लोराईड फवारा.",
            organicRemedyEn = "Spray Garlic extract combined with neem oil.",
            organicRemedyMr = "लसूण अर्क आणि निंबोळी तेलाचे मिश्रण फवारा.",
            preventionEn = "Ensure vine canopy allows wind movement and sunlight penetration.",
            preventionMr = "वेलींना पुरेशी हवा व सूर्यप्रकाश मिळेल अशी सोय करा."
        ),
        "groundnut_early_leaf_spot" to DiseaseInfo(
            key = "groundnut_early_leaf_spot",
            nameEn = "Groundnut Early Leaf Spot (Tikka)",
            nameMr = "भुईमुगाचा टिक्का रोग (लवकर येणारा करपा)",
            category = "Groundnut (भुईमूग)",
            chemicalRemedyEn = "Spray Carbendazim 12% + Mancozeb 63% WP (SAAF 2g/L).",
            chemicalRemedyMr = "कार्बेन्डाझिम १२% + मँकोझेब ६३% (साफ २ ग्रॅम/लीटर) फवारा.",
            organicRemedyEn = "Spray Panchagavya (3%) or Neem Leaf Extract (10%).",
            organicRemedyMr = "पंचगव्य (३%) किंवा निंबोळी पानांचा अर्क (१०%) फवारा.",
            preventionEn = "Rotate groundnut with cereal crops like sorghum or maize.",
            preventionMr = "ज्वारी किंवा मका या पिकांसोबत फेरपालट करा."
        ),
        "groundnut_late_leaf_spot" to DiseaseInfo(
            key = "groundnut_late_leaf_spot",
            nameEn = "Groundnut Late Leaf Spot",
            nameMr = "भुईमुगाचा उशिरा येणारा टिक्का रोग",
            category = "Groundnut (भुईमूग)",
            chemicalRemedyEn = "Spray Tebuconazole 25.9% EC or Chlorothalonil.",
            chemicalRemedyMr = "टेबुकॉनेझोल २५.९% ईसी किंवा क्लोरोथॅलोनिल फवारा.",
            organicRemedyEn = "Spray Trichoderma viride (5g/L) on affected crop leaves.",
            organicRemedyMr = "ट्रायकोडेर्मा विरिडी (५ ग्रॅम/लीटर) पानांवर फवारा.",
            preventionEn = "Destroy infected haulms post-harvest to kill fungus.",
            preventionMr = "काढणीनंतर पिकाचे उरलेले अवशेष जाळून टाका."
        ),
        "groundnut_nutrition_deficiency" to DiseaseInfo(
            key = "groundnut_nutrition_deficiency",
            nameEn = "Groundnut Nutrition Deficiency",
            nameMr = "भुईमुगातील पोषक तत्वांची कमतरता",
            category = "Groundnut (भुईमूग)",
            chemicalRemedyEn = "Apply Gypsum (500kg/ha) at pegging stage + micronutrient spray.",
            chemicalRemedyMr = "आऱ्या सुटण्याच्या वेळी जिप्सम (५०० किग्रॅ/हेक्टर) व सूक्ष्मअन्नद्रव्ये द्या.",
            organicRemedyEn = "Apply well-decomposed Farmyard Manure (FYM) and bio-fertilizers.",
            organicRemedyMr = "चांगले कुजलेले शेणखत आणि जिवाणू संवर्धक खते द्या.",
            preventionEn = "Conduct soil test and maintain optimal Calcium & Boron levels.",
            preventionMr = "माती परीक्षण करा व कॅल्शियम आणि बोरॉनचे प्रमाण योग्य ठेवा."
        ),
        "groundnut_rust" to DiseaseInfo(
            key = "groundnut_rust",
            nameEn = "Groundnut Rust",
            nameMr = "भुईमुगावरील तांबेरा (Groundnut Rust)",
            category = "Groundnut (भुईमूग)",
            chemicalRemedyEn = "Spray Propiconazole 25% EC (1ml/L) or Hexaconazole.",
            chemicalRemedyMr = "प्रोपिकॉनेझोल २५% ईसी (१ मि.ली./लीटर) किंवा हेक्साकोनॅझोल फवारा.",
            organicRemedyEn = "Spray Fermented buttermilk (Chaas 5%) mixed with neem oil.",
            organicRemedyMr = "आंबवलेले ताक (५%) आणि निंबोळी तेल फवारा.",
            preventionEn = "Avoid late sowing and use rust-resistant cultivars.",
            preventionMr = "उशिरा पेरणी टाळा आणि तांबेरा प्रतिकारक बियाणे वापरा."
        ),
        "lemon_anthracnose" to DiseaseInfo(
            key = "lemon_anthracnose",
            nameEn = "Lemon Anthracnose",
            nameMr = "लिंबाचा अँथ्रॅक्नोस रोग (फळ व फांदी करपा)",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Spray Copper Oxychloride 50% WP (3g/L) or Carbendazim.",
            chemicalRemedyMr = "कॉपर ऑक्सिक्लोराईड (३ ग्रॅम/लीटर) किंवा कार्बेन्डाझिम फवारा.",
            organicRemedyEn = "Prune dead twigs and spray Bordeaux mixture 1%.",
            organicRemedyMr = "सुकलेल्या फांद्या छाटा व १% बोर्डो मिश्रण फवारा.",
            preventionEn = "Ensure good aeration inside tree canopy and avoid wetting foliage.",
            preventionMr = "झाडांच्या गराड्यात हवा खेळती ठेवा व पाने जास्त ओली राहणार नाहीत याची काळजी घ्या."
        ),
        "lemon_bacterial_blight" to DiseaseInfo(
            key = "lemon_bacterial_blight",
            nameEn = "Lemon Bacterial Blight",
            nameMr = "लिंबाचा जिवाणूजन्य करपा रोग",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Spray Streptocycline (1g) + Copper Oxychloride (30g) in 10L water.",
            chemicalRemedyMr = "स्ट्रिप्टोसायक्लीन १ ग्रॅम + कॉपर ऑक्सिक्लोराईड ३० ग्रॅम १० लीटर पाण्यात मिसळून फवारा.",
            organicRemedyEn = "Prune infected branches with sterilized tools.",
            organicRemedyMr = "जंतूविरहित कात्रीने बाधित फांद्या छाटून टाका.",
            preventionEn = "Disinfect secateurs with bleaching powder solution between cuts.",
            preventionMr = "फांद्या छाटताना कात्री निर्जंतुक करून वापरा."
        ),
        "lemon_citrus_canker" to DiseaseInfo(
            key = "lemon_citrus_canker",
            nameEn = "Lemon Citrus Canker",
            nameMr = "लिंबावरील देवी रोग (Citrus Canker)",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Spray Streptocycline (1g/10L) along with Copper Hydroxide.",
            chemicalRemedyMr = "स्ट्रिप्टोसायक्लीन १ ग्रॅम आणि कॉपर हायड्रॉक्साईड फवारा.",
            organicRemedyEn = "Spray Neem cake extract and remove infected leaves/fruits.",
            organicRemedyMr = "खत म्हणून निंबोळी पेंड द्या व बाधित पाने/फळे काढून टाका.",
            preventionEn = "Control citrus leaf miner pest which spreads canker bacteria.",
            preventionMr = "देवी रोगाचा प्रसार करणाऱ्या पानांवरील अळीचे नियंत्रण करा."
        ),
        "lemon_curl_virus" to DiseaseInfo(
            key = "lemon_curl_virus",
            nameEn = "Lemon Leaf Curl Virus",
            nameMr = "लिंबाचा पर्णगुच्छ / पानांचा पीळ रोग (Leaf Curl Virus)",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Control vector insects: Spray Dimethoate 30 EC or Imidacloprid.",
            chemicalRemedyMr = "कीड प्रसारासाठी डायमेथोएट ३० ईसी किंवा इमिडाक्लोप्रिड फवारा.",
            organicRemedyEn = "Spray Neem oil (10ml/L) to prevent whiteflies and aphids.",
            organicRemedyMr = "मावा व पांढरी माशी रोखण्यासाठी निंबोळी तेल १० मि.ली./लीटर फवारा.",
            preventionEn = "Remove severely affected trees and use yellow sticky cards.",
            preventionMr = "बाधित रोपे काढून टाका व पिवळे सापळे लावा."
        ),
        "lemon_deficiency" to DiseaseInfo(
            key = "lemon_deficiency",
            nameEn = "Lemon Nutrient Deficiency",
            nameMr = "लिंबामधील पोषक तत्वांची कमतरता",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Spray Citrus Micronutrient mixture (Zn, Fe, Mn, Mg 5g/L).",
            chemicalRemedyMr = "लिंबूवर्ग सूक्ष्मअन्नद्रव्ये (जस्त, लोह, मॅंगनीज ५ ग्रॅम/लीटर) फवारा.",
            organicRemedyEn = "Apply Organic Vermicompost + Bio-fertilizers to root zone.",
            organicRemedyMr = "गांडूळ खत आणि जिवाणू खते मुळांशी द्या.",
            preventionEn = "Maintain soil pH between 6.5 - 7.5 and perform annual fertigation.",
            preventionMr = "मातीचा सामू (pH) योग्य ठेवा व नियमित खतमात्रा द्या."
        ),
        "lemon_dry_leaf" to DiseaseInfo(
            key = "lemon_dry_leaf",
            nameEn = "Lemon Dry Leaf / Wilting",
            nameMr = "लिंबाची पाने सुकणे (Dry Leaf)",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Apply Potassium Nitrate (13-0-45 10g/L) foliar spray.",
            chemicalRemedyMr = "पोटॅशियम नायट्रेड (१३-०-४५ १० ग्रॅम/लीटर) ची फवारणी करा.",
            organicRemedyEn = "Increase mulch depth around tree basin and irrigate properly.",
            organicRemedyMr = "झाडाभोवती आच्छादन (Mulching) करा व योग्य पाणी द्या.",
            preventionEn = "Avoid water logging and severe drought periods.",
            preventionMr = "अतिपाणी किंवा पाण्याचा ताण पिकाला बसू देऊ नका."
        ),
        "lemon_sooty_mould" to DiseaseInfo(
            key = "lemon_sooty_mould",
            nameEn = "Lemon Sooty Mould",
            nameMr = "लिंबावरील काळी बुरशी (Sooty Mould)",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Spray Starch solution (10g/L) or Chlorpyrifos to kill scale insects.",
            chemicalRemedyMr = "स्टार्च द्रावण (१० ग्रॅम/लीटर) फवारा व पिठ्या ढेकूण नियंत्रित करा.",
            organicRemedyEn = "Spray Maida paste (1kg maida in 15L water) to peel off soot.",
            organicRemedyMr = "मैद्याची खळ (१ किग्रॅ मैदा १५ लीटर पाण्यात) फवारल्यास काळी बुरशी गळून पडते.",
            preventionEn = "Control honeydew producing sucking pests like mealybugs.",
            preventionMr = "रस शोषणाऱ्या किडींचे (पिठ्या ढेकूण) वेळेवर नियंत्रण करा."
        ),
        "lemon_spider_mites" to DiseaseInfo(
            key = "lemon_spider_mites",
            nameEn = "Lemon Spider Mites Infestation",
            nameMr = "लिंबावरील लाल कोळी (Spider Mites)",
            category = "Lemon (लिंबू)",
            chemicalRemedyEn = "Spray Miticides like Spiromesifen 22.9 SC or Propargite.",
            chemicalRemedyMr = "स्पायरोमेसिफेन २२.९ एससी किंवा प्रोपार्गाईट कोळीनाशक फवारा.",
            organicRemedyEn = "Spray Neem oil 10,000 ppm (3ml/L) thoroughly under leaves.",
            organicRemedyMr = "पानांच्या खालच्या बाजूने निंबोळी तेल ३ मि.ली./लीटर फवारा.",
            preventionEn = "Avoid dust accumulation on foliage during dry seasons.",
            preventionMr = "उन्हाळ्यात पानांवर धूळ साचू देऊ नका."
        ),
        "potato_early_blight" to DiseaseInfo(
            key = "potato_early_blight",
            nameEn = "Potato Early Blight",
            nameMr = "बटाट्याचा लवकर येणारा करपा (Early Blight)",
            category = "Potato (बटाटा)",
            chemicalRemedyEn = "Spray Mancozeb 75% WP (2.5g/L) or Chlorothalonil.",
            chemicalRemedyMr = "मँकोझेब ७५% डब्ल्यू.पी. (२.५ ग्रॅम/लीटर) किंवा क्लोरोथॅलोनिल फवारा.",
            organicRemedyEn = "Spray Copper Hydroxide or bio-fungicide Trichoderma.",
            organicRemedyMr = "कॉपर हायड्रॉक्साईड किंवा ट्रायकोडेर्मा फवारा.",
            preventionEn = "Maintain high nitrogen & potassium fertility; rotate with non-solanaceous crops.",
            preventionMr = "योग्य नत्र-पालाश खते द्या व वांगी/टोमॅटो सोडून इतर पिकांची फेरपालट करा."
        ),
        "potato_late_blight" to DiseaseInfo(
            key = "potato_late_blight",
            nameEn = "Potato Late Blight",
            nameMr = "बटाट्याचा उशिरा येणारा महा-करपा (Late Blight)",
            category = "Potato (बटाटा)",
            chemicalRemedyEn = "Spray Cymoxanil + Mancozeb (Moximate) or Metalaxyl + Mancozeb (Ridomil).",
            chemicalRemedyMr = "सायमॉक्सॅनिल + मँकोझेब किंवा मेटलॅक्सिल + मँकोझेब (रिडोमिल) फवारा.",
            organicRemedyEn = "Spray Bordeaux Mixture 1% preventively before rain.",
            organicRemedyMr = "पावसाळ्यापूर्वी प्रतिबंधात्मक १% बोर्डो मिश्रण फवारा.",
            preventionEn = "Use certified healthy seed tubers and hill up soil around plant base.",
            preventionMr = "निरोगी बटाटा बियाणे वापरा व रोपांच्या मुळांशी मातीची भर द्या."
        ),
        "soyabean_sudden_death_syndrome" to DiseaseInfo(
            key = "soyabean_sudden_death_syndrome",
            nameEn = "Soybean Sudden Death Syndrome",
            nameMr = "सोयाबीनचा अचानक वाळण्याचा रोग (SDS)",
            category = "Soyabean (सोयाबीन)",
            chemicalRemedyEn = "Seed treatment with Fluopyram (ILeVO) fungicide.",
            chemicalRemedyMr = "फ्ल्युओपायरम बुरशीनाशकाची बियाण्यांवर प्रक्रिया करा.",
            organicRemedyEn = "Apply Trichoderma harzianum to soil at planting time.",
            organicRemedyMr = "पेरणीच्या वेळी जमिनीत ट्रायकोडेर्मा हार्झियानम मिसळा.",
            preventionEn = "Improve field drainage and plant SDS resistant soybean lines.",
            preventionMr = "शेतातील पाण्याचा निचरा सुधारा व प्रतिकारक वाण पेरा."
        ),
        "soyabean_bacterial_blight" to DiseaseInfo(
            key = "soyabean_bacterial_blight",
            nameEn = "Soybean Bacterial Blight",
            nameMr = "सोयाबीनचा जिवाणूजन्य तांबडा करपा",
            category = "Soyabean (सोयाबीन)",
            chemicalRemedyEn = "Spray Copper Oxychloride 50% WP (2.5g/L) + Streptocycline (1g/10L).",
            chemicalRemedyMr = "कॉपर ऑक्सिक्लोराईड २.५ ग्रॅम/लीटर + स्ट्रिप्टोसायक्लीन फवारा.",
            organicRemedyEn = "Spray Garlic-Chilli extract and avoid field work when wet.",
            organicRemedyMr = "लसूण-मिरची अर्क फवारा व पाने ओली असताना काम करणे टाळा.",
            preventionEn = "Avoid entering fields while foliage is wet to prevent bacterial spread.",
            preventionMr = "पानांवर दव किंवा पाणी असताना शेतात फिरणे टाळा."
        ),
        "sugarcane_bacterial_blight" to DiseaseInfo(
            key = "sugarcane_bacterial_blight",
            nameEn = "Sugarcane Bacterial Blight",
            nameMr = "ऊसाचा जिवाणूजन्य करपा रोग",
            category = "Sugarcane (ऊस)",
            chemicalRemedyEn = "Soak cane sets in hot water (50°C for 2 hours) + Copper spray.",
            chemicalRemedyMr = "ऊस बेणे ५० अंश सेल्सिअस गरम पाण्यात प्रक्रिया करा व तांब्याची बुरशीनाशके फवारा.",
            organicRemedyEn = "Dip setts in Trichoderma viride suspension before planting.",
            organicRemedyMr = "ऊसाचे कांडे पेरणीपूर्वी ट्रायकोडेर्मा द्रावणात बुडवा.",
            preventionEn = "Use disease-free nursery seed canes and sanitize harvesting sickles.",
            preventionMr = "निरोगी बेणे वापरा आणि कोयता/विळा निर्जंतुक करा."
        ),
        "sugarcane_mosaic" to DiseaseInfo(
            key = "sugarcane_mosaic",
            nameEn = "Sugarcane Mosaic Virus",
            nameMr = "ऊसाचा मोझॅक व्हायरस रोग (चितकबरा रोग)",
            category = "Sugarcane (ऊस)",
            chemicalRemedyEn = "No chemical cure for virus; Control Aphid vector with Malathion 50 EC.",
            chemicalRemedyMr = "विषाणूवर थेट औषध नाही; मावा कीड मारण्यासाठी मॅलाथिऑन ५० ईसी फवारा.",
            organicRemedyEn = "Rogue out infected clumps immediately and burn them.",
            organicRemedyMr = "बाधित ऊसाची खोडकी उपटून जाळून टाका.",
            preventionEn = "Plant tissue-culture disease-free cane seed sets.",
            preventionMr = "उती संवर्धित (Tissue Culture) निरोगी बेणे वापरा."
        ),
        "sugarcane_red_rot" to DiseaseInfo(
            key = "sugarcane_red_rot",
            nameEn = "Sugarcane Red Rot",
            nameMr = "ऊसाचा लाल कुज रोग (Red Rot - ऊसाचा कर्करोग)",
            category = "Sugarcane (ऊस)",
            chemicalRemedyEn = "Drench soil with Carbendazim 50% WP (1g/L) or Thiophanate-methyl.",
            chemicalRemedyMr = "कार्बेन्डाझिम ५०% डब्ल्यू.पी. (१ ग्रॅम/लीटर) चे द्रावण मुळाशी द्या.",
            organicRemedyEn = "Apply Trichoderma viride (2.5 kg/acre) mixed with FYM.",
            organicRemedyMr = "शेणखतात मिसळून ट्रायकोडेर्मा (२.५ किग्रॅ/एकर) जमिनीत द्या.",
            preventionEn = "Never use infected setts; grow resistant cane varieties like Co 86032.",
            preventionMr = "को ८६०३२ सारखे रोगप्रतिकारक वाण वापरा."
        ),
        "sugarcane_rust" to DiseaseInfo(
            key = "sugarcane_rust",
            nameEn = "Sugarcane Rust",
            nameMr = "ऊसावरील तांबेरा (Sugarcane Rust)",
            category = "Sugarcane (ऊस)",
            chemicalRemedyEn = "Spray Mancozeb 75% WP (2g/L) or Propiconazole 25 EC.",
            chemicalRemedyMr = "मँकोझेब ७५% (२ ग्रॅम/लीटर) किंवा प्रोपिकॉनेझोल २५ ईसी फवारा.",
            organicRemedyEn = "Spray Sulfur dust 25 kg/ha on foliage.",
            organicRemedyMr = "गंधक भुकटी २५ किग्रॅ/हेक्टर पानांवर टाका.",
            preventionEn = "Avoid over-irrigation and maintain optimum plant population.",
            preventionMr = "अतिपाणी देणे टाळा आणि ऊसात जास्त गर्दी होऊ देऊ नका."
        ),
        "sugarcane_yellow_leaf" to DiseaseInfo(
            key = "sugarcane_yellow_leaf_disease",
            nameEn = "Sugarcane Yellow Leaf Disease (YLD)",
            nameMr = "ऊसाचा पिवळा पान रोग (Yellow Leaf)",
            category = "Sugarcane (ऊस)",
            chemicalRemedyEn = "Control sugarcane aphids with Imidacloprid (4ml/10L).",
            chemicalRemedyMr = "मावा कीड नियंत्रणासाठी इमिडाक्लोप्रिड फवारा.",
            organicRemedyEn = "Foliar spray of micronutrients + Neem oil 5ml/L.",
            organicRemedyMr = "सूक्ष्मअन्नद्रव्ये व निंबोळी तेलाची फवारणी करा.",
            preventionEn = "Use heat-treated or meristem-derived disease-free cane seed.",
            preventionMr = "उष्णता प्रक्रिया केलेले बेणे वापरा."
        ),
        "tomato_bacterial_spot" to DiseaseInfo(
            key = "tomato_bacterial_spot",
            nameEn = "Tomato Bacterial Spot",
            nameMr = "टोमॅटोवरील जिवाणूजन्य ठिपके रोग",
            category = "Tomato (टोमॅटो)",
            chemicalRemedyEn = "Spray Copper Hydroxide (2g/L) mixed with Mancozeb.",
            chemicalRemedyMr = "कॉपर हायड्रॉक्साईड (२ ग्रॅम/लीटर) + मँकोझेब फवारा.",
            organicRemedyEn = "Spray Bacillus subtilis formulation on tomato canopy.",
            organicRemedyMr = "बॅसिलस सुब्टिलिस जैविक औषध फवारा.",
            preventionEn = "Use disease-free seeds and avoid overhead sprinkler watering.",
            preventionMr = "कारंजे पद्धतीने (Sprinkler) पाणी देणे टाळा."
        ),
        "tomato_early_blight" to DiseaseInfo(
            key = "tomato_early_blight",
            nameEn = "Tomato Early Blight",
            nameMr = "टोमॅटोचा लवकर येणारा करपा",
            category = "Tomato (टोमॅटो)",
            chemicalRemedyEn = "Spray Chlorothalonil 75% WP or Azoxystrobin.",
            chemicalRemedyMr = "क्लोरोथॅलोनिल ७५% किंवा ॲझॉक्सीस्ट्रोबिन फवारा.",
            organicRemedyEn = "Mulch around base and spray baking soda (5g/L) + soap.",
            organicRemedyMr = "झाडांच्या बुंध्याशी आच्छादन करा व बेकिंग सोडा फवारा.",
            preventionEn = "Prune lowest leaves to prevent soil splash onto foliage.",
            preventionMr = "खालची पाने छाटा जेणेकरून माती पानांवर उडणार नाही."
        ),
        "tomato_late_blight" to DiseaseInfo(
            key = "tomato_late_blight",
            nameEn = "Tomato Late Blight",
            nameMr = "टोमॅटोचा उशिरा येणारा महा-करपा",
            category = "Tomato (टोमॅटो)",
            chemicalRemedyEn = "Spray Dimethomorph 50% WP or Metalaxyl + Mancozeb.",
            chemicalRemedyMr = "डायमेथोमॉर्फ ५०% किंवा मेटलॅक्सिल + मँकोझेब (रिडोमिल) फवारा.",
            organicRemedyEn = "Spray Copper soap liquid fungicide at first sign.",
            organicRemedyMr = "तांबायुक्त द्रव बुरशीनाशक सुरुवातीलाच फवारा.",
            preventionEn = "Destroy infected vines immediately; avoid planting near potatoes.",
            preventionMr = "बटाटा पिकाजवळ टोमॅटोची लागवड करू नका."
        ),
        "tomato_septoria_leaf_spot" to DiseaseInfo(
            key = "tomato_septoria_leaf_spot",
            nameEn = "Tomato Septoria Leaf Spot",
            nameMr = "टोमॅटोवरील सेप्टोरिया ठिपके रोग",
            category = "Tomato (टोमॅटो)",
            chemicalRemedyEn = "Apply Mancozeb or Copper fungicides every 7-10 days.",
            chemicalRemedyMr = "मँकोझेब किंवा तांबायुक्त बुरशीनाशके ७-१० दिवसांनी फवारा.",
            organicRemedyEn = "Spray Bio-fungicide Trichoderma harzianum.",
            organicRemedyMr = "ट्रायकोडेर्मा हार्झियानम बुरशीनाशक फवारा.",
            preventionEn = "Clear all tomato plant crop debris at end of season.",
            preventionMr = "हंगाम संपल्यावर पिकाचे अवशेष पूर्ण साफ करा."
        ),
        "tomato_yellow_leaf_curl_virus" to DiseaseInfo(
            key = "tomato_yellow_leaf_curl_virus",
            nameEn = "Tomato Yellow Leaf Curl Virus (TYLCV)",
            nameMr = "टोमॅटोचा पिवळा चुराडा रोग (Leaf Curl)",
            category = "Tomato (टोमॅटो)",
            chemicalRemedyEn = "Control Whiteflies: Spray Cyantraniliprole 10.26 OD or Diafenthiuron.",
            chemicalRemedyMr = "पांढरी माशी मारण्यासाठी सायांट्रानिलीप्रोल किंवा डायफेन्थियुरॉन फवारा.",
            organicRemedyEn = "Use Yellow Sticky Traps (20/acre) + Neem Oil 10ml/L.",
            organicRemedyMr = "पिवळे चिकट सापळे (२०/एकर) आणि निंबोळी तेल फवारा.",
            preventionEn = "Use insect-proof net nurseries and TYLCV-tolerant tomato hybrids.",
            preventionMr = "रोपवाटिकेत ॲफिड नेट वापरा व सहनशील वाण लावा."
        ),
        "wheat_aphid" to DiseaseInfo(
            key = "wheat_aphid",
            nameEn = "Wheat Aphids Infestation",
            nameMr = "गव्हावरील मावा कीड (Wheat Aphid)",
            category = "Wheat (गहू)",
            chemicalRemedyEn = "Spray Thiamethoxam 25% WG (2g/10L) or Quinalphos.",
            chemicalRemedyMr = "थायमेथॉक्सम २५% डब्ल्यूजी (२ ग्रॅम/१० लीटर) फवारा.",
            organicRemedyEn = "Spray Neem Seed Kernel Extract 5% or soap water spray.",
            organicRemedyMr = "निंबोळी अर्क ५% किंवा साबणाचे पाणी पानांवर फवारा.",
            preventionEn = "Encourage natural aphid predators like Syrphid flies & Chrysoperla.",
            preventionMr = "मित्रकिडींचे (ढालभुंगे) शेतात संरक्षण करा."
        ),
        "wheat_black_rust" to DiseaseInfo(
            key = "wheat_black_rust",
            nameEn = "Wheat Black Rust (Stem Rust)",
            nameMr = "गव्हाचा काळा तांबेरा (Stem Rust)",
            category = "Wheat (गहू)",
            chemicalRemedyEn = "Spray Propiconazole 25 EC (1ml/L) or Tebuconazole.",
            chemicalRemedyMr = "प्रोपिकॉनेझोल २५ ईसी (१ मि.ली./लीटर) किंवा टेबुकॉनेझोल फवारा.",
            organicRemedyEn = "Foliar spray of Fermented Curd extract + Sulfur dust.",
            organicRemedyMr = "आंबट ताक व गंधक मिश्रणाची फवारणी करा.",
            preventionEn = "Grow rust-resistant wheat varieties (e.g. GW 322, HD 2967).",
            preventionMr = "प्रतिकारक गव्हाचे वाण पेरा (उदा. जीडब्ल्यू ३२२, एचडी २९६७)."
        ),
        "wheat_blast" to DiseaseInfo(
            key = "wheat_blast",
            nameEn = "Wheat Blast Disease",
            nameMr = "गव्हावरील ब्लास्ट रोग (Wheat Blast)",
            category = "Wheat (गहू)",
            chemicalRemedyEn = "Spray Tebuconazole + Trifloxystrobin (Nativo 0.8g/L).",
            chemicalRemedyMr = "टेबुकॉनेझोल + ट्रायफ्लॉक्सीस्ट्रोबिन (नेटिव्हो ०.८ ग्रॅम/लीटर) फवारा.",
            organicRemedyEn = "Seed treatment with Pseudomonas fluorescens (10g/kg).",
            organicRemedyMr = "बियाण्यास सुडोमोनासची (१० ग्रॅम/किग्रॅ) बीजप्रक्रिया करा.",
            preventionEn = "Avoid late sowing during high temperature-humidity windows.",
            preventionMr = "उशिरा पेरणी टाळा."
        ),
        "wheat_brown_rust" to DiseaseInfo(
            key = "wheat_brown_rust",
            nameEn = "Wheat Brown Rust (Leaf Rust)",
            nameMr = "गव्हाचा तांबडा / तपकिरी तांबेरा (Leaf Rust)",
            category = "Wheat (गहू)",
            chemicalRemedyEn = "Spray Mancozeb 75% WP (2g/L) or Propiconazole 25 EC.",
            chemicalRemedyMr = "मँकोझेब ७५% डब्ल्यू.पी. (२ ग्रॅम/लीटर) किंवा प्रोपिकॉनेझोल फवारा.",
            organicRemedyEn = "Spray Bio-fungicide Trichoderma viride.",
            organicRemedyMr = "ट्रायकोडेर्मा विरिडी जैव-बुरशीनाशक फवारा.",
            preventionEn = "Ensure balanced fertilization without excessive urea.",
            preventionMr = "युरियाचा प्रमाणाबाहेर वापर टाळा."
        ),
        "wheat_yellow_rust" to DiseaseInfo(
            key = "wheat_yellow_rust",
            nameEn = "Wheat Yellow Rust (Stripe Rust)",
            nameMr = "गव्हाचा पिवळा तांबेरा (Yellow Stripe Rust)",
            category = "Wheat (गहू)",
            chemicalRemedyEn = "Spray Propiconazole 25 EC (Tilt 1ml/L) immediately upon yellow stripe detection.",
            chemicalRemedyMr = "पिवळ्या पट्ट्या दिसताच प्रोपिकॉनेझोल २५ ईसी (टिल्ट १ मि.ली./लीटर) फवारा.",
            organicRemedyEn = "Spray Sulfur WP 80% (3g/L) on affected patches.",
            organicRemedyMr = "बाधित भागांवर गंधक ८०% डब्ल्यू.पी. फवारा.",
            preventionEn = "Sow early in season and monitor field regularly during cool moist weather.",
            preventionMr = "थंड हवामानात पिकाची नियमित पाहणी करा."
        )
    )

    fun getDiseaseInfo(rawClass: String?): DiseaseInfo {
        if (rawClass == null) return getHealthyDefault("healthy_crop")
        val cleanKey = rawClass.lowercase().trim()

        // Exact match
        diseaseDatabase[cleanKey]?.let { return it }

        // Partial key search
        for ((key, info) in diseaseDatabase) {
            if (cleanKey.contains(key) || key.contains(cleanKey)) {
                return info
            }
        }

        // Healthy checks
        if (cleanKey.contains("healthy")) {
            val cropName = cleanKey.replace("healthy_", "").replace("_healthy", "").capitalizeWords()
            return DiseaseInfo(
                key = cleanKey,
                nameEn = "$cropName - Healthy Crop",
                nameMr = "$cropName - निरोगी पीक (कोणताही रोग नाही)",
                category = cropName,
                chemicalRemedyEn = "No chemical remedy required. Your crop is healthy!",
                chemicalRemedyMr = "कोणत्याही रासायनिक औषधाची गरज नाही. तुमचे पीक अगदी निरोगी आहे!",
                organicRemedyEn = "Maintain routine organic fertilization and proper irrigation schedule.",
                organicRemedyMr = "नियमित सेंद्रिय खते व वेळेवर पाणी देत राहा.",
                preventionEn = "Continue monitoring crop leaves weekly.",
                preventionMr = "पिकाची आठवड्यातून एकदा पाहणी करत राहा."
            )
        }

        // Generic fallback for unmapped class
        val formattedTitle = cleanKey.replace("_", " ").capitalizeWords()
        return DiseaseInfo(
            key = cleanKey,
            nameEn = formattedTitle,
            nameMr = "$formattedTitle (रोग आढळला)",
            category = "General Crop",
            chemicalRemedyEn = "Consult a local Krishi Vigyan Kendra (KVK) officer for targeted broad-spectrum fungicide spray.",
            chemicalRemedyMr = "योग्य बुरशीनाशकाच्या सल्ल्यासाठी स्थानिक कृषी विज्ञान केंद्राशी संपर्क साधा.",
            organicRemedyEn = "Apply Neem oil 10,000 ppm (5ml/L) and ensure good field sanitation.",
            organicRemedyMr = "निंबोळी तेल ५ मि.ली./लीटर फवारा आणि शेतात स्वच्छता ठेवा.",
            preventionEn = "Destroy infected plant residue and rotate crops.",
            preventionMr = "बाधित अवशेष शेताबाहेर नेऊन जाळून टाका."
        )
    }

    private fun getHealthyDefault(key: String): DiseaseInfo {
        return DiseaseInfo(
            key = key,
            nameEn = "Healthy Crop",
            nameMr = "निरोगी पीक",
            category = "General",
            chemicalRemedyEn = "No chemical spray needed.",
            chemicalRemedyMr = "कोणत्याही औषधाची गरज नाही.",
            organicRemedyEn = "Keep up good farm management.",
            organicRemedyMr = "उत्तम शेत व्यवस्थापन चालू ठेवा.",
            preventionEn = "Regular crop inspection.",
            preventionMr = "पिकाची नियमित तपासणी करा."
        )
    }

    private fun String.capitalizeWords(): String {
        return split(" ").joinToString(" ") { word ->
            word.lowercase().replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        }
    }
}
