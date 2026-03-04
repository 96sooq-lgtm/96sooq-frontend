class StoreReviewModel {
  const StoreReviewModel({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userName;
  final String avatarUrl;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  factory StoreReviewModel.fromJson(Map<String, dynamic> json) {
    return StoreReviewModel(
      id: (json['id'] ?? '').toString(),
      userName:
          (json['reviewer_name'] ??
                  json['user_name'] ??
                  json['name'] ??
                  'Anonymous')
              .toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatar'] ?? '').toString(),
      rating: int.tryParse((json['rating'] ?? '0').toString()) ?? 0,
      comment: (json['comment'] ?? json['review'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  String get timeAgoLabel {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

class StoreReviewsResponse {
  const StoreReviewsResponse({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
    required this.page,
    required this.limit,
    required this.pages,
  });

  final List<StoreReviewModel> reviews;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingBreakdown;
  final int page;
  final int limit;
  final int pages;

  factory StoreReviewsResponse.fromJson(Map<String, dynamic> json) {
    final reviewsList = json['reviews'];
    final reviews = <StoreReviewModel>[];
    if (reviewsList is List) {
      for (final item in reviewsList) {
        if (item is Map) {
          reviews.add(
            StoreReviewModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final breakdownRaw = json['rating_breakdown'];
    final breakdown = <int, int>{};
    if (breakdownRaw is Map) {
      for (final entry in breakdownRaw.entries) {
        final key = int.tryParse(entry.key.toString());
        final value = int.tryParse((entry.value ?? 0).toString()) ?? 0;
        if (key != null) breakdown[key] = value;
      }
    }

    return StoreReviewsResponse(
      reviews: reviews,
      averageRating:
          double.tryParse((json['average_rating'] ?? '0').toString()) ?? 0.0,
      totalReviews:
          int.tryParse((json['total_reviews'] ?? '0').toString()) ?? 0,
      ratingBreakdown: breakdown,
      page: int.tryParse((json['page'] ?? '1').toString()) ?? 1,
      limit: int.tryParse((json['limit'] ?? '20').toString()) ?? 20,
      pages: int.tryParse((json['pages'] ?? '0').toString()) ?? 0,
    );
  }
}
