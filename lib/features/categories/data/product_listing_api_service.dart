import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';

class ProductListingResponse {
  final CategoryModel? category;
  final List<ProductModel> products;
  final int total;
  final int page;
  final int limit;
  final int pages;

  ProductListingResponse({
    this.category,
    required this.products,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}

class ProductListingApiService {
  Future<ProductListingResponse> fetchProductsByCategory({
    required String categoryId,
    double? lat,
    double? lng,
    int page = 0,
    int limit = 10,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sellerType,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      if (lat != null && lng != null) {
        queryParams['lat'] = lat;
        queryParams['lng'] = lng;
      }

      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (condition != null && condition.toLowerCase() != 'all') {
        queryParams['condition'] = condition.toLowerCase();
      }
      if (sellerType != null) {
        // Map 'Individual' or 'Business/Store' to API expected values
        if (sellerType == 'Individual') {
          queryParams['seller_type'] = 'individual';
        } else if (sellerType == 'Business/Store') {
          queryParams['seller_type'] = 'store';
        } else {
          queryParams['seller_type'] = sellerType.toLowerCase();
        }
      }

      final response = await DioServices.client.get(
        ApiEndpoints.feedCategory(categoryId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;

        CategoryModel? category;
        if (data['category'] != null) {
          category = CategoryModel.fromJson(data['category']);
        }

        final productsData = data['listings'] as List<dynamic>? ?? [];
        final products = productsData
            .map((json) => ProductModel.fromJson(json))
            .toList();

        final total = data['total'] as int? ?? 0;
        final responsePage = data['page'] as int? ?? 0;
        final responseLimit = data['limit'] as int? ?? 20;
        final pages = data['pages'] as int? ?? 1;

        return ProductListingResponse(
          category: category,
          products: products,
          total: total,
          page: responsePage,
          limit: responseLimit,
          pages: pages,
        );
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch category products: $e');
    }
  }

  Future<ProductListingResponse> fetchBySearch({
    required String query,
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final response = await DioServices.client.get(
        '${ApiEndpoints.baseUrl}/api/listings/',
        queryParameters: {
          'search': query,
          'skip': page * limit,
          'limit': limit,
        },
      );
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
        rawList = [];
      }
      final products = rawList
          .whereType<Map>()
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return ProductListingResponse(
        products: products,
        total: products.length,
        page: page,
        limit: limit,
        pages: 1, // search API doesn't paginate with pages
      );
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }
}
