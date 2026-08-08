class PestThreat {
  final String threatEn;
  final String threatMr;
  final String actionEn;
  final String actionMr;

  const PestThreat({
    required this.threatEn,
    required this.threatMr,
    required this.actionEn,
    required this.actionMr,
  });

  factory PestThreat.fromJson(Map<String, dynamic> json) {
    return PestThreat(
      threatEn: json['threat_en'] as String? ?? '',
      threatMr: json['threat_mr'] as String? ?? '',
      actionEn: json['action_en'] as String? ?? '',
      actionMr: json['action_mr'] as String? ?? '',
    );
  }
}

class NpkRecommendation {
  final String titleEn;
  final String titleMr;
  final Map<String, dynamic> perAcreKg;
  final String instructionEn;
  final String instructionMr;

  const NpkRecommendation({
    required this.titleEn,
    required this.titleMr,
    required this.perAcreKg,
    required this.instructionEn,
    required this.instructionMr,
  });

  factory NpkRecommendation.fromJson(Map<String, dynamic> json) {
    return NpkRecommendation(
      titleEn: json['title_en'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      perAcreKg: (json['per_acre_kg'] as Map<String, dynamic>?) ?? {},
      instructionEn: json['instruction_en'] as String? ?? '',
      instructionMr: json['instruction_mr'] as String? ?? '',
    );
  }
}

class CropStageModel {
  final String stageId;
  final int order;
  final String nameEn;
  final String nameMr;
  final int dayRangeMin;
  final int dayRangeMax;
  final String descriptionEn;
  final String descriptionMr;
  final NpkRecommendation? npkRecommendation;
  final String irrigationAdviceEn;
  final String irrigationAdviceMr;
  final String waterSensitivity;
  final List<PestThreat> pestDiseaseWatch;

  const CropStageModel({
    required this.stageId,
    required this.order,
    required this.nameEn,
    required this.nameMr,
    required this.dayRangeMin,
    required this.dayRangeMax,
    required this.descriptionEn,
    required this.descriptionMr,
    this.npkRecommendation,
    required this.irrigationAdviceEn,
    required this.irrigationAdviceMr,
    required this.waterSensitivity,
    required this.pestDiseaseWatch,
  });

  factory CropStageModel.fromJson(Map<String, dynamic> json) {
    return CropStageModel(
      stageId: json['stage_id'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      nameEn: json['name_en'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? '',
      dayRangeMin: json['day_range_min'] as int? ?? 0,
      dayRangeMax: json['day_range_max'] as int? ?? 15,
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionMr: json['description_mr'] as String? ?? '',
      npkRecommendation: json['npk_recommendation'] != null
          ? NpkRecommendation.fromJson(json['npk_recommendation'] as Map<String, dynamic>)
          : null,
      irrigationAdviceEn: json['irrigation_advice_en'] as String? ?? '',
      irrigationAdviceMr: json['irrigation_advice_mr'] as String? ?? '',
      waterSensitivity: json['water_sensitivity'] as String? ?? 'Moderate',
      pestDiseaseWatch: (json['pest_disease_watch'] as List<dynamic>?)
              ?.map((e) => PestThreat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CropTaskModel {
  final int id;
  final int cropCycleId;
  final String stageId;
  final String stageNameEn;
  final String stageNameMr;
  final String titleEn;
  final String titleMr;
  final String taskType;
  final int dueDaysAfterSowing;
  final String? dueDate;
  final bool isCompleted;
  final String? completedAt;
  final String? notes;

  const CropTaskModel({
    required this.id,
    required this.cropCycleId,
    required this.stageId,
    required this.stageNameEn,
    required this.stageNameMr,
    required this.titleEn,
    required this.titleMr,
    required this.taskType,
    required this.dueDaysAfterSowing,
    this.dueDate,
    required this.isCompleted,
    this.completedAt,
    this.notes,
  });

  factory CropTaskModel.fromJson(Map<String, dynamic> json) {
    return CropTaskModel(
      id: json['id'] as int,
      cropCycleId: json['crop_cycle_id'] as int,
      stageId: json['stage_id'] as String? ?? '',
      stageNameEn: json['stage_name_en'] as String? ?? '',
      stageNameMr: json['stage_name_mr'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      taskType: json['task_type'] as String? ?? 'cultural',
      dueDaysAfterSowing: json['due_days_after_sowing'] as int? ?? 0,
      dueDate: json['due_date'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] as String?,
      notes: json['notes'] as String?,
    );
  }

  CropTaskModel copyWith({bool? isCompleted, String? completedAt}) {
    return CropTaskModel(
      id: id,
      cropCycleId: cropCycleId,
      stageId: stageId,
      stageNameEn: stageNameEn,
      stageNameMr: stageNameMr,
      titleEn: titleEn,
      titleMr: titleMr,
      taskType: taskType,
      dueDaysAfterSowing: dueDaysAfterSowing,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notes: notes,
    );
  }
}

class CropCycleModel {
  final int id;
  final int userId;
  final int farmId;
  final String cropName;
  final String? varietyName;
  final String season;
  final String sowingDate;
  final String? expectedHarvestDate;
  final String status;
  final int daysSinceSowing;
  final double progressPercentage;
  final CropStageModel currentStage;
  final List<CropTaskModel> tasks;

  const CropCycleModel({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.cropName,
    this.varietyName,
    required this.season,
    required this.sowingDate,
    this.expectedHarvestDate,
    required this.status,
    required this.daysSinceSowing,
    required this.progressPercentage,
    required this.currentStage,
    required this.tasks,
  });

  factory CropCycleModel.fromJson(Map<String, dynamic> json) {
    return CropCycleModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      farmId: json['farm_id'] as int,
      cropName: json['crop_name'] as String? ?? 'Maize',
      varietyName: json['variety_name'] as String?,
      season: json['season'] as String? ?? 'Kharif',
      sowingDate: json['sowing_date'] as String? ?? '',
      expectedHarvestDate: json['expected_harvest_date'] as String?,
      status: json['status'] as String? ?? 'active',
      daysSinceSowing: json['days_since_sowing'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      currentStage: CropStageModel.fromJson(json['current_stage'] as Map<String, dynamic>),
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => CropTaskModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FertilizerCalculationModel {
  final String? titleEn;
  final String? titleMr;
  final double acreage;
  final Map<String, dynamic> fertilizersKg;
  final String? instructionEn;
  final String? instructionMr;

  const FertilizerCalculationModel({
    this.titleEn,
    this.titleMr,
    required this.acreage,
    required this.fertilizersKg,
    this.instructionEn,
    this.instructionMr,
  });

  factory FertilizerCalculationModel.fromJson(Map<String, dynamic> json) {
    return FertilizerCalculationModel(
      titleEn: json['title_en'] as String?,
      titleMr: json['title_mr'] as String?,
      acreage: (json['acreage'] as num?)?.toDouble() ?? 1.0,
      fertilizersKg: (json['fertilizers_kg'] as Map<String, dynamic>?) ?? {},
      instructionEn: json['instruction_en'] as String?,
      instructionMr: json['instruction_mr'] as String?,
    );
  }
}
