import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../farm/providers/farm_provider.dart';
import '../providers/disease_provider.dart';

class ScanHistoryScreen extends ConsumerWidget {
  const ScanHistoryScreen({super.key});

  Color _getSeverityColor(String level) {
    switch (level.toLowerCase()) {
      case 'healthy':
        return const Color(0xFF2E7D32);
      case 'low':
        return const Color(0xFFF9A825);
      case 'moderate':
        return const Color(0xFFEF6C00);
      case 'severe':
        return const Color(0xFFC62828);
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final activeFarm = ref.watch(activeFarmProvider);
    final historyAsync = ref.watch(scanHistoryProvider(activeFarm?.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'मागील स्कॅन इतिहास' : 'Scan History',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                isMr ? 'इतिहास लोड करताना त्रुटी आली' : 'Failed to load scan history',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(scanHistoryProvider(activeFarm?.id)),
                child: Text(isMr ? 'पुन्हा प्रयत्न करा' : 'Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.document_scanner_outlined, size: 48, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isMr ? 'अजून कोणताही स्कॅन इतिहास नाही' : 'No leaf scans recorded yet',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMr
                        ? 'मका पिकाच्या पानांचा फोटो काढून तपासणी सुरू करा.'
                        : 'Capture a maize leaf photo to start diagnosing.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(scanHistoryProvider(activeFarm?.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final color = _getSeverityColor(item.severityLevel);
                final dateStr = item.createdAt != null
                    ? '${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}'
                    : '';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1.5,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.cropName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isMr ? item.diseaseNameMr : item.diseaseNameEn,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.severityLevel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(item.confidence * 100).toStringAsFixed(1)}% ${isMr ? "अचूकता" : "Confidence"}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                        if (item.remedySummary != null && item.remedySummary!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Text(
                            item.remedySummary!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
