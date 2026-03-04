class StoreListItemModel {
  const StoreListItemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.governorateId,
    required this.wilayat,
    required this.logo,
    required this.storeNumber,
    required this.status,
    required this.planId,
    required this.expiresAt,
    required this.createdAt,
    required this.averageRating,
    required this.totalReviews,
  });

  final String id;
  final String userId;
  final String name;
  final String nameAr;
  final String description;
  final String governorateId;
  final String wilayat;
  final String? logo;
  final String? storeNumber;
  final String status;
  final String? planId;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final double averageRating;
  final int totalReviews;

  factory StoreListItemModel.fromJson(Map<String, dynamic> json) {
    return StoreListItemModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      governorateId: (json['governorate_id'] ?? '').toString(),
      wilayat: (json['wilayat'] ?? '').toString(),
      logo: json['logo']?.toString(),
      storeNumber: json['store_number']?.toString(),
      status: (json['status'] ?? '').toString(),
      planId: json['plan_id']?.toString(),
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      averageRating:
          double.tryParse((json['average_rating'] ?? '0').toString()) ?? 0.0,
      totalReviews:
          int.tryParse((json['total_reviews'] ?? '0').toString()) ?? 0,
    );
  }

  String displayName(String languageCode) {
    if (languageCode == 'ar' && nameAr.trim().isNotEmpty) {
      return nameAr.trim();
    }
    if (name.trim().isNotEmpty) return name.trim();
    if (nameAr.trim().isNotEmpty) return nameAr.trim();
    return 'Store';
  }
}
