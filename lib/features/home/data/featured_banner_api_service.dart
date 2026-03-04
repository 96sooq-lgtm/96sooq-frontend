import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/model/featured_banner_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class FeaturedBannerApiService {
  const FeaturedBannerApiService();

  Future<List<FeaturedBannerModel>> fetchFeaturedBanners() async {
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.featuredBanners,
      );
      final items = _extractItems(response.data);
      return items
          .map((item) => FeaturedBannerModel.fromJson(item))
          .where(
            (banner) =>
                banner.hasValidImage &&
                banner.status.toLowerCase() == 'active' &&
                banner.type.toLowerCase() == 'carousel',
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('featured banners', e));
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final wrapped = data['data'] ?? data['results'];
      if (wrapped is List) {
        return wrapped
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      // Some environments return a single banner object instead of a list.
      if (data.containsKey('id') && data.containsKey('image_url')) {
        return [Map<String, dynamic>.from(data)];
      }
    }

    throw Exception('Unexpected featured banners response');
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
