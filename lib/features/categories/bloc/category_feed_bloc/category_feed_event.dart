import 'package:equatable/equatable.dart';

abstract class CategoryFeedEvent extends Equatable {
  const CategoryFeedEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoryFeed extends CategoryFeedEvent {
  final String categoryId;
  final String? governorate;
  final bool isRefresh;

  const FetchCategoryFeed({
    required this.categoryId,
    this.governorate,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [categoryId, governorate, isRefresh];
}
