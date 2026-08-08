class AgriStore {
  final int id;
  final String nameEn;
  final String nameMr;
  final String dealerName;
  final String licenseNo;
  final String phone;
  final String? alternatePhone;
  final String addressEn;
  final String addressMr;
  final String taluka;
  final String district;
  final String pincode;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final double rating;
  final bool isVerified;
  final String openingHours;
  final double? distanceKm;

  const AgriStore({
    required this.id,
    required this.nameEn,
    required this.nameMr,
    required this.dealerName,
    required this.licenseNo,
    required this.phone,
    this.alternatePhone,
    required this.addressEn,
    required this.addressMr,
    required this.taluka,
    required this.district,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.categories,
    required this.rating,
    required this.isVerified,
    required this.openingHours,
    this.distanceKm,
  });

  factory AgriStore.fromJson(Map<String, dynamic> json) {
    return AgriStore(
      id: json['id'] as int,
      nameEn: json['name_en'] as String? ?? '',
      nameMr: json['name_mr'] as String? ?? '',
      dealerName: json['dealer_name'] as String? ?? '',
      licenseNo: json['license_no'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      alternatePhone: json['alternate_phone'] as String?,
      addressEn: json['address_en'] as String? ?? '',
      addressMr: json['address_mr'] as String? ?? '',
      taluka: json['taluka'] as String? ?? '',
      district: json['district'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      isVerified: json['is_verified'] as bool? ?? true,
      openingHours: json['opening_hours'] as String? ?? '08:00 AM - 08:00 PM',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}

class StoreListResponseModel {
  final List<AgriStore> stores;
  final int totalCount;
  final double? userLatitude;
  final double? userLongitude;

  const StoreListResponseModel({
    required this.stores,
    required this.totalCount,
    this.userLatitude,
    this.userLongitude,
  });

  factory StoreListResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreListResponseModel(
      stores: (json['stores'] as List<dynamic>?)
              ?.map((e) => AgriStore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['total_count'] as int? ?? 0,
      userLatitude: (json['user_latitude'] as num?)?.toDouble(),
      userLongitude: (json['user_longitude'] as num?)?.toDouble(),
    );
  }
}
