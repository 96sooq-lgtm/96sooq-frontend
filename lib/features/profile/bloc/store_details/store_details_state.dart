import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/profile/model/store_check_response_model.dart';
import 'package:_96_sooq/features/profile/model/store_review_model.dart';
import 'package:equatable/equatable.dart';

enum StoreDetailsLoadStatus { initial, loading, success, failure }

class StoreDetailsState extends Equatable {
  const StoreDetailsState({
    this.status = StoreDetailsLoadStatus.initial,
    this.store,
    this.error,
    // Listings
    this.listings = const <ProductModel>[],
    this.listingsStatus = StoreDetailsLoadStatus.initial,
    this.isListingsPaginating = false,
    this.hasMoreListings = true,
    this.listingsSkip = 0,
    // Reviews
    this.reviews = const <StoreReviewModel>[],
    this.reviewsStatus = StoreDetailsLoadStatus.initial,
    this.isReviewsPaginating = false,
    this.hasMoreReviews = true,
    this.reviewsSkip = 0,
    this.reviewsAvgRating = 0.0,
    this.reviewsTotalCount = 0,
    this.reviewsRatingBreakdown = const <int, int>{},
  });

  final StoreDetailsLoadStatus status;
  final StoreProfileModel? store;
  final String? error;

  // Listings
  final List<ProductModel> listings;
  final StoreDetailsLoadStatus listingsStatus;
  final bool isListingsPaginating;
  final bool hasMoreListings;
  final int listingsSkip;

  // Reviews
  final List<StoreReviewModel> reviews;
  final StoreDetailsLoadStatus reviewsStatus;
  final bool isReviewsPaginating;
  final bool hasMoreReviews;
  final int reviewsSkip;
  final double reviewsAvgRating;
  final int reviewsTotalCount;
  final Map<int, int> reviewsRatingBreakdown;

  StoreDetailsState copyWith({
    StoreDetailsLoadStatus? status,
    StoreProfileModel? store,
    String? error,
    List<ProductModel>? listings,
    StoreDetailsLoadStatus? listingsStatus,
    bool? isListingsPaginating,
    bool? hasMoreListings,
    int? listingsSkip,
    List<StoreReviewModel>? reviews,
    StoreDetailsLoadStatus? reviewsStatus,
    bool? isReviewsPaginating,
    bool? hasMoreReviews,
    int? reviewsSkip,
    double? reviewsAvgRating,
    int? reviewsTotalCount,
    Map<int, int>? reviewsRatingBreakdown,
  }) {
    return StoreDetailsState(
      status: status ?? this.status,
      store: store ?? this.store,
      error: error,
      listings: listings ?? this.listings,
      listingsStatus: listingsStatus ?? this.listingsStatus,
      isListingsPaginating: isListingsPaginating ?? this.isListingsPaginating,
      hasMoreListings: hasMoreListings ?? this.hasMoreListings,
      listingsSkip: listingsSkip ?? this.listingsSkip,
      reviews: reviews ?? this.reviews,
      reviewsStatus: reviewsStatus ?? this.reviewsStatus,
      isReviewsPaginating: isReviewsPaginating ?? this.isReviewsPaginating,
      hasMoreReviews: hasMoreReviews ?? this.hasMoreReviews,
      reviewsSkip: reviewsSkip ?? this.reviewsSkip,
      reviewsAvgRating: reviewsAvgRating ?? this.reviewsAvgRating,
      reviewsTotalCount: reviewsTotalCount ?? this.reviewsTotalCount,
      reviewsRatingBreakdown:
          reviewsRatingBreakdown ?? this.reviewsRatingBreakdown,
    );
  }

  @override
  List<Object?> get props => [
    status,
    store,
    error,
    listings,
    listingsStatus,
    isListingsPaginating,
    hasMoreListings,
    listingsSkip,
    reviews,
    reviewsStatus,
    isReviewsPaginating,
    hasMoreReviews,
    reviewsSkip,
    reviewsAvgRating,
    reviewsTotalCount,
    reviewsRatingBreakdown,
  ];
}
