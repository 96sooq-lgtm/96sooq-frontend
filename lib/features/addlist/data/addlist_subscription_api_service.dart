import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/addlist/model/listing_prices_response_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AddlistSubscriptionApiService {
  const AddlistSubscriptionApiService();

  Future<ListingPricesResponseModel> fetchListingPrices({
    required bool isStore,
  }) async {
    final url = ApiEndpoints.listingPricesByStoreType(isStore: isStore);
    if (kDebugMode) {
      debugPrint(
        '[LISTING-PRICES-DEBUG] request_start is_store=$isStore url=$url via_global_auth_interceptor=true',
      );
    }
    try {
      final response = await DioServices.client.get(url);
      if (kDebugMode) {
        debugPrint(
          '[LISTING-PRICES-DEBUG] request_success status=${response.statusCode} '
          'is_store=$isStore',
        );
      }
      final data = response.data;
      if (data is! Map) {
        throw Exception('Unexpected listing prices response');
      }
      return ListingPricesResponseModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[LISTING-PRICES-DEBUG] request_error status=${e.response?.statusCode} '
          'is_store=$isStore body=${e.response?.data}',
        );
      }
      throw Exception(_buildDioErrorMessage('listing prices', e));
    }
  }

  Future<List<ListingPlanModel>> fetchAdPrices({required bool isStore}) async {
    final url = ApiEndpoints.adPrices(isStore: isStore);
    if (kDebugMode) {
      debugPrint(
        '[AD-PRICES-DEBUG] request_start is_store=$isStore url=$url via_global_auth_interceptor=true',
      );
    }
    try {
      final response = await DioServices.client.get(url);
      if (kDebugMode) {
        debugPrint(
          '[AD-PRICES-DEBUG] request_success status=${response.statusCode} '
          'is_store=$isStore',
        );
      }
      final data = response.data;
      if (data is! List) {
        throw Exception('Unexpected ad prices response');
      }
      return data
          .whereType<Map>()
          .map(
            (item) =>
                ListingPlanModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AD-PRICES-DEBUG] request_error status=${e.response?.statusCode} '
          'is_store=$isStore body=${e.response?.data}',
        );
      }
      throw Exception(_buildDioErrorMessage('ad prices', e));
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
