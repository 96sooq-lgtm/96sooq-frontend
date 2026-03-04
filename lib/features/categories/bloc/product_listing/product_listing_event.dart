import 'package:equatable/equatable.dart';

abstract class ProductListingEvent extends Equatable {
  const ProductListingEvent();

  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductListingEvent {
  const FetchProducts(this.categoryId, {this.searchQuery});

  final String categoryId;
  final String? searchQuery;

  @override
  List<Object?> get props => [categoryId, searchQuery];
}

class LoadMoreProducts extends ProductListingEvent {}

class ApplyFilters extends ProductListingEvent {
  const ApplyFilters({
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.sellerType,
  });

  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? sellerType;

  @override
  List<Object?> get props => [minPrice, maxPrice, condition, sellerType];
}
