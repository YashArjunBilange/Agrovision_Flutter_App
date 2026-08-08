import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/farm_model.dart';
import '../providers/farm_provider.dart';
import 'add_edit_farm_dialog.dart';

class FarmScreen extends ConsumerWidget {
  const FarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final farmsAsync = ref.watch(farmsProvider);
    final activeFarm = ref.watch(activeFarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'माझी शेती व भूखंड' : 'My Farms & Plots',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isMr ? 'ताजे करा' : 'Refresh',
            onPressed: () => ref.read(farmsProvider.notifier).loadFarms(),
          ),
        ],
      ),
      body: farmsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  isMr ? 'शेतांची माहिती लोड करताना त्रुटी आली.' : 'Failed to load farms.',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.read(farmsProvider.notifier).loadFarms(),
                  icon: const Icon(Icons.refresh),
                  label: Text(isMr ? 'पुन्हा प्रयत्न करा' : 'Try Again'),
                ),
              ],
            ),
          ),
        ),
        data: (farms) {
          if (farms.isEmpty) {
            return _buildEmptyState(context, isMr);
          }

          final totalAcres = farms.fold<double>(0.0, (sum, f) => sum + f.areaAcres);

          return RefreshIndicator(
            onRefresh: () => ref.read(farmsProvider.notifier).loadFarms(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              children: [
                // Summary Header Banner
                _buildSummaryBanner(context, farms.length, totalAcres, activeFarm, isMr),
                const SizedBox(height: 16),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMr ? 'सर्व शेत भूखंड (${farms.length})' : 'All Farm Plots (${farms.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isMr ? 'सक्रिय शेत निवडा' : 'Select Active Plot',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // List of Farm Cards
                ...farms.map((farm) => _buildFarmCard(context, ref, farm, isMr)),
                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditFarmDialog.show(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        label: Text(
          isMr ? 'नवीन शेत जोडा' : 'Add New Farm',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryBanner(
    BuildContext context,
    int count,
    double totalAcres,
    FarmModel? activeFarm,
    bool isMr,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMr ? 'एकूण शेतजमीन सारांश' : 'Total Farm Holding',
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isMr ? '$count भूखंड' : '$count Plots',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${totalAcres.toStringAsFixed(1)} ${isMr ? "एकर" : "Acres"}',
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.secondaryLight, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  activeFarm != null
                      ? (isMr ? 'सध्याचे सक्रिय शेत: ${activeFarm.name}' : 'Active plot: ${activeFarm.name}')
                      : (isMr ? 'कोणतेही सक्रिय शेत निवडलेले नाही' : 'No active plot selected'),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmCard(
    BuildContext context,
    WidgetRef ref,
    FarmModel farm,
    bool isMr,
  ) {
    final isPrimary = farm.isPrimary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPrimary ? AppColors.primaryGreen : Colors.transparent,
          width: isPrimary ? 2.0 : 0,
        ),
      ),
      elevation: isPrimary ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!isPrimary) {
            ref.read(farmsProvider.notifier).setActiveFarm(farm.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? AppColors.primaryGreen.withValues(alpha: 0.12)
                          : AppColors.dividerLight.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.landscape_rounded,
                      color: isPrimary ? AppColors.primaryGreen : AppColors.textSecondaryLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (farm.surveyNumber != null)
                          Text(
                            isMr ? 'गट / सर्व्हे: ${farm.surveyNumber}' : 'Gat / Survey: ${farm.surveyNumber}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                      ],
                    ),
                  ),
                  if (isPrimary)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isMr ? 'सक्रिय' : 'Active',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => ref.read(farmsProvider.notifier).setActiveFarm(farm.id),
                      child: Text(
                        isMr ? 'सक्रिय करा' : 'Set Active',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (val) {
                      if (val == 'edit') {
                        AddEditFarmDialog.show(context, farmToEdit: farm);
                      } else if (val == 'delete') {
                        _showDeleteConfirm(context, ref, farm, isMr);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(isMr ? 'संपादित करा' : 'Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Text(isMr ? 'हटवा' : 'Delete', style: const TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Badges Row (Acres, Soil, Irrigation, Location)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildBadge(
                    Icons.square_foot,
                    '${farm.areaAcres.toStringAsFixed(1)} ${isMr ? "एकर" : "Acres"}',
                    AppColors.primaryGreen,
                  ),
                  if (farm.soilType != null)
                    _buildBadge(
                      Icons.layers_outlined,
                      farm.soilType!,
                      AppColors.secondaryDark,
                    ),
                  if (farm.irrigationType != null)
                    _buildBadge(
                      Icons.water_drop_outlined,
                      farm.irrigationType!,
                      AppColors.info,
                    ),
                  if (farm.district != null || farm.village != null)
                    _buildBadge(
                      Icons.location_on_outlined,
                      [farm.village, farm.taluka, farm.district].where((s) => s != null && s.isNotEmpty).join(', '),
                      AppColors.textSecondaryLight,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isMr) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.landscape_rounded, size: 64, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 20),
            Text(
              isMr ? 'अद्याप कोणतेही शेत जोडलेले नाही' : 'No Farms Added Yet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isMr
                  ? 'आपल्या शेताची माहिती, मातीचा प्रकार आणि सिंचन व्यवस्था जोडून वैयक्तिकृत मका व्यवस्थापन मिळवा.'
                  : 'Add your farm plots to get personalized maize crop schedules, weather forecasts, and disease protection.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AddEditFarmDialog.show(context),
              icon: const Icon(Icons.add),
              label: Text(
                isMr ? 'पहिले शेत जोडा' : 'Add First Farm',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, FarmModel farm, bool isMr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isMr ? 'शेत हटवायचे का?' : 'Delete Farm?'),
        content: Text(
          isMr
              ? 'तुम्हाला खात्री आहे का "${farm.name}" हे शेत हटवायचे आहे? या शेताचा सर्व डेटा कायमचा काढून टाकला जाईल.'
              : 'Are you sure you want to delete "${farm.name}"? All associated plot records will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isMr ? 'रद्द करा' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(farmsProvider.notifier).deleteFarm(farm.id);
            },
            child: Text(isMr ? 'हटवा' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
