import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:dio/dio.dart';

import 's3_upload_state.dart';

class S3UploadService {
  final Dio dio;

  S3UploadService(this.dio);

  Future<S3UploadResult> uploadFile({
    required List<int> bytes,
    required String filename,
    required String folder,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
      'folder': folder,
    });

    final response = await dio.post(
      ApiEndpoints.uploadToS3,
      data: formData,
      options: Options(sendTimeout: const Duration(seconds: 120)),
    );

    if (response.data is Map<String, dynamic>) {
      return S3UploadResult.fromJson(response.data as Map<String, dynamic>);
    }
    if (response.data is Map) {
      return S3UploadResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }

    throw Exception('Unexpected S3 upload response format');
  }

  /// Uploads multiple files in a single request using the `files` key.
  Future<List<S3UploadResult>> uploadFiles({
    required List<({List<int> bytes, String filename})> files,
    required String folder,
  }) async {
    final multipartFiles = <MultipartFile>[];
    for (final file in files) {
      multipartFiles.add(
        MultipartFile.fromBytes(file.bytes, filename: file.filename),
      );
    }

    final formData = FormData.fromMap({
      'files': multipartFiles,
      'folder': folder,
    });

    final response = await dio.post(
      ApiEndpoints.uploadToS3,
      data: formData,
      options: Options(sendTimeout: const Duration(seconds: 120)),
    );

    final data = response.data;

    // Backend may return a list of results or a map containing a list.
    List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map) {
      final mapData = Map<String, dynamic>.from(data);
      rawList =
          mapData['files'] as List? ??
          mapData['urls'] as List? ??
          mapData['results'] as List? ??
          mapData.values.whereType<List>().firstOrNull ??
          [];
    } else {
      throw Exception('Unexpected S3 batch upload response format');
    }

    return rawList
        .whereType<Map>()
        .map((item) => S3UploadResult.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
