class OfferStoryItem {
  const OfferStoryItem({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.stories,
    this.linkUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final List<String> stories;
  final String? linkUrl;

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
    );
  }
}
