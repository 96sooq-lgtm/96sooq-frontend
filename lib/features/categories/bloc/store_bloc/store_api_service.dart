import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/categories/model/store_list_item_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class StoreApiService {
  const StoreApiService();

  Future<List<StoreListItemModel>> fetchStores({
    required int skip,
    required int limit,
    String? locationId,
    double? minRating,
  }) async {
    final url = ApiEndpoints.storesList(
      skip: skip,
      limit: limit,
      locationId: locationId,
      minRating: minRating,
    );

    try {
      final response = await DioServices.client.get(url);
      final data = response.data;
      if (data is! List) {
        throw Exception('Unexpected stores response');
      }

      return data
          .whereType<Map>()
          .map(
            (item) =>
                StoreListItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('stores', e));
    }
  }

  String _buildDioErrorMessage(String resourceName, DioException e) {
    final statusCode = e.response?.statusCode?.toString() ?? 'unknown';
    final message = _extractApiErrorMessage(e.response?.data);
    if (message != null && message.isNotEmpty) {
      return 'Failed to load $resourceName ($statusCode): $message';
    }
    return 'Failed to load $resourceName ($statusCode)';
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
