class CropRecommendationItemModel {
  final String cropId;
  final String nameEn;
  final String nameMr;
  final String category;
  final double matchScore;
  final String tierEn;
  final String tierMr;
  final String badgeColor;
  final String durationDays;
  final String estimatedYieldPerAcre;
  final String profitPotentialPerAcre;
  final String descriptionEn;
  final String descriptionMr;
  final List<String> advantagesEn;
  final List<String> advantagesMr;

  const CropRecommendationItemModel({
    required this.cropId,
    required this.nameEn,
    required this.nameMr,
    required this.category,
    required this.matchScore,
    required this.tierEn,
    required this.tierMr,
    required this.badgeColor,
    required this.durationDays,
    required this.estimatedYieldPerAcre,
    required this.profitPotentialPerAcre,
    required this.descriptionEn,
    required this.descriptionMr,
    required this.advantagesEn,
    required this.advantagesMr,
  });

  factory CropRecommendationItemModel.fromJson(Map<String, dynamic> json) {
    return CropRecommendationItemModel(
      cropId: json['crop_id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? '',
      category: json['category'] as String? ?? '',
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 50.0,
      tierEn: json['tier_en'] as String? ?? 'Suitable',
      tierMr: json['tier_mr'] as String? ?? 'अनुकूल',
      badgeColor: json['badge_color'] as String? ?? '#2E7D32',
      durationDays: json['duration_days'] as String? ?? '',
      estimatedYieldPerAcre: json['estimated_yield_per_acre'] as String? ?? '',
      profitPotentialPerAcre: json['profit_potential_per_acre'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionMr: json['description_mr'] as String? ?? '',
      advantagesEn: (json['advantages_en'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      advantagesMr: (json['advantages_mr'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CropRecommendationResponseModel {
  final List<CropRecommendationItemModel> recommendations;
  final String analyzedSeason;
  final String analyzedSoil;

  const CropRecommendationResponseModel({
    required this.recommendations,
    required this.analyzedSeason,
    required this.analyzedSoil,
  });

  factory CropRecommendationResponseModel.fromJson(Map<String, dynamic> json) {
    return CropRecommendationResponseModel(
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => CropRecommendationItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      analyzedSeason: json['analyzed_season'] as String? ?? 'Kharif',
      analyzedSoil: json['analyzed_soil'] as String? ?? 'Medium Black',
    );
  }
}

class CropRecommendationRequestModel {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double temperature;
  final double rainfall;
  final String season;
  final String soilType;
  final bool irrigationAvailable;
  final int? farmId;

  const CropRecommendationRequestModel({
    this.nitrogen = 80.0,
    this.phosphorus = 40.0,
    this.potassium = 40.0,
    this.ph = 6.8,
    this.temperature = 28.0,
    this.rainfall = 750.0,
    this.season = 'Kharif',
    this.soilType = 'Medium Black',
    this.irrigationAvailable = true,
    this.farmId,
  });

  Map<String, dynamic> toJson() => {
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'ph': ph,
        'temperature': temperature,
        'rainfall': rainfall,
        'season': season,
        'soil_type': soilType,
        'irrigation_available': irrigationAvailable,
        if (farmId != null) 'farm_id': farmId,
      };
}
