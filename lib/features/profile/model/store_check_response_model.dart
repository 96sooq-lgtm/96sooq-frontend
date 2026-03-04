class StoreCheckResponseModel {
  const StoreCheckResponseModel({required this.hasStore, this.store});

  final bool hasStore;
  final StoreProfileModel? store;

  factory StoreCheckResponseModel.fromJson(Map<String, dynamic> json) {
    final hasStoreRaw = json['has_store'];
    final hasStore = hasStoreRaw == true || hasStoreRaw?.toString() == 'true';

    final storeRaw = json['store'];
    final store = storeRaw is Map<String, dynamic>
        ? StoreProfileModel.fromJson(storeRaw)
        : storeRaw is Map
        ? StoreProfileModel.fromJson(Map<String, dynamic>.from(storeRaw))
        : null;

    return StoreCheckResponseModel(hasStore: hasStore, store: store);
  }
}

class StoreProfileModel {
  const StoreProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.logo,
    required this.status,
    required this.planId,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.nameAr,
    required this.governorateId,
    required this.wilayat,
    required this.storeNumber,
    required this.averageRating,
    required this.totalReviews,
    this.isOwnStore = false,
    this.governorateEn = '',
    this.governorateAr = '',
    this.wilayatEn = '',
    this.wilayatAr = '',
  });

  final String id;
  final String userId;
  final String name;
  final String description;
  final String logo;
  final String status;
  final String? planId;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String nameAr;
  final String governorateId;
  final String wilayat;
  final String storeNumber;
  final double averageRating;
  final int totalReviews;
  final bool isOwnStore;
  final String governorateEn;
  final String governorateAr;
  final String wilayatEn;
  final String wilayatAr;

  factory StoreProfileModel.fromJson(Map<String, dynamic> json) {
    final isOwnStoreRaw = json['is_own_store'];
    final isOwnStore =
        isOwnStoreRaw == true || isOwnStoreRaw?.toString() == 'true';

    return StoreProfileModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      logo: (json['logo'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      planId: json['plan_id']?.toString(),
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
      nameAr: (json['name_ar'] ?? '').toString(),
      governorateId: (json['governorate_id'] ?? '').toString(),
      wilayat: (json['wilayat'] ?? '').toString(),
      storeNumber: (json['store_number'] ?? '').toString(),
      averageRating:
          double.tryParse((json['average_rating'] ?? '0').toString()) ?? 0.0,
      totalReviews:
          int.tryParse((json['total_reviews'] ?? '0').toString()) ?? 0,
      isOwnStore: isOwnStore,
      governorateEn: (json['governorate_en'] ?? '').toString(),
      governorateAr: (json['governorate_ar'] ?? '').toString(),
      wilayatEn: (json['wilayat_en'] ?? '').toString(),
      wilayatAr: (json['wilayat_ar'] ?? '').toString(),
    );
  }
}
