import 'package:_96_sooq/features/offers/model/offer_story_item.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class OffersApiService {
  const OffersApiService();

  Future<List<OfferStoryItem>> fetchOffers({
    required int skip,
    required int limit,
  }) async {
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.offers,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List<dynamic>;
        return data
            .map(
              (json) => OfferStoryItem.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[OFFERS-API] fetch error: ${e.response?.data ?? e.message}',
        );
      }
      throw Exception('Failed to load offers: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OFFERS-API] fetch general error: $e');
      }
      throw Exception('Failed to load offers: $e');
    }
  }
}
