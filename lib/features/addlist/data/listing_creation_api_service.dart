import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class ListingCreationApiService {
  const ListingCreationApiService();

  Future<ProductModel?> createListing({
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await DioServices.client.post(
        '${ApiEndpoints.baseUrl}/api/listings/',
        data: request,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['id'] != null) {
        return ProductModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('listing', e));
    }
  }

  Future<ProductModel?> updateListing({
    required String id,
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await DioServices.client.put(
        '${ApiEndpoints.baseUrl}/api/listings/$id',
        data: request,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['id'] != null) {
        return ProductModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('listing', e));
    }
  }

  Future<bool> deleteListing({required String id}) async {
    try {
      final response = await DioServices.client.delete(
        '${ApiEndpoints.baseUrl}/api/listings/$id',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('delete listing', e));
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
