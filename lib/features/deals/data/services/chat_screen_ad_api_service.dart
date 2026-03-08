import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ChatScreenAdApiService {
  const ChatScreenAdApiService();

  Future<ProductModel?> fetchChatScreenAd() async {
    try {
      final response = await DioServices.client.get(ApiEndpoints.chatScreenAd);
      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      final hasAds = data['has_ads'] == true;
      if (!hasAds) return null;

      final ad = data['ad'];
      if (ad is! Map<String, dynamic>) return null;

      return ProductModel.fromJson(ad);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[CHAT-AD-API] fetch error: ${e.response?.data ?? e.message}',
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CHAT-AD-API] fetch general error: $e');
      }
      return null;
    }
  }
}
