import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../farm/providers/farm_provider.dart';
import '../domain/crop_recommendation_model.dart';
import '../providers/crop_recommendation_provider.dart';

class CropRecommendationScreen extends ConsumerStatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  ConsumerState<CropRecommendationScreen> createState() => _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends ConsumerState<CropRecommendationScreen> {
  String _selectedSeason = 'Kharif';
  String _selectedSoilType = 'Medium Black';
  bool _irrigationAvailable = true;
  double _nitrogen = 80.0;
  double _phosphorus = 40.0;
  double _potassium = 40.0;
  double _ph = 6.8;
  bool _showAdvancedParams = false;

  final List<Map<String, String>> _seasons = [
    {'id': 'Kharif', 'en': 'Kharif (Monsoon)', 'mr': 'खरीप (पावसाळी)'},
    {'id': 'Rabi', 'en': 'Rabi (Winter)', 'mr': 'रब्बी (हिवाळी)'},
    {'id': 'Summer', 'en': 'Summer (Zaid)', 'mr': 'उन्हाळी (झैद)'},
  ];

  final List<Map<String, String>> _soils = [
    {'id': 'Medium Black', 'en': 'Medium Black Soil', 'mr': 'मध्यम काळी जमीन'},
    {'id': 'Black Cotton', 'en': 'Deep Black Cotton', 'mr': 'काळी कसदार भारी जमीन'},
    {'id': 'Loam', 'en': 'Loamy Soil', 'mr': 'पोयट्याची गाळाची जमीन'},
    {'id': 'Sandy Loam', 'en': 'Sandy Loam', 'mr': 'वाळूमिश्रित हलकी जमीन'},
    {'id': 'Clay', 'en': 'Clay Soil', 'mr': 'चिकणमाती जमीन'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeFarm = ref.read(activeFarmProvider);
      if (activeFarm != null) {
        setState(() {
          if (activeFarm.soilType != null && activeFarm.soilType!.isNotEmpty) {
            _selectedSoilType = activeFarm.soilType!;
          }
          if (activeFarm.irrigationType != null) {
            _irrigationAvailable = activeFarm.irrigationType != 'Rainfed';
          }
          if (activeFarm.soilPh != null) {
            _ph = activeFarm.soilPh!;
          }
        });
      }
    });
  }

  void _runRecommendation() {
    final activeFarm = ref.read(activeFarmProvider);
    final request = CropRecommendationRequestModel(
      season: _selectedSeason,
      soilType: _selectedSoilType,
      irrigationAvailable: _irrigationAvailable,
      nitrogen: _nitrogen,
      phosphorus: _phosphorus,
      potassium: _potassium,
      ph: _ph,
      farmId: activeFarm?.id,
    );

    ref.read(cropRecommendationProvider.notifier).fetchRecommendations(request);
  }

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final state = ref.watch(cropRecommendationProvider);
    final activeFarm = ref.watch(activeFarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'पीक शिफारस व नफा अंदाज' : 'Crop Recommendation & ROI',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Farm Context Card
            if (activeFarm != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isMr
                            ? 'शेत: ${activeFarm.name} (${activeFarm.areaAcres} एकर)'
                            : 'Farm: ${activeFarm.name} (${activeFarm.areaAcres} Acres)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 16),
                  ],
                ),
              ),

            // Parameters Selection Card
            _buildInputControlCard(isMr),

            const SizedBox(height: 20),

            // Analyze Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.analytics_rounded),
              label: Text(
                isMr ? 'अनुकूल पिकांची शिफारस मिळवा' : 'Analyze & Recommend Crops',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: state.isLoading ? null : _runRecommendation,
            ),

            const SizedBox(height: 24),

            // Results Section
            if (state.error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isMr ? 'माहिती मिळवण्यात त्रुटी आली.' : 'Failed to analyze crop suitability.',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (state.result != null)
              _buildResultsList(state.result!.recommendations, isMr),
          ],
        ),
      ),
    );
  }

  Widget _buildInputControlCard(bool isMr) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMr ? '१. लागवड हंगाम निवडा' : '1. Choose Planting Season',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _seasons.map((s) {
                final isSelected = _selectedSeason == s['id'];
                return ChoiceChip(
                  label: Text(isMr ? s['mr']! : s['en']!),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryGreen : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedSeason = s['id']!);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            Text(
              isMr ? '२. शेतातील जमिनीचा प्रकार' : '2. Soil Classification',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedSoilType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _soils.map((s) {
                return DropdownMenuItem(
                  value: s['id'],
                  child: Text(isMr ? s['mr']! : s['en']!),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedSoilType = val);
              },
            ),

            const SizedBox(height: 14),

            // Irrigation Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                isMr ? 'ओलिताची / सिंचनाची सोय उपलब्ध' : 'Assured Irrigation Available',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              subtitle: Text(
                isMr ? 'ठिबक, तुषार किंवा विहीर/कॅनॉल पाणी' : 'Drip, sprinkler, or borewell water',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              value: _irrigationAvailable,
              activeThumbColor: AppColors.primaryGreen,
              onChanged: (val) => setState(() => _irrigationAvailable = val),
            ),

            const Divider(height: 20),

            // Advanced Soil NPK Accordion
            InkWell(
              onTap: () => setState(() => _showAdvancedParams = !_showAdvancedParams),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMr ? 'माती परीक्षण तपशील (NPK व सामू)' : 'Soil Test Data (NPK & pH)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13),
                  ),
                  Icon(
                    _showAdvancedParams ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),

            if (_showAdvancedParams) ...[
              const SizedBox(height: 12),
              _buildSliderRow(
                label: isMr ? 'नत्र (Nitrogen - N kg/ha): ${_nitrogen.toInt()}' : 'Nitrogen (N): ${_nitrogen.toInt()} kg/ha',
                value: _nitrogen,
                min: 0,
                max: 200,
                onChanged: (v) => setState(() => _nitrogen = v),
              ),
              _buildSliderRow(
                label: isMr ? 'स्फुरद (Phosphorus - P kg/ha): ${_phosphorus.toInt()}' : 'Phosphorus (P): ${_phosphorus.toInt()} kg/ha',
                value: _phosphorus,
                min: 0,
                max: 120,
                onChanged: (v) => setState(() => _phosphorus = v),
              ),
              _buildSliderRow(
                label: isMr ? 'पालाश (Potassium - K kg/ha): ${_potassium.toInt()}' : 'Potassium (K): ${_potassium.toInt()} kg/ha',
                value: _potassium,
                min: 0,
                max: 120,
                onChanged: (v) => setState(() => _potassium = v),
              ),
              _buildSliderRow(
                label: isMr ? 'जमिनीचा सामू (Soil pH): ${_ph.toStringAsFixed(1)}' : 'Soil pH: ${_ph.toStringAsFixed(1)}',
                value: _ph,
                min: 4.5,
                max: 9.0,
                onChanged: (v) => setState(() => _ph = v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultsList(List<CropRecommendationItemModel> crops, bool isMr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isMr ? 'शिफारस केलेली पिके (गुणानुक्रमे)' : 'Recommended Crops (Ranked)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${crops.length} ${isMr ? 'पिके' : 'Crops'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...crops.map((crop) => _buildCropCard(crop, isMr)),
      ],
    );
  }

  Widget _buildCropCard(CropRecommendationItemModel crop, bool isMr) {
    final isTop = crop.matchScore >= 80;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop ? AppColors.primaryGreen.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: isTop ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMr ? crop.nameMr : crop.nameEn,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        crop.category,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(int.parse(crop.badgeColor.replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${crop.matchScore.toStringAsFixed(0)}% ${isMr ? 'अनुकूल' : 'Match'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              isMr ? crop.descriptionMr : crop.descriptionEn,
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
            ),

            const SizedBox(height: 12),

            // Metrics Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem(
                    Icons.trending_up,
                    crop.profitPotentialPerAcre,
                    isMr ? 'अंदाजे नफा/एकर' : 'Profit/Acre',
                  ),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  _buildMetricItem(
                    Icons.scale_rounded,
                    crop.estimatedYieldPerAcre,
                    isMr ? 'उत्पादन क्षमता' : 'Est. Yield',
                  ),
                  Container(height: 24, width: 1, color: Colors.grey.shade300),
                  _buildMetricItem(
                    Icons.timelapse_rounded,
                    crop.durationDays,
                    isMr ? 'कालावधी' : 'Duration',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Advantages Wrap
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (isMr ? crop.advantagesMr : crop.advantagesEn).map((adv) {
                return Chip(
                  label: Text(
                    adv,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF1B5E20), fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFFE8F5E9),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryGreen),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }
}
