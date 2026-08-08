import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../domain/disease_diagnosis_model.dart';

class DiseaseRepository {
  final ApiClient _apiClient;

  DiseaseRepository(this._apiClient);

  Future<DiagnosisResult> diagnoseLeafImage({
    required XFile imageFile,
    int? farmId,
    String language = 'mr',
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final fileName = imageFile.name.isNotEmpty ? imageFile.name : 'leaf_scan.jpg';

    // Determine mime type
    final ext = fileName.split('.').last.toLowerCase();
    final mimeType = (ext == 'png')
        ? MediaType('image', 'png')
        : (ext == 'webp')
            ? MediaType('image', 'webp')
            : MediaType('image', 'jpeg');

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        imageBytes,
        filename: fileName,
        contentType: mimeType,
      ),
      if (farmId != null) 'farm_id': farmId,
      'language': language,
    });

    final response = await _apiClient.post(
      '/api/v1/disease/diagnose',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    return DiagnosisResult.fromJson(
      response.data as Map<String, dynamic>,
      localImagePath: imageFile.path,
    );
  }

  Future<List<ScanHistoryItem>> getScanHistory({int? farmId, int limit = 20}) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      if (farmId != null) 'farm_id': farmId,
    };

    final response = await _apiClient.get(
      '/api/v1/disease/history',
      queryParameters: queryParams,
    );

    final list = response.data as List<dynamic>;
    return list.map((item) => ScanHistoryItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<DiseaseDetail> getRemedyDetails(String diseaseKey, {String language = 'mr'}) async {
    final response = await _apiClient.get(
      '/api/v1/disease/remedies/$diseaseKey',
      queryParameters: {'language': language},
    );

    return DiseaseDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DiseaseDetail>> getDiseaseCatalog({String language = 'mr'}) async {
    final response = await _apiClient.get(
      '/api/v1/disease/catalog',
      queryParameters: {'language': language},
    );

    final list = response.data as List<dynamic>;
    return list.map((item) => DiseaseDetail.fromJson(item as Map<String, dynamic>)).toList();
  }
}
