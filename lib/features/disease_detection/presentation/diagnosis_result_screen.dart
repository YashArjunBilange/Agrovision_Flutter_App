import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/disease_diagnosis_model.dart';

class DiagnosisResultScreen extends ConsumerStatefulWidget {
  final DiagnosisResult result;

  const DiagnosisResultScreen({super.key, required this.result});

  @override
  ConsumerState<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends ConsumerState<DiagnosisResultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _pumpCount = 1; // 15-liter knapsack sprayer pump count

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  String _getSeverityText(String level, bool isMr) {
    switch (level.toLowerCase()) {
      case 'healthy':
        return isMr ? 'निरोगी पीक' : 'Healthy Crop';
      case 'low':
        return isMr ? 'कमी प्रादुर्भाव' : 'Low Severity';
      case 'moderate':
        return isMr ? 'मध्यम प्रादुर्भाव' : 'Moderate Severity';
      case 'severe':
        return isMr ? 'गंभीर प्रादुर्भाव' : 'Severe Threat';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final diag = widget.result.diagnosis;
    final severityColor = _getSeverityColor(diag.severityLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'तपासणी निकाल व उपाय' : 'Diagnosis & Remedies',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image & Overlay Card
            Stack(
              children: [
                if (widget.result.localImagePath != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                    ),
                    child: kIsWeb
                        ? Image.network(widget.result.localImagePath!, fit: BoxFit.cover)
                        : Image.file(File(widget.result.localImagePath!), fit: BoxFit.cover),
                  )
                else
                  Container(
                    height: 120,
                    color: severityColor.withValues(alpha: 0.15),
                    child: Center(
                      child: Icon(Icons.eco_rounded, size: 60, color: severityColor),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.result.confidencePercentage.toStringAsFixed(1)}% ${isMr ? "अचूकता" : "Confidence"}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Disease Identity Banner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          diag.crop,
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: severityColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          _getSeverityText(diag.severityLevel, isMr),
                          style: TextStyle(
                            color: severityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isMr ? diag.nameMr : diag.nameEn,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (isMr && diag.nameEn != diag.nameMr) ...[
                    const SizedBox(height: 2),
                    Text(
                      diag.nameEn,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Urgency / Action Alert Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Color(0xFFF57F17), size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMr ? 'त्वरित कृती सल्ला' : 'Immediate Action',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                diag.urgencyAction,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF424242), height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Symptoms Box
                  Text(
                    isMr ? 'रोगाची लक्षणे:' : 'Symptoms:',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diag.symptoms,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
                  ),
                ],
              ),
            ),

            // Knapsack Sprayer Pump Dosage Calculator
            if (!widget.result.isHealthy) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildPumpCalculator(isMr),
              ),
              const SizedBox(height: 12),
            ],

            // Remedies Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondaryLight,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: [
                  Tab(text: isMr ? 'रासायनिक' : 'Chemical'),
                  Tab(text: isMr ? 'जैविक / सेंद्रिय' : 'Organic/Bio'),
                  Tab(text: isMr ? 'मशागत सल्ला' : 'Cultural'),
                ],
              ),
            ),

            // Tab Content
            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChemicalTab(diag.chemicalTreatment, isMr),
                  _buildBiologicalTab(diag.biologicalTreatment, isMr),
                  _buildCulturalTab(diag.culturalPreventions, isMr),
                ],
              ),
            ),

            // Alternative Predictions Accordion
            if (widget.result.topKPredictions.length > 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: _buildAlternativePredictions(widget.result.topKPredictions, isMr),
              ),
            ],

            // Ask AI Assistant Action
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF6A1B9A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  context.go('/assistant');
                },
                icon: const Icon(Icons.smart_toy_outlined),
                label: Text(
                  isMr ? 'AI कृषी सल्लागाराशी अधिक चर्चा करा 🤖' : 'Discuss with AI Agronomist 🤖',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPumpCalculator(bool isMr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop, color: AppColors.primaryGreen, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isMr ? '१५ लिटर फवारणी पंप' : '15L Sprayer Pump',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${isMr ? "एकूण पाणी" : "Total Water"}: ${_pumpCount * 15} ${isMr ? "लिटर" : "L"}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.remove, size: 16),
                onPressed: _pumpCount > 1 ? () => setState(() => _pumpCount--) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  '$_pumpCount',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => setState(() => _pumpCount++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChemicalTab(List<ChemicalTreatment> list, bool isMr) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isMr ? 'कोणत्याही रासायनिक फवारणीची आवश्यकता नाही.' : 'No chemical spray needed.',
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMr ? item.nameMr : item.nameEn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${isMr ? "प्रमाण" : "Rate"}: ${item.dosagePerLiter}',
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${isMr ? "पंप डोस" : "Per 15L"}: ${item.dosage15lPump}',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                if (item.waitingPeriodDays != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${isMr ? "प्रतीक्षा कालावधी (तोडणीपूर्वी)" : "Waiting Period"}: ${item.waitingPeriodDays} ${isMr ? "दिवस" : "days"}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBiologicalTab(List<BiologicalTreatment> list, bool isMr) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isMr ? 'नियमित व्यवस्थापन पुरेसे आहे.' : 'Standard practices apply.',
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMr ? item.nameMr : item.nameEn,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '${isMr ? "प्रमाण" : "Dosage"}: ${item.dosage15lPump}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCulturalTab(List<String> list, bool isMr) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isMr ? 'सध्या कोणतीही विशेष नोंद नाही.' : 'No additional cultural steps.',
          style: const TextStyle(color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  list[index],
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlternativePredictions(List<TopPrediction> list, bool isMr) {
    return ExpansionTile(
      title: Text(
        isMr ? 'इतर संभाव्य रोग शक्यता' : 'Alternative Predictions',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      children: list.map((pred) {
        return ListTile(
          dense: true,
          title: Text(pred.className, style: const TextStyle(fontSize: 12)),
          trailing: Text(
            '${pred.confidencePercentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}
