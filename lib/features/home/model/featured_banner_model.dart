class FeaturedBannerModel {
  final String id;
  final String name;
  final String description;
  final String type;
  final String imageUrl;
  final String linkUrl;
  final String status;
  final DateTime? expiresAt;

  const FeaturedBannerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.linkUrl,
    required this.status,
    this.expiresAt,
  });

  bool get hasValidImage => imageUrl.trim().isNotEmpty;
  bool get hasValidLink => linkUrl.trim().isNotEmpty;

  factory FeaturedBannerModel.fromJson(Map<String, dynamic> json) {
    return FeaturedBannerModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      linkUrl: (json['link_url'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString()),
    );
  }
}
