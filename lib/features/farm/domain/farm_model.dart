class FarmModel {
  final int id;
  final int userId;
  final String name;
  final double areaAcres;
  final double? latitude;
  final double? longitude;
  final String state;
  final String? district;
  final String? taluka;
  final String? village;
  final String? pincode;
  final String? surveyNumber;
  final String? soilType;
  final double? soilPh;
  final double? soilOrganicCarbon;
  final String? irrigationType;
  final String? waterSource;
  final bool isActive;
  final bool isPrimary;
  final String? notes;
  final String? polygonGeojson;
  final double? areaSqm;
  final double? areaHectares;
  final double? perimeterMeters;
  final double? lengthMeters;
  final double? widthMeters;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FarmModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.areaAcres,
    this.latitude,
    this.longitude,
    this.state = 'Maharashtra',
    this.district,
    this.taluka,
    this.village,
    this.pincode,
    this.surveyNumber,
    this.soilType,
    this.soilPh,
    this.soilOrganicCarbon,
    this.irrigationType,
    this.waterSource,
    this.isActive = true,
    this.isPrimary = false,
    this.notes,
    this.polygonGeojson,
    this.areaSqm,
    this.areaHectares,
    this.perimeterMeters,
    this.lengthMeters,
    this.widthMeters,
    this.createdAt,
    this.updatedAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      areaAcres: (json['area_acres'] as num).toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      state: json['state'] as String? ?? 'Maharashtra',
      district: json['district'] as String?,
      taluka: json['taluka'] as String?,
      village: json['village'] as String?,
      pincode: json['pincode'] as String?,
      surveyNumber: json['survey_number'] as String?,
      soilType: json['soil_type'] as String?,
      soilPh: (json['soil_ph'] as num?)?.toDouble(),
      soilOrganicCarbon: (json['soil_organic_carbon'] as num?)?.toDouble(),
      irrigationType: json['irrigation_type'] as String?,
      waterSource: json['water_source'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isPrimary: json['is_primary'] as bool? ?? false,
      notes: json['notes'] as String?,
      polygonGeojson: json['polygon_geojson'] as String?,
      areaSqm: (json['area_sqm'] as num?)?.toDouble(),
      areaHectares: (json['area_hectares'] as num?)?.toDouble(),
      perimeterMeters: (json['perimeter_meters'] as num?)?.toDouble(),
      lengthMeters: (json['length_meters'] as num?)?.toDouble(),
      widthMeters: (json['width_meters'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'area_acres': areaAcres,
      'latitude': latitude,
      'longitude': longitude,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'pincode': pincode,
      'survey_number': surveyNumber,
      'soil_type': soilType,
      'soil_ph': soilPh,
      'soil_organic_carbon': soilOrganicCarbon,
      'irrigation_type': irrigationType,
      'water_source': waterSource,
      'is_active': isActive,
      'is_primary': isPrimary,
      'notes': notes,
      'polygon_geojson': polygonGeojson,
      'area_sqm': areaSqm,
      'area_hectares': areaHectares,
      'perimeter_meters': perimeterMeters,
      'length_meters': lengthMeters,
      'width_meters': widthMeters,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  FarmModel copyWith({
    int? id,
    int? userId,
    String? name,
    double? areaAcres,
    double? latitude,
    double? longitude,
    String? state,
    String? district,
    String? taluka,
    String? village,
    String? pincode,
    String? surveyNumber,
    String? soilType,
    double? soilPh,
    double? soilOrganicCarbon,
    String? irrigationType,
    String? waterSource,
    bool? isActive,
    bool? isPrimary,
    String? notes,
    String? polygonGeojson,
    double? areaSqm,
    double? areaHectares,
    double? perimeterMeters,
    double? lengthMeters,
    double? widthMeters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      areaAcres: areaAcres ?? this.areaAcres,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      state: state ?? this.state,
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      village: village ?? this.village,
      pincode: pincode ?? this.pincode,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      soilType: soilType ?? this.soilType,
      soilPh: soilPh ?? this.soilPh,
      soilOrganicCarbon: soilOrganicCarbon ?? this.soilOrganicCarbon,
      irrigationType: irrigationType ?? this.irrigationType,
      waterSource: waterSource ?? this.waterSource,
      isActive: isActive ?? this.isActive,
      isPrimary: isPrimary ?? this.isPrimary,
      notes: notes ?? this.notes,
      polygonGeojson: polygonGeojson ?? this.polygonGeojson,
      areaSqm: areaSqm ?? this.areaSqm,
      areaHectares: areaHectares ?? this.areaHectares,
      perimeterMeters: perimeterMeters ?? this.perimeterMeters,
      lengthMeters: lengthMeters ?? this.lengthMeters,
      widthMeters: widthMeters ?? this.widthMeters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
