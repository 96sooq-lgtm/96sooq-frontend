import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:dio/dio.dart';

class CategoriesApiService {
  const CategoriesApiService();

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await DioServices.client.get(ApiEndpoints.getAllCategory);
      return _parseCategories(response);
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('categories', e));
    }
  }

  Future<List<CategoryModel>> fetchSubCategories({
    required String parentId,
  }) async {
    try {
      final response = await DioServices.client.get(
        '${ApiEndpoints.getCategoriesByParent}$parentId',
      );
      return _parseCategories(response);
    } on DioException catch (e) {
      throw Exception(_buildDioErrorMessage('subcategories', e));
    }
  }

  List<CategoryModel> _parseCategories(Response<dynamic> response) {
    final data = response.data;
    if (data is! List) {
      throw Exception('Unexpected categories response');
    }

    return data
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
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
