import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/addlist/model/create_store_request_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class StoreCreationApiService {
  const StoreCreationApiService();

  Future<void> createStore({required CreateStoreRequestModel request}) async {
    try {
      await DioServices.client.post(
        ApiEndpoints.stores,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('store', e));
    }
  }

  Future<void> updateStore({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    try {
      await DioServices.client.put(
        '${ApiEndpoints.stores}$storeId',
        data: body,
      );
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('store update', e));
    }
  }

  String _buildDioErrorMessage(String resourceName, DioException e) {
    final statusCode = e.response?.statusCode?.toString() ?? 'unknown';
    final message = _extractApiErrorMessage(e.response?.data);
    if (message != null && message.isNotEmpty) {
      return 'Failed to create $resourceName ($statusCode): $message';
    }
    return 'Failed to create $resourceName ($statusCode)';
  }

  String? _extractApiErrorMessage(dynamic data) {
    if (data is String) return data;
    if (data is Map<String, dynamic>) {
      const keys = ['message', 'detail', 'error', 'error_description'];
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return null;
  }
}
