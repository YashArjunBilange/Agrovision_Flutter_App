class ChemicalTreatment {
  final String nameEn;
  final String nameMr;
  final String dosagePerLiter;
  final String dosage15lPump;
  final int? waitingPeriodDays;

  const ChemicalTreatment({
    required this.nameEn,
    required this.nameMr,
    required this.dosagePerLiter,
    required this.dosage15lPump,
    this.waitingPeriodDays,
  });

  factory ChemicalTreatment.fromJson(Map<String, dynamic> json) {
    return ChemicalTreatment(
      nameEn: json['name_en'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? json['name_en'] as String? ?? '',
      dosagePerLiter: json['dosage_per_liter'] as String? ?? '',
      dosage15lPump: json['dosage_15l_pump'] as String? ?? '',
      waitingPeriodDays: json['waiting_period_days'] as int?,
    );
  }
}

class BiologicalTreatment {
  final String nameEn;
  final String nameMr;
  final String dosagePerLiter;
  final String dosage15lPump;

  const BiologicalTreatment({
    required this.nameEn,
    required this.nameMr,
    required this.dosagePerLiter,
    required this.dosage15lPump,
  });

  factory BiologicalTreatment.fromJson(Map<String, dynamic> json) {
    return BiologicalTreatment(
      nameEn: json['name_en'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? json['name_en'] as String? ?? '',
      dosagePerLiter: json['dosage_per_liter'] as String? ?? '',
      dosage15lPump: json['dosage_15l_pump'] as String? ?? '',
    );
  }
}

class DiseaseDetail {
  final String key;
  final String name;
  final String nameEn;
  final String nameMr;
  final String crop;
  final String severityLevel;
  final String symptoms;
  final List<ChemicalTreatment> chemicalTreatment;
  final List<BiologicalTreatment> biologicalTreatment;
  final List<String> culturalPreventions;
  final String urgencyAction;

  const DiseaseDetail({
    required this.key,
    required this.name,
    required this.nameEn,
    required this.nameMr,
    required this.crop,
    required this.severityLevel,
    required this.symptoms,
    required this.chemicalTreatment,
    required this.biologicalTreatment,
    required this.culturalPreventions,
    required this.urgencyAction,
  });

  factory DiseaseDetail.fromJson(Map<String, dynamic> json) {
    return DiseaseDetail(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? '',
      crop: json['crop'] as String? ?? '',
      severityLevel: json['severity_level'] as String? ?? 'moderate',
      symptoms: json['symptoms'] as String? ?? '',
      chemicalTreatment: (json['chemical_treatment'] as List<dynamic>?)
              ?.map((e) => ChemicalTreatment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      biologicalTreatment: (json['biological_treatment'] as List<dynamic>?)
              ?.map((e) => BiologicalTreatment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      culturalPreventions: (json['cultural_preventions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      urgencyAction: json['urgency_action'] as String? ?? '',
    );
  }
}

class TopPrediction {
  final int classId;
  final String className;
  final String normalizedName;
  final double confidence;
  final double confidencePercentage;

  const TopPrediction({
    required this.classId,
    required this.className,
    required this.normalizedName,
    required this.confidence,
    required this.confidencePercentage,
  });

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      classId: json['class_id'] as int? ?? 0,
      className: json['class_name'] as String? ?? '',
      normalizedName: json['normalized_name'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      confidencePercentage: (json['confidence_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DiagnosisResult {
  final bool success;
  final int classId;
  final String className;
  final String normalizedName;
  final double confidence;
  final double confidencePercentage;
  final bool isHealthy;
  final int? scanId;
  final int? farmId;
  final List<TopPrediction> topKPredictions;
  final DiseaseDetail diagnosis;
  final String? localImagePath;

  const DiagnosisResult({
    required this.success,
    required this.classId,
    required this.className,
    required this.normalizedName,
    required this.confidence,
    required this.confidencePercentage,
    required this.isHealthy,
    this.scanId,
    this.farmId,
    required this.topKPredictions,
    required this.diagnosis,
    this.localImagePath,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json, {String? localImagePath}) {
    return DiagnosisResult(
      success: json['success'] as bool? ?? true,
      classId: json['class_id'] as int? ?? 0,
      className: json['class_name'] as String? ?? '',
      normalizedName: json['normalized_name'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      confidencePercentage: (json['confidence_percentage'] as num?)?.toDouble() ?? 0.0,
      isHealthy: json['is_healthy'] as bool? ?? false,
      scanId: json['scan_id'] as int?,
      farmId: json['farm_id'] as int?,
      topKPredictions: (json['top_k_predictions'] as List<dynamic>?)
              ?.map((e) => TopPrediction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      diagnosis: DiseaseDetail.fromJson(json['diagnosis'] as Map<String, dynamic>),
      localImagePath: localImagePath,
    );
  }
}

class ScanHistoryItem {
  final int id;
  final int userId;
  final int? farmId;
  final String? imageFilename;
  final String diseaseKey;
  final String diseaseNameEn;
  final String diseaseNameMr;
  final String cropName;
  final double confidence;
  final String severityLevel;
  final bool isHealthy;
  final String? remedySummary;
  final DateTime? createdAt;

  const ScanHistoryItem({
    required this.id,
    required this.userId,
    this.farmId,
    this.imageFilename,
    required this.diseaseKey,
    required this.diseaseNameEn,
    required this.diseaseNameMr,
    required this.cropName,
    required this.confidence,
    required this.severityLevel,
    required this.isHealthy,
    this.remedySummary,
    this.createdAt,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      farmId: json['farm_id'] as int?,
      imageFilename: json['image_filename'] as String?,
      diseaseKey: json['disease_key'] as String? ?? '',
      diseaseNameEn: json['disease_name_en'] as String? ?? '',
      diseaseNameMr: json['disease_name_mr'] as String? ?? '',
      cropName: json['crop_name'] as String? ?? 'Maize',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severityLevel: json['severity_level'] as String? ?? 'moderate',
      isHealthy: json['is_healthy'] as bool? ?? false,
      remedySummary: json['remedy_summary'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }
}
