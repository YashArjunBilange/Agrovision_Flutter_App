class NdviData {
  final double mean;
  final double min;
  final double max;

  const NdviData({
    required this.mean,
    required this.min,
    required this.max,
  });

  factory NdviData.fromJson(Map<String, dynamic> json) {
    return NdviData(
      mean: (json['mean'] as num).toDouble(),
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );
  }
}

class SatelliteObservation {
  final int id;
  final int farmId;
  final DateTime observationDate;
  final double cloudCover;
  final String satellite;
  final String? trueColorImageUrl;
  final String? ndviImageUrl;
  final NdviData? ndvi;

  const SatelliteObservation({
    required this.id,
    required this.farmId,
    required this.observationDate,
    required this.cloudCover,
    required this.satellite,
    this.trueColorImageUrl,
    this.ndviImageUrl,
    this.ndvi,
  });

  factory SatelliteObservation.fromJson(Map<String, dynamic> json) {
    return SatelliteObservation(
      id: json['id'] as int,
      farmId: json['farm_id'] as int,
      observationDate: DateTime.parse(json['observation_date'] as String),
      cloudCover: (json['cloud_cover'] as num).toDouble(),
      satellite: json['satellite'] as String,
      trueColorImageUrl: json['true_color_image_url'] as String?,
      ndviImageUrl: json['ndvi_image_url'] as String?,
      ndvi: json['ndvi'] != null ? NdviData.fromJson(json['ndvi'] as Map<String, dynamic>) : null,
    );
  }
}

class SatelliteHistory {
  final int farmId;
  final List<SatelliteObservation> history;

  const SatelliteHistory({
    required this.farmId,
    required this.history,
  });

  factory SatelliteHistory.fromJson(Map<String, dynamic> json) {
    return SatelliteHistory(
      farmId: json['farm_id'] as int,
      history: (json['history'] as List)
          .map((e) => SatelliteObservation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
