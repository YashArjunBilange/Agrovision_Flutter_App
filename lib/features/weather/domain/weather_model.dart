class CurrentWeatherModel {
  final double temperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final double windDirection;
  final int weatherCode;
  final String conditionEn;
  final String conditionMr;
  final String icon;

  const CurrentWeatherModel({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    required this.conditionEn,
    required this.conditionMr,
    required this.icon,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      humidity: json['humidity'] as int? ?? 65,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 8.0,
      windDirection: (json['wind_direction'] as num?)?.toDouble() ?? 180.0,
      weatherCode: json['weather_code'] as int? ?? 0,
      conditionEn: json['condition_en'] as String? ?? 'Clear',
      conditionMr: json['condition_mr'] as String? ?? 'निरभ्र',
      icon: json['icon'] as String? ?? 'sunny',
    );
  }
}

class SprayAdvisoryModel {
  final String status; // ideal, caution, unfavorable
  final int score;
  final String titleEn;
  final String titleMr;
  final String badgeColor;
  final List<String> reasonsEn;
  final List<String> reasonsMr;

  const SprayAdvisoryModel({
    required this.status,
    required this.score,
    required this.titleEn,
    required this.titleMr,
    required this.badgeColor,
    required this.reasonsEn,
    required this.reasonsMr,
  });

  factory SprayAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return SprayAdvisoryModel(
      status: json['status'] as String? ?? 'ideal',
      score: json['score'] as int? ?? 80,
      titleEn: json['title_en'] as String? ?? 'Ideal Spray Window',
      titleMr: json['title_mr'] as String? ?? 'फवारणीसाठी उत्तम वेळ',
      badgeColor: json['badge_color'] as String? ?? '#2E7D32',
      reasonsEn: (json['reasons_en'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reasonsMr: (json['reasons_mr'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AgriAlertModel {
  final String type;
  final String severity;
  final String titleEn;
  final String titleMr;
  final String descriptionEn;
  final String descriptionMr;
  final String actionEn;
  final String actionMr;

  const AgriAlertModel({
    required this.type,
    required this.severity,
    required this.titleEn,
    required this.titleMr,
    required this.descriptionEn,
    required this.descriptionMr,
    required this.actionEn,
    required this.actionMr,
  });

  factory AgriAlertModel.fromJson(Map<String, dynamic> json) {
    return AgriAlertModel(
      type: json['type'] as String? ?? 'general',
      severity: json['severity'] as String? ?? 'info',
      titleEn: json['title_en'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      descriptionMr: json['description_mr'] as String? ?? '',
      actionEn: json['action_en'] as String? ?? '',
      actionMr: json['action_mr'] as String? ?? '',
    );
  }
}

class HourlyForecastModel {
  final String time;
  final double temperature;
  final int humidity;
  final int precipitationProbability;
  final int weatherCode;
  final String conditionEn;
  final String conditionMr;
  final String icon;
  final double windSpeed;

  const HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.conditionEn,
    required this.conditionMr,
    required this.icon,
    required this.windSpeed,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      time: json['time'] as String? ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      humidity: json['humidity'] as int? ?? 60,
      precipitationProbability: json['precipitation_probability'] as int? ?? 0,
      weatherCode: json['weather_code'] as int? ?? 0,
      conditionEn: json['condition_en'] as String? ?? 'Clear',
      conditionMr: json['condition_mr'] as String? ?? 'निरभ्र',
      icon: json['icon'] as String? ?? 'sunny',
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 8.0,
    );
  }
}

class DailyForecastModel {
  final String date;
  final double tempMax;
  final double tempMin;
  final double precipitationSum;
  final int precipitationProbability;
  final int weatherCode;
  final String conditionEn;
  final String conditionMr;
  final String icon;
  final double windSpeedMax;

  const DailyForecastModel({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.conditionEn,
    required this.conditionMr,
    required this.icon,
    required this.windSpeedMax,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: json['date'] as String? ?? '',
      tempMax: (json['temp_max'] as num?)?.toDouble() ?? 30.0,
      tempMin: (json['temp_min'] as num?)?.toDouble() ?? 20.0,
      precipitationSum: (json['precipitation_sum'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability: json['precipitation_probability'] as int? ?? 0,
      weatherCode: json['weather_code'] as int? ?? 0,
      conditionEn: json['condition_en'] as String? ?? 'Clear',
      conditionMr: json['condition_mr'] as String? ?? 'निरभ्र',
      icon: json['icon'] as String? ?? 'sunny',
      windSpeedMax: (json['wind_speed_max'] as num?)?.toDouble() ?? 10.0,
    );
  }
}

class WeatherForecastModel {
  final double latitude;
  final double longitude;
  final String? farmName;
  final int? farmId;
  final CurrentWeatherModel current;
  final SprayAdvisoryModel sprayAdvisory;
  final List<AgriAlertModel> agriculturalAlerts;
  final List<HourlyForecastModel> hourlyForecast;
  final List<DailyForecastModel> dailyForecast;

  const WeatherForecastModel({
    required this.latitude,
    required this.longitude,
    this.farmName,
    this.farmId,
    required this.current,
    required this.sprayAdvisory,
    required this.agriculturalAlerts,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 19.75,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 75.71,
      farmName: json['farm_name'] as String?,
      farmId: json['farm_id'] as int?,
      current: CurrentWeatherModel.fromJson(json['current'] as Map<String, dynamic>),
      sprayAdvisory: SprayAdvisoryModel.fromJson(json['spray_advisory'] as Map<String, dynamic>),
      agriculturalAlerts: (json['agricultural_alerts'] as List<dynamic>?)
              ?.map((e) => AgriAlertModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hourlyForecast: (json['hourly_forecast'] as List<dynamic>?)
              ?.map((e) => HourlyForecastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyForecast: (json['daily_forecast'] as List<dynamic>?)
              ?.map((e) => DailyForecastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
