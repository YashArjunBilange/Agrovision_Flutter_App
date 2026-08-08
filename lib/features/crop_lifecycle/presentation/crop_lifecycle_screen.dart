import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../farm/providers/farm_provider.dart';
import '../domain/crop_cycle_model.dart';
import '../providers/crop_cycle_provider.dart';

class CropLifecycleScreen extends ConsumerStatefulWidget {
  const CropLifecycleScreen({super.key});

  @override
  ConsumerState<CropLifecycleScreen> createState() => _CropLifecycleScreenState();
}

class _CropLifecycleScreenState extends ConsumerState<CropLifecycleScreen> {
  int _selectedStageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final activeFarm = ref.watch(activeFarmProvider);
    final cycleAsync = ref.watch(activeCropCycleProvider);
    final stagesAsync = ref.watch(stagesCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'मका पीक वाढ चक्र व सल्ला' : 'Maize Lifecycle & Advisory',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isMr ? 'माहिती ताजी करा' : 'Refresh',
            onPressed: () {
              ref.read(activeCropCycleProvider.notifier).loadCycle();
            },
          ),
        ],
      ),
      body: cycleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(isMr ? 'माहिती लोड करताना त्रुटी आली' : 'Failed to load crop cycle'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(activeCropCycleProvider.notifier).loadCycle(),
                child: Text(isMr ? 'पुन्हा प्रयत्न करा' : 'Retry'),
              ),
            ],
          ),
        ),
        data: (cycle) {
          if (cycle == null) {
            return _buildNoActiveCycleState(isMr, activeFarm?.id, activeFarm?.areaAcres ?? 2.0);
          }

          return stagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildMainLifecycleView(cycle, [], isMr, activeFarm?.areaAcres ?? 2.0),
            data: (stages) => _buildMainLifecycleView(cycle, stages, isMr, activeFarm?.areaAcres ?? 2.0),
          );
        },
      ),
    );
  }

  Widget _buildNoActiveCycleState(bool isMr, int? farmId, double acreage) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.grass_rounded,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isMr ? 'सक्रिय पिकाचे नियोजन सुरू करा' : 'Start Maize Crop Cycle',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isMr
                  ? 'आपल्या शेतातील मका पेरणीची तारीख नोंदवा. ॲग्रोव्हिजन तुम्हाला पेरणीपासून काढणीपर्यंत खते, पाणी, व फवारणीचे वेळेवर अचूक मार्गदर्शन देईल.'
                  : 'Record your maize sowing date to receive tailored NPK fertilizer schedules, irrigation alerts, and pest guidance for all growth stages.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: farmId == null ? null : () => _showStartCycleDialog(isMr, farmId),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                isMr ? 'मका पेरणी तारीख नोंदवा 🌽' : 'Record Sowing Date 🌽',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            if (farmId == null) ...[
              const SizedBox(height: 12),
              Text(
                isMr ? 'प्रथम शेत जोडा किंवा निवडा' : 'Please select or add a farm first',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainLifecycleView(CropCycleModel cycle, List<CropStageModel> stages, bool isMr, double acreage) {
    final effectiveStages = stages.isNotEmpty ? stages : [cycle.currentStage];
    final activeStageIndex = effectiveStages.indexWhere((s) => s.stageId == cycle.currentStage.stageId);
    final displayedStage = (_selectedStageIndex >= 0 && _selectedStageIndex < effectiveStages.length)
        ? effectiveStages[_selectedStageIndex]
        : cycle.currentStage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Crop Header Card
          _buildCropHeaderCard(cycle, isMr),

          const SizedBox(height: 16),

          // Stage Stepper Timeline Carousel
          _buildStageStepper(effectiveStages, activeStageIndex, isMr),

          const SizedBox(height: 20),

          // Stage Details & Insights Card
          _buildStageDetailCard(displayedStage, isMr, acreage),

          const SizedBox(height: 20),

          // Stage Tasks & Checklist
          _buildTasksSection(cycle, displayedStage.stageId, isMr),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCropHeaderCard(CropCycleModel cycle, bool isMr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.primaryGreen.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cycle.varietyName ?? (isMr ? 'संकरित मका' : 'Hybrid Maize'),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isMr ? "हंगाम" : "Season"}: ${cycle.season} • ${isMr ? "पेरणी" : "Sown"}: ${cycle.sowingDate}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${isMr ? "दिवस" : "Day"} ${cycle.daysSinceSowing}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isMr ? "सध्याचा टप्पा" : "Current Stage"}: ${isMr ? cycle.currentStage.nameMr : cycle.currentStage.nameEn}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                '${cycle.progressPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: cycle.progressPercentage / 100.0,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageStepper(List<CropStageModel> stages, int activeIndex, bool isMr) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          final isSelected = index == _selectedStageIndex;
          final isCurrent = index == activeIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStageIndex = index;
              });
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withValues(alpha: 0.12)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : (isCurrent ? Colors.amber.shade700 : Colors.grey.shade300),
                  width: isSelected ? 2 : (isCurrent ? 1.5 : 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: isCurrent ? Colors.amber.shade700 : AppColors.primaryGreen,
                        child: Text(
                          '${stage.order}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${stage.dayRangeMin}-${stage.dayRangeMax} ${isMr ? "दिवस" : "d"}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                  Text(
                    isMr ? stage.nameMr : stage.nameEn,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected || isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryGreen : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageDetailCard(CropStageModel stage, bool isMr, double acreage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMr ? stage.nameMr : stage.nameEn,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getSensitivityColor(stage.waterSensitivity).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isMr ? "पाण्याची गरज" : "Water"}: ${stage.waterSensitivity}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getSensitivityColor(stage.waterSensitivity),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isMr ? stage.descriptionMr : stage.descriptionEn,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.3),
          ),
          const SizedBox(height: 14),

          // NPK Fertilizer Calculator for Farmer's Exact Acreage
          if (stage.npkRecommendation != null && stage.npkRecommendation!.perAcreKg.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            isMr
                                ? stage.npkRecommendation!.titleMr
                                : stage.npkRecommendation!.titleEn,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '($acreage ${isMr ? "एकर क्षेत्र" : "Acres"})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF388E3C), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: stage.npkRecommendation!.perAcreKg.entries.map((e) {
                      final calculatedKg = (double.tryParse(e.value.toString()) ?? 0.0) * acreage;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA5D6A7)),
                        ),
                        child: Text(
                          '${e.key.replaceAll("_", " ")}: ${calculatedKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMr ? stage.npkRecommendation!.instructionMr : stage.npkRecommendation!.instructionEn,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF33691E), height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Irrigation Advice
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.water_drop_outlined, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isMr ? stage.irrigationAdviceMr : stage.irrigationAdviceEn,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1), height: 1.3),
                ),
              ),
            ],
          ),

          // Pest Watch
          if (stage.pestDiseaseWatch.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.pest_control_outlined, color: Colors.deepOrange, size: 18),
                const SizedBox(width: 6),
                Text(
                  isMr ? 'या टप्प्यावरील कीड व रोग दक्षता' : 'Pest & Disease Watch',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...stage.pestDiseaseWatch.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '• ${isMr ? p.threatMr : p.threatEn}: ${isMr ? p.actionMr : p.actionEn}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTasksSection(CropCycleModel cycle, String stageId, bool isMr) {
    final stageTasks = cycle.tasks.where((t) => t.stageId == stageId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMr ? 'शेत कामे व वेळापत्रक' : 'Stage Farm Tasks',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${stageTasks.where((t) => t.isCompleted).length}/${stageTasks.length} ${isMr ? "पूर्ण" : "Done"}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (stageTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isMr ? 'या टप्प्यासाठी कोणतीही कामे शिल्लक नाहीत.' : 'No pending tasks for this stage.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ),
          )
        else
          ...stageTasks.map((task) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                activeColor: AppColors.primaryGreen,
                value: task.isCompleted,
                title: Text(
                  isMr ? task.titleMr : task.titleEn,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '${isMr ? "वेळ" : "Due"}: ${isMr ? "दिवस" : "Day"} ${task.dueDaysAfterSowing} (${task.taskType})',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                ),
                onChanged: (_) {
                  ref.read(activeCropCycleProvider.notifier).toggleTask(task.id);
                },
              ),
            );
          }),
      ],
    );
  }

  Color _getSensitivityColor(String sensitivity) {
    switch (sensitivity.toLowerCase()) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade800;
      case 'moderate':
        return Colors.blue.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  void _showStartCycleDialog(bool isMr, int farmId) {
    DateTime selectedDate = DateTime.now();
    final varietyController = TextEditingController(text: 'Pioneer 3396 (संकरित मका)');
    String selectedSeason = 'Kharif';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            isMr ? 'नवीन मका पीक नोंदवा' : 'Record New Maize Cycle',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isMr ? 'पेरणी तारीख निवडा:' : 'Sowing Date:',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 120)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedDate = picked;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              ),
              const SizedBox(height: 12),
              Text(
                isMr ? 'हंगाम:' : 'Season:',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedSeason,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: [
                  DropdownMenuItem(value: 'Kharif', child: Text(isMr ? 'खरीप (Kharif)' : 'Kharif')),
                  DropdownMenuItem(value: 'Rabi', child: Text(isMr ? 'रब्बी (Rabi)' : 'Rabi')),
                  DropdownMenuItem(value: 'Summer', child: Text(isMr ? 'उन्हाळी (Summer)' : 'Summer')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedSeason = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                isMr ? 'वाण / व्हरायटी नाव:' : 'Variety / Hybrid Name:',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: varietyController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  hintText: 'उदा. Pioneer, Dekalb 9108, Syngenta',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(isMr ? 'रद्द करा' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final dateStr =
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                await ref.read(activeCropCycleProvider.notifier).startNewCycle(
                      farmId: farmId,
                      cropName: 'Maize',
                      varietyName: varietyController.text.trim(),
                      season: selectedSeason,
                      sowingDate: dateStr,
                    );
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: Text(isMr ? 'सुरू करा' : 'Start Cycle'),
            ),
          ],
        ),
      ),
    );
  }
}
