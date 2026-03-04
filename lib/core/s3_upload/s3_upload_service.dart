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
}
