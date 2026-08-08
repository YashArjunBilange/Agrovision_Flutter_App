import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../data/disease_repository.dart';
import '../domain/disease_diagnosis_model.dart';

final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DiseaseRepository(apiClient);
});

final lastDiagnosisProvider = StateProvider<DiagnosisResult?>((ref) => null);

final isAnalyzingProvider = StateProvider<bool>((ref) => false);

final scanHistoryProvider = FutureProvider.family<List<ScanHistoryItem>, int?>((ref, farmId) async {
  final repository = ref.watch(diseaseRepositoryProvider);
  return repository.getScanHistory(farmId: farmId);
});

final diseaseCatalogProvider = FutureProvider.family<List<DiseaseDetail>, String>((ref, language) async {
  final repository = ref.watch(diseaseRepositoryProvider);
  return repository.getDiseaseCatalog(language: language);
});
