import 'package:_96_sooq/features/categories/model/category_model.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:equatable/equatable.dart';

enum ProductListingStatus { initial, loading, success, failure }

class ProductListingState extends Equatable {
  const ProductListingState({
    this.status = ProductListingStatus.initial,
    this.products = const [],
    this.categoryId = '',
    this.hasReachedMax = false,
    this.page = 0,
    this.limit = 10,
    this.totalPages = 1,
    this.totalItems = 0,
    this.error,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.sellerType,
    this.isPaginating = false,
    this.searchQuery,
  });

  final ProductListingStatus status;
  final List<ProductModel> products;
  final String categoryId;
  final bool hasReachedMax;
  final int page;
  final int limit;
  final int totalPages;
  final int totalItems;
  final String? error;
  final CategoryModel? category;

  // Filters
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? sellerType;

  final bool isPaginating;
  final String? searchQuery;

  ProductListingState copyWith({
    ProductListingStatus? status,
    List<ProductModel>? products,
    String? categoryId,
    bool? hasReachedMax,
    int? page,
    int? limit,
    int? totalPages,
    int? totalItems,
    String? error,
    CategoryModel? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sellerType,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCondition = false,
    bool clearSellerType = false,
    bool? isPaginating,
    String? searchQuery,
    bool clearSearchQuery = false,
  }) {
    return ProductListingState(
      status: status ?? this.status,
      products: products ?? this.products,
      categoryId: categoryId ?? this.categoryId,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      error: error,
      category: category ?? this.category,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      condition: clearCondition ? null : (condition ?? this.condition),
      sellerType: clearSellerType ? null : (sellerType ?? this.sellerType),
      isPaginating: isPaginating ?? this.isPaginating,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    categoryId,
    hasReachedMax,
    page,
    limit,
    totalPages,
    totalItems,
    error,
    category,
    minPrice,
    maxPrice,
    condition,
    sellerType,
    isPaginating,
    searchQuery,
  ];
}
