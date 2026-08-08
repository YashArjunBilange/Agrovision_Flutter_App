class FarmerProfileModel {
  final int? id;
  final int? userId;
  final String preferredLanguage;
  final String state;
  final String? district;
  final String? taluka;
  final String? village;
  final double totalLandAcres;
  final String? soilType;
  final String? irrigationType;
  final String? avatarUrl;

  const FarmerProfileModel({
    this.id,
    this.userId,
    this.preferredLanguage = 'mr',
    this.state = 'Maharashtra',
    this.district,
    this.taluka,
    this.village,
    this.totalLandAcres = 0.0,
    this.soilType,
    this.irrigationType,
    this.avatarUrl,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      preferredLanguage: json['preferred_language'] as String? ?? 'mr',
      state: json['state'] as String? ?? 'Maharashtra',
      district: json['district'] as String?,
      taluka: json['taluka'] as String?,
      village: json['village'] as String?,
      totalLandAcres: (json['total_land_acres'] as num?)?.toDouble() ?? 0.0,
      soilType: json['soil_type'] as String?,
      irrigationType: json['irrigation_type'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'preferred_language': preferredLanguage,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'total_land_acres': totalLandAcres,
      'soil_type': soilType,
      'irrigation_type': irrigationType,
      'avatar_url': avatarUrl,
    };
  }

  FarmerProfileModel copyWith({
    int? id,
    int? userId,
    String? preferredLanguage,
    String? state,
    String? district,
    String? taluka,
    String? village,
    double? totalLandAcres,
    String? soilType,
    String? irrigationType,
    String? avatarUrl,
  }) {
    return FarmerProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      state: state ?? this.state,
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      village: village ?? this.village,
      totalLandAcres: totalLandAcres ?? this.totalLandAcres,
      soilType: soilType ?? this.soilType,
      irrigationType: irrigationType ?? this.irrigationType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class UserModel {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final bool isActive;
  final bool isVerified;
  final String role;
  final FarmerProfileModel? profile;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.isActive = true,
    this.isVerified = false,
    this.role = 'farmer',
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      role: json['role'] as String? ?? 'farmer',
      profile: json['profile'] != null
          ? FarmerProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'is_active': isActive,
      'is_verified': isVerified,
      'role': role,
      'profile': profile?.toJson(),
    };
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? phone,
    String? email,
    bool? isActive,
    bool? isVerified,
    String? role,
    FarmerProfileModel? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      profile: profile ?? this.profile,
    );
  }
}

class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserModel user;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    required this.user,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
