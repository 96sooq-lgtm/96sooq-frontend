import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/profile/bloc/store_details/store_details_state.dart';
import 'package:_96_sooq/features/profile/data/store_profile_api_service.dart';
import 'package:_96_sooq/features/profile/model/store_review_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreDetailsCubit extends Cubit<StoreDetailsState> {
  StoreDetailsCubit({StoreProfileApiService? apiService})
    : _apiService = apiService ?? const StoreProfileApiService(),
      super(const StoreDetailsState());

  final StoreProfileApiService _apiService;

  static const int _pageSize = 20;

  Future<void> fetchStoreDetails({
    String? storeId,
    bool isMyStore = false,
  }) async {
    emit(state.copyWith(status: StoreDetailsLoadStatus.loading, error: null));

    try {
      final store = await _apiService.getStoreDetails(
        storeId: storeId,
        isMyStore: isMyStore,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoreDetailsLoadStatus.success,
          store: store,
          error: null,
        ),
      );

      // Automatically fetch listings and reviews
      if (storeId != null && storeId.isNotEmpty) {
        fetchStoreListings(storeId: storeId);
        fetchStoreReviews(storeId: storeId);
      }
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: StoreDetailsLoadStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  // ─── Listings ────────────────────────────────────────────

  Future<void> fetchStoreListings({required String storeId}) async {
    emit(
      state.copyWith(
        listingsStatus: StoreDetailsLoadStatus.loading,
        listings: const <ProductModel>[],
        isListingsPaginating: false,
        hasMoreListings: true,
        listingsSkip: 0,
      ),
    );

    try {
      final listings = await _apiService.fetchStoreListings(
        storeId: storeId,
        skip: 0,
        limit: _pageSize,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          listingsStatus: StoreDetailsLoadStatus.success,
          listings: listings,
          hasMoreListings: listings.length >= _pageSize,
          listingsSkip: 0,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          listingsStatus: StoreDetailsLoadStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreListings({required String storeId}) async {
    if (state.listingsStatus != StoreDetailsLoadStatus.success ||
        state.isListingsPaginating ||
        !state.hasMoreListings) {
      return;
    }

    final nextSkip = state.listingsSkip + _pageSize;
    emit(state.copyWith(isListingsPaginating: true));

    try {
      final listings = await _apiService.fetchStoreListings(
        storeId: storeId,
        skip: nextSkip,
        limit: _pageSize,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isListingsPaginating: false,
          listings: <ProductModel>[...state.listings, ...listings],
          hasMoreListings: listings.length >= _pageSize,
          listingsSkip: nextSkip,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isListingsPaginating: false));
    }
  }

  // ─── Reviews ─────────────────────────────────────────────

  Future<void> fetchStoreReviews({required String storeId}) async {
    emit(
      state.copyWith(
        reviewsStatus: StoreDetailsLoadStatus.loading,
        reviews: const <StoreReviewModel>[],
        isReviewsPaginating: false,
        hasMoreReviews: true,
        reviewsSkip: 0,
      ),
    );

    try {
      final response = await _apiService.fetchStoreReviews(
        storeId: storeId,
        skip: 0,
        limit: _pageSize,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          reviewsStatus: StoreDetailsLoadStatus.success,
          reviews: response.reviews,
          hasMoreReviews: response.page < response.pages,
          reviewsSkip: 0,
          reviewsAvgRating: response.averageRating,
          reviewsTotalCount: response.totalReviews,
          reviewsRatingBreakdown: response.ratingBreakdown,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          reviewsStatus: StoreDetailsLoadStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreReviews({required String storeId}) async {
    if (state.reviewsStatus != StoreDetailsLoadStatus.success ||
        state.isReviewsPaginating ||
        !state.hasMoreReviews) {
      return;
    }

    final nextSkip = state.reviewsSkip + _pageSize;
    emit(state.copyWith(isReviewsPaginating: true));

    try {
      final response = await _apiService.fetchStoreReviews(
        storeId: storeId,
        skip: nextSkip,
        limit: _pageSize,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isReviewsPaginating: false,
          reviews: <StoreReviewModel>[...state.reviews, ...response.reviews],
          hasMoreReviews: response.page < response.pages,
          reviewsSkip: nextSkip,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isReviewsPaginating: false));
    }
  }

  // ─── Submit Review ───────────────────────────────────────

  Future<void> submitReview({
    required String storeId,
    required int rating,
    required String comment,
  }) async {
    await _apiService.submitReview(
      storeId: storeId,
      rating: rating,
      comment: comment,
    );
    // Refresh reviews after submission
    await fetchStoreReviews(storeId: storeId);
  }
}
