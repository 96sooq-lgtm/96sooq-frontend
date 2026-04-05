import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class LanguageApiService {
  const LanguageApiService();

  Future<void> updateLanguage({required String language}) async {
    try {
      await DioServices.client.put(
        ApiEndpoints.userLanguage,
        data: {'language': language},
      );
    } on DioException {
      // Ignore failures; language change is handled locally.
    }
  }
}
