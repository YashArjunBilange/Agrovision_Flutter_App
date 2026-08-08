import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../farm/providers/farm_provider.dart';
import '../providers/disease_provider.dart';
import 'diagnosis_result_screen.dart';
import 'scan_history_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _runDiagnosis() async {
    if (_selectedImage == null) return;

    final isMr = ref.read(appLocaleProvider).languageCode == 'mr';
    final activeFarm = ref.read(activeFarmProvider);

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(diseaseRepositoryProvider);
      final result = await repository.diagnoseLeafImage(
        imageFile: _selectedImage!,
        farmId: activeFarm?.id,
        language: isMr ? 'mr' : 'en',
      );

      ref.read(lastDiagnosisProvider.notifier).state = result;

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiagnosisResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = isMr
            ? 'तपासणी अयशस्वी झाली. कृपया स्पष्ट फोटो निवडा किंवा इंटरनेट तपासा.'
            : 'Diagnosis failed. Please select a clear photo or check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final activeFarm = ref.watch(activeFarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMr ? 'मका कीड व रोग स्कॅनर' : 'Maize Disease Scanner',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: isMr ? 'मागील स्कॅन इतिहास' : 'Scan History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active Farm Banner
              if (activeFarm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${isMr ? "सक्रिय शेत" : "Target Plot"}: ${activeFarm.name} (${activeFarm.areaAcres} ${isMr ? "एकर" : "Acres"})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Viewfinder Scanner Box / Image Preview
              _buildViewfinder(isMr),

              const SizedBox(height: 20),

              // Camera and Gallery Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                      ),
                      onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined, color: AppColors.primaryGreen),
                      label: Text(
                        isMr ? 'गॅलरी निवडा' : 'Gallery',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isAnalyzing ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(
                        isMr ? 'कॅमेरा सुरू करा' : 'Take Photo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Analyze Leaf Action Button
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  onPressed: _isAnalyzing ? null : _runDiagnosis,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    _isAnalyzing
                        ? (isMr ? 'AI विश्लेषण चालू आहे...' : 'AI Analyzing Leaf...')
                        : (isMr ? 'मका रोग व उपाय तपासा 🔍' : 'Diagnose Disease & Remedies 🔍'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Photography Best Practice Guidelines
              _buildGuidanceCard(isMr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinder(bool isMr) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Selected Image Preview or Placeholder
            if (_selectedImage != null)
              kIsWeb
                  ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                  : Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isMr ? 'मका पानाचा फोटो निवडा किंवा काढा' : 'Capture or Select Maize Leaf Photo',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMr ? 'AI काही सेकंदात अचूक रोग व उपाय सांगेल' : 'Instant AI disease diagnosis & dosages',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),

            // Viewfinder Corner Brackets Overlay
            Positioned(
              top: 16,
              left: 16,
              child: _buildCorner(isTop: true, isLeft: true),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: _buildCorner(isTop: true, isLeft: false),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: _buildCorner(isTop: false, isLeft: true),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildCorner(isTop: false, isLeft: false),
            ),

            if (_selectedImage != null)
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 18,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.primaryGreen, width: 3.5) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primaryGreen, width: 3.5) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.primaryGreen, width: 3.5) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primaryGreen, width: 3.5) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(bool isMr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF2E7D32), size: 22),
              const SizedBox(width: 8),
              Text(
                isMr ? 'अचूक निदानासाठी महत्त्वाच्या टिप्स 💡' : 'Tips for Best Diagnosis 💡',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTipRow(
            Icons.wb_sunny_outlined,
            isMr ? 'फोटो चांगल्या सूर्यप्रकाशात काढा.' : 'Take photos in natural daylight.',
          ),
          _buildTipRow(
            Icons.center_focus_strong_outlined,
            isMr ? 'पानावरील डाग किंवा अळीचा प्रादुर्भाव मध्यभागी ठेवा.' : 'Focus directly on affected spots or whorl.',
          ),
          _buildTipRow(
            Icons.blur_off_outlined,
            isMr ? 'फोटो अस्पष्ट किंवा धूसर होणार नाही याची काळजी घ्या.' : 'Avoid blurry or out-of-focus images.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF388E3C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
