import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/satellite_model.dart';
import '../providers/satellite_provider.dart';

class SatelliteViewScreen extends ConsumerWidget {
  final int farmId;

  const SatelliteViewScreen({super.key, required this.farmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestObsAsync = ref.watch(latestSatelliteObservationProvider(farmId));
    final historyAsync = ref.watch(satelliteHistoryProvider(farmId));
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isMr ? 'उपग्रह निरीक्षण (Sentinel-2)' : 'Satellite Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(latestSatelliteObservationProvider(farmId));
              ref.invalidate(satelliteHistoryProvider(farmId));
            },
          ),
        ],
      ),
      body: latestObsAsync.when(
        data: (SatelliteObservation obs) => _buildBody(context, obs, historyAsync, isMr),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.satellite_alt_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Could not fetch satellite imagery.\nError: ${err.toString().replaceAll('Exception: ', '')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                Text(
                  isMr
                      ? 'कृपया शेताचे क्षेत्र (Polygon) नकाशावर जोडलेले असल्याची खात्री करा.'
                      : 'Please ensure your farm field polygon is drawn on the map.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, 
    SatelliteObservation obs, 
    AsyncValue<SatelliteHistory> historyAsync,
    bool isMr,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Info
          Card(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? 'शेवटचे निरीक्षण' : 'Latest Observation',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(DateFormat('dd MMM yyyy').format(obs.observationDate)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isMr ? 'ढगांचे प्रमाण' : 'Cloud Cover',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${obs.cloudCover.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Images Side by Side or Stacked
          Text(
            isMr ? 'खरी-रंग प्रतिमा (True Color)' : 'True Color Imagery',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildImageCard(obs.trueColorImageUrl),
          
          const SizedBox(height: 20),
          
          Text(
            isMr ? 'पिकाचे आरोग्य (NDVI)' : 'Crop Health (NDVI)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildImageCard(obs.ndviImageUrl),

          const SizedBox(height: 20),
          // NDVI Metrics
          if (obs.ndvi != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      isMr ? 'NDVI विश्लेषण' : 'NDVI Analysis',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricColumn('Min', obs.ndvi!.min),
                        _buildMetricColumn('Mean', obs.ndvi!.mean, isPrimary: true),
                        _buildMetricColumn('Max', obs.ndvi!.max),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getNdviInterpretation(obs.ndvi!.mean, isMr),
                      style: TextStyle(
                        color: _getNdviColor(obs.ndvi!.mean),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
          Text(
            isMr ? 'ऐतिहासिक आरोग्य आलेख' : 'Historical Health Trend',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // History Chart
          historyAsync.when(
            data: (history) => _buildHistoryChart(history, isMr),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading history: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, double value, {bool isPrimary = false}) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(3),
          style: TextStyle(
            fontSize: isPrimary ? 22 : 16,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
            color: isPrimary ? AppColors.primaryGreen : Colors.black87,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildImageCard(String? base64Url) {
    if (base64Url == null || base64Url.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text('Image unavailable'),
      );
    }
    
    // Remove "data:image/jpeg;base64," prefix
    final base64String = base64Url.split(',').last;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        base64Decode(base64String),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 250,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Text('Failed to decode image'),
        ),
      ),
    );
  }

  Widget _buildHistoryChart(SatelliteHistory history, bool isMr) {
    if (history.history.isEmpty) {
      return const Text('No historical data available yet.');
    }

    final spots = <FlSpot>[];
    // Sort history by date ascending for chart
    final sortedHistory = List<SatelliteObservation>.from(history.history)
      ..sort((a, b) => a.observationDate.compareTo(b.observationDate));

    for (int i = 0; i < sortedHistory.length; i++) {
      final obs = sortedHistory[i];
      if (obs.ndvi != null) {
        spots.add(FlSpot(i.toDouble(), obs.ndvi!.mean));
      }
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < sortedHistory.length) {
                        final date = sortedHistory[index].observationDate;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd MMM').format(date),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: 1.0,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primaryGreen,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNdviInterpretation(double mean, bool isMr) {
    if (mean < 0.2) return isMr ? 'अतिशय खराब स्थिती (नापीक / पाणी नाही)' : 'Very Poor Health (Barren/Water)';
    if (mean < 0.4) return isMr ? 'कमी वाढ / आजारी पीक' : 'Stressed / Sparse Vegetation';
    if (mean < 0.6) return isMr ? 'मध्यम वाढ' : 'Moderate Vegetation';
    return isMr ? 'उत्तम आणि निरोगी पीक' : 'Dense and Healthy Crop';
  }

  Color _getNdviColor(double mean) {
    if (mean < 0.2) return Colors.red;
    if (mean < 0.4) return Colors.orange;
    if (mean < 0.6) return Colors.yellow.shade700;
    return Colors.green;
  }
}
