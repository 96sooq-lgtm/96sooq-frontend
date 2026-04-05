class ProductModel {
  final String id;
  final String title;
  final String details;
  final String amount;
  final String imageUrl;
  final String? categoryName;
  final String? subCategoryName;
  final String? condition;
  final String? sellerType;
  final String? status;
  final String? city;
  final String? place;
  final String? locationNameEn;
  final String? locationNameAr;
  final String? placeNameEn;
  final String? placeNameAr;
  final bool isPreview;
  final List<String> images;
  final String? localImagePath;
  final List<String>? localImagePaths;
  final Map<String, dynamic>? attributesValues;
  final String? storeId;
  final String? storeName;
  final String? storeLogo;
  final String? userId;
  final String? categoryId;
  final String? subcategoryId;
  final String? currency;
  final String? rejectionReason;
  final String? placeId;
  final String? planId;
  final String? expiresAt;
  final String? location;
  final String? createdAt;
  final String? updatedAt;
  final String? locationId;
  final bool? isPromoted;
  final bool isFavorite;
  final Map<String, dynamic>? locationDetails;
  final String? userName;
  final String? userProfilePicture;
  final String? sellerPhoneNumber;
  final List<dynamic>? promotions;
  final int favoritesCount;
  final int viewsCount;

  ProductModel({
    required this.id,
    required this.title,
    required this.details,
    required this.amount,
    required this.imageUrl,
    this.images = const <String>[],
    this.categoryName,
    this.subCategoryName,
    this.condition,
    this.sellerType,
    this.status,
    this.city,
    this.place,
    this.locationNameEn,
    this.locationNameAr,
    this.placeNameEn,
    this.placeNameAr,
    this.isPreview = false,
    this.localImagePath,
    this.localImagePaths,
    this.attributesValues,
    this.storeId,
    this.storeName,
    this.storeLogo,
    this.userId,
    this.categoryId,
    this.subcategoryId,
    this.currency,
    this.rejectionReason,
    this.placeId,
    this.planId,
    this.expiresAt,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.locationId,
    this.isPromoted,
    this.isFavorite = false,
    this.locationDetails,
    this.userName,
    this.userProfilePicture,
    this.sellerPhoneNumber,
    this.promotions,
    this.favoritesCount = 0,
    this.viewsCount = 0,
  });

  /// Capitalizes the first letter and replaces underscores with spaces.
  /// e.g. "pending_approval" → "Pending approval", "new" → "New"
  static String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return value;
    final cleaned = value.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return cleaned;
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesListInfo = json['images'];
    String imageUrl = '';
    List<String> imagesList = [];
    if (imagesListInfo is List && imagesListInfo.isNotEmpty) {
      imageUrl = imagesListInfo.first.toString();
      imagesList = imagesListInfo.map((e) => e.toString()).toList();
    } else if (json['image_url'] != null) {
      imageUrl = json['image_url'].toString();
      imagesList = [imageUrl];
    }

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      details: (json['details'] ?? json['description'] ?? '').toString(),
      amount: (json['price'] ?? json['amount'] ?? '').toString(),
      imageUrl: imageUrl,
      images: imagesList,
      categoryName:
          json['category_name']?.toString() ??
          json['category_name_en']?.toString(),
      subCategoryName:
          json['sub_category_name']?.toString() ??
          json['subcategory_name_en']?.toString(),
      condition: _capitalize(json['condition']?.toString()),
      sellerType: _capitalize(json['seller_type']?.toString()),
      status: json['status']?.toString(),
      city: json['city']?.toString(),
      place: json['place']?.toString(),
      locationNameEn: json['location_name_en']?.toString(),
      locationNameAr: json['location_name_ar']?.toString(),
      placeNameEn: json['place_name_en']?.toString(),
      placeNameAr: json['place_name_ar']?.toString(),
      attributesValues: json['attributes_values'] as Map<String, dynamic>?,
      storeId: json['store_id']?.toString(),
      storeName: json['store_name']?.toString(),
      storeLogo: json['store_logo']?.toString(),
      userId: json['user_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      subcategoryId: json['subcategory_id']?.toString(),
      currency: json['currency']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      placeId: json['place_id']?.toString(),
      planId: json['plan_id']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      location: json['location']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      locationId: json['location_id']?.toString(),
      isPromoted: json['is_promoted'] as bool?,
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 'true',
      locationDetails: json['location_details'] as Map<String, dynamic>?,
      userName: json['user_name']?.toString(),
      userProfilePicture: json['user_profile_picture']?.toString(),
      sellerPhoneNumber: json['seller_phone_number']?.toString(),
      promotions: json['promotions'] as List<dynamic>?,
      favoritesCount: json['favorites_count'] is int
          ? json['favorites_count'] as int
          : int.tryParse(json['favorites_count']?.toString() ?? '0') ?? 0,
      viewsCount: json['views_count'] is int
          ? json['views_count'] as int
          : int.tryParse(json['views_count']?.toString() ?? '0') ?? 0,
    );
  }
}
