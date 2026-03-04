import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/profile/model/store_check_response_model.dart';
import 'package:_96_sooq/features/profile/model/store_review_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class StoreProfileApiService {
  const StoreProfileApiService();

  Future<StoreCheckResponseModel> checkStore() async {
    try {
      final response = await DioServices.client.get(ApiEndpoints.checkStore);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return StoreCheckResponseModel.fromJson(data);
      }
      if (data is Map) {
        return StoreCheckResponseModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw Exception('Unexpected store-check response');
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('store check', e));
    }
  }

  Future<StoreProfileModel> getStoreDetails({
    String? storeId,
    bool isMyStore = false,
  }) async {
    try {
      final endpoint = '${ApiEndpoints.stores}$storeId';
      final response = await DioServices.client.get(endpoint);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return StoreProfileModel.fromJson(data);
      }
      if (data is Map) {
        return StoreProfileModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Unexpected store details response');
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('store details', e));
    }
  }

  Future<List<ProductModel>> fetchStoreListings({
    required String storeId,
    required int skip,
    required int limit,
    String? status,
  }) async {
    final url = ApiEndpoints.storeListings(
      storeId: storeId,
      skip: skip,
      limit: limit,
      status: status,
    );
    try {
      final response = await DioServices.client.get(url);
      final data = response.data;
      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        rawList =
            data['listings'] as List? ??
            data['items'] as List? ??
            data.values.whereType<List>().firstOrNull ??
            [];
      } else {
        throw Exception('Unexpected listings response');
      }

      return rawList
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('store listings', e));
    }
  }

  Future<StoreReviewsResponse> fetchStoreReviews({
    required String storeId,
    required int skip,
    required int limit,
  }) async {
    final url = ApiEndpoints.storeReviews(
      storeId: storeId,
      skip: skip,
      limit: limit,
    );
    try {
      final response = await DioServices.client.get(url);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return StoreReviewsResponse.fromJson(data);
      }
      if (data is Map) {
        return StoreReviewsResponse.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Unexpected reviews response');
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('store reviews', e));
    }
  }

  Future<void> submitReview({
    required String storeId,
    required int rating,
    required String comment,
  }) async {
    final url = '${ApiEndpoints.stores}$storeId/reviews';
    try {
      await DioServices.client.post(
        url,
        data: {'rating': rating, 'comment': comment},
      );
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('submit review', e));
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
