import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/categories/model/category_feed_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CategoryFeedApiService {
  const CategoryFeedApiService();

  Future<CategoryFeedResponse> fetchCategoryFeed({
    required String categoryId,
    required int skip,
    required int limit,
    String? governorate,
  }) async {
    try {
      final query = <String, dynamic>{'skip': skip, 'limit': limit};
      if (governorate != null && governorate.trim().isNotEmpty) {
        query['governorate'] = governorate.trim();
      }
      final response = await DioServices.client.get(
        ApiEndpoints.feedCategory(categoryId),
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data != null) {
        return CategoryFeedResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to load category feed');
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[CATEGORY-FEED-API] Error: ${e.response?.data ?? e.message}',
        );
      }
      throw Exception('Failed to load category feed: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CATEGORY-FEED-API] General Error: $e');
      }
      throw Exception('Failed to load category feed: $e');
    }
  }
}
