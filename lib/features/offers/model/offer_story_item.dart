class OfferStoryItem {
  const OfferStoryItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.stories,
    this.linkUrl,
    this.whatsappNumber,
    this.storeMobileNumber,
    this.storeName,
    this.storeLogo,
    this.storeId,
    this.listingId,
    this.isAdminOffer = false,
    this.description,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final List<String> stories;
  final String? linkUrl;
  final String? whatsappNumber;
  final String? storeMobileNumber;
  final String? storeName;
  final String? storeLogo;
  final String? storeId;
  final String? listingId;
  final bool isAdminOffer;
  final String? description;

  factory OfferStoryItem.fromJson(Map<String, dynamic> json) {
    return OfferStoryItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Offer',
      avatarUrl: json['image_url'] as String?,
      stories:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      linkUrl: json['link_url'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      storeMobileNumber: json['store_mobile_number'] as String?,
      storeName: json['store_name'] as String?,
      storeLogo: json['store_logo'] as String?,
      storeId: json['store_id'] as String?,
      listingId: json['listing_id'] as String?,
      isAdminOffer: json['is_admin_offer'] == true,
      description: json['description'] as String?,
    );
  }
}
