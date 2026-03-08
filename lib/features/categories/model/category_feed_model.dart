import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:equatable/equatable.dart';

class CategoryFeedCategory extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final String? imageUrl;

  const CategoryFeedCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.imageUrl,
  });

  factory CategoryFeedCategory.fromJson(Map<String, dynamic> json) {
    return CategoryFeedCategory(
      id: json['id']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, nameEn, nameAr, imageUrl];
}

class CategoryFeedResponse extends Equatable {
  final CategoryFeedCategory? category;
  final List<ProductModel> listings;
  final int total;
  final int page;
  final int limit;
  final int pages;

  const CategoryFeedResponse({
    this.category,
    required this.listings,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory CategoryFeedResponse.fromJson(Map<String, dynamic> json) {
    return CategoryFeedResponse(
      category: json['category'] != null
          ? CategoryFeedCategory.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,
      listings:
          (json['listings'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 0,
      limit: json['limit'] as int? ?? 10,
      pages: json['pages'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [category, listings, total, page, limit, pages];
}
