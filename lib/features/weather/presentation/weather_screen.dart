import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/weather_model.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'हवामान अंदाज व कृषी सल्ला' : 'Weather & Agri Intelligence',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isMr ? 'ताजे करा' : 'Refresh',
            onPressed: () {
              ref.invalidate(currentWeatherProvider);
            },
          ),
        ],
      ),
      body: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              Text(isMr ? 'हवामान माहिती लोड करता आली नाही' : 'Failed to load weather data'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentWeatherProvider),
                child: Text(isMr ? 'पुन्हा प्रयत्न करा' : 'Retry'),
              ),
            ],
          ),
        ),
        data: (data) => _buildWeatherContent(context, data, isMr),
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherForecastModel data, bool isMr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Farm Location Header
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.farmName ?? (isMr ? 'शेताचे हवामान' : 'Farm Weather'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Lat: ${data.latitude.toStringAsFixed(2)}°, Lon: ${data.longitude.toStringAsFixed(2)}°',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Current Weather Hero Card
          _buildHeroWeatherCard(data.current, isMr),

          const SizedBox(height: 16),

          // Spray Window Advisory
          _buildSprayAdvisoryCard(data.sprayAdvisory, isMr),

          const SizedBox(height: 16),

          // Agricultural Risk Alerts
          if (data.agriculturalAlerts.isNotEmpty) ...[
            _buildAgriculturalAlerts(data.agriculturalAlerts, isMr),
            const SizedBox(height: 16),
          ],

          // 24-Hour Hourly Forecast
          _buildHourlyForecastSection(data.hourlyForecast, isMr),

          const SizedBox(height: 20),

          // 7-Day Forecast Section
          _buildDailyForecastSection(data.dailyForecast, isMr),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroWeatherCard(CurrentWeatherModel current, bool isMr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    isMr ? current.conditionMr : current.conditionEn,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _getWeatherIconWidget(current.icon, size: 54),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherParam(
                  Icons.water_drop_outlined,
                  '${current.humidity}%',
                  isMr ? 'आर्द्रता' : 'Humidity',
                ),
                Container(height: 28, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                _buildWeatherParam(
                  Icons.air,
                  '${current.windSpeed.toStringAsFixed(1)} km/h',
                  isMr ? 'वारा' : 'Wind',
                ),
                Container(height: 28, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                _buildWeatherParam(
                  Icons.grain,
                  '${current.precipitation.toStringAsFixed(1)} mm',
                  isMr ? 'पाऊस' : 'Precip',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherParam(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSprayAdvisoryCard(SprayAdvisoryModel spray, bool isMr) {
    final isIdeal = spray.status == 'ideal';
    final isCaution = spray.status == 'caution';
    final badgeColor = isIdeal
        ? const Color(0xFF2E7D32)
        : (isCaution ? const Color(0xFFF57F17) : const Color(0xFFC62828));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.sanitizer_outlined, color: badgeColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isMr ? 'फवारणी अनुकूलता सल्ला' : 'Spray Window Advisory',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: badgeColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${spray.score}/100',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isMr ? spray.titleMr : spray.titleEn,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
          const SizedBox(height: 6),
          ...(isMr ? spray.reasonsMr : spray.reasonsEn).map(
            (reason) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgriculturalAlerts(List<AgriAlertModel> alerts, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMr ? 'कृषी हवामान इशारे व दक्षता' : 'Agri Weather Risk Alerts',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...alerts.map((alert) {
          final isHigh = alert.severity == 'high';
          final alertColor = isHigh ? Colors.red.shade700 : Colors.amber.shade900;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: alertColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: alertColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isMr ? alert.titleMr : alert.titleEn,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: alertColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isMr ? alert.descriptionMr : alert.descriptionEn,
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isMr ? alert.actionMr : alert.actionEn,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHourlyForecastSection(List<HourlyForecastModel> hourly, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMr ? 'पुढील २४ तास अंदाज' : 'Next 24 Hours Forecast',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourly.length,
            itemBuilder: (context, index) {
              final item = hourly[index];
              final timeFormatted = _formatHourlyTime(item.time);

              return Container(
                width: 78,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeFormatted,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    _getWeatherIconWidget(item.icon, size: 26),
                    Text(
                      '${item.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.water_drop, size: 10, color: Colors.blue),
                        Text(
                          '${item.precipitationProbability}%',
                          style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastSection(List<DailyForecastModel> daily, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMr ? '७ दिवसांचा कृषी हवामान अंदाज' : '7-Day Agricultural Forecast',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...daily.map((day) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDailyDate(day.date, isMr),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isMr ? day.conditionMr : day.conditionEn,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                _getWeatherIconWidget(day.icon, size: 28),
                const SizedBox(width: 14),
                Row(
                  children: [
                    const Icon(Icons.grain, size: 14, color: Colors.blue),
                    const SizedBox(width: 3),
                    Text(
                      '${day.precipitationSum.toStringAsFixed(1)} mm (${day.precipitationProbability}%)',
                      style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Text(
                  '${day.tempMax.toStringAsFixed(0)}° / ${day.tempMin.toStringAsFixed(0)}°',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _getWeatherIconWidget(String icon, {double size = 32}) {
    IconData iconData;
    Color color;

    switch (icon) {
      case 'sunny':
        iconData = Icons.wb_sunny_rounded;
        color = Colors.amber;
        break;
      case 'partly_cloudy':
        iconData = Icons.cloud_queue_rounded;
        color = Colors.lightBlueAccent;
        break;
      case 'cloudy':
        iconData = Icons.cloud_rounded;
        color = Colors.blueGrey;
        break;
      case 'rainy':
        iconData = Icons.grain_rounded;
        color = Colors.blue;
        break;
      case 'heavy_rain':
        iconData = Icons.thunderstorm_rounded;
        color = Colors.indigo;
        break;
      case 'thunderstorm':
        iconData = Icons.flash_on_rounded;
        color = Colors.deepOrange;
        break;
      default:
        iconData = Icons.wb_sunny_outlined;
        color = Colors.amber;
    }

    return Icon(iconData, size: size, color: color);
  }

  String _formatHourlyTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final hour = dt.hour;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12 $amPm';
    } catch (_) {
      return isoTime.contains('T') ? isoTime.split('T').last.substring(0, 5) : isoTime;
    }
  }

  String _formatDailyDate(String dateStr, bool isMr) {
    try {
      final dt = DateTime.parse(dateStr);
      final weekdayMr = ['सोम', 'मंगळ', 'बुध', 'गुरू', 'शुक्र', 'शनि', 'रवि'][dt.weekday - 1];
      final weekdayEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dt.weekday - 1];
      return '${isMr ? weekdayMr : weekdayEn}, ${dt.day}/${dt.month}';
    } catch (_) {
      return dateStr;
    }
  }
}
