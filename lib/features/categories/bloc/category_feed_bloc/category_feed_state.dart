import 'package:_96_sooq/features/categories/model/category_feed_model.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:equatable/equatable.dart';

enum CategoryFeedStatus { initial, loading, success, failure }

class CategoryFeedState extends Equatable {
  final CategoryFeedStatus status;
  final CategoryFeedCategory? category;
  final List<ProductModel> products;
  final bool hasReachedMax;
  final String? errorMessage;
  final int skip;

  const CategoryFeedState({
    this.status = CategoryFeedStatus.initial,
    this.category,
    this.products = const [],
    this.hasReachedMax = false,
    this.errorMessage,
    this.skip = 0,
  });

  CategoryFeedState copyWith({
    CategoryFeedStatus? status,
    CategoryFeedCategory? category,
    List<ProductModel>? products,
    bool? hasReachedMax,
    String? errorMessage,
    int? skip,
  }) {
    return CategoryFeedState(
      status: status ?? this.status,
      category: category ?? this.category,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      skip: skip ?? this.skip,
    );
  }

  @override
  List<Object?> get props => [
    status,
    category,
    products,
    hasReachedMax,
    errorMessage,
    skip,
  ];
}
