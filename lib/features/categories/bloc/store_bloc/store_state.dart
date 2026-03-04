part of 'store_bloc.dart';

enum StoreLoadStatus { initial, loading, success, failure }

class StoreState {
  const StoreState({
    this.homeStatus = StoreLoadStatus.initial,
    this.homeStores = const <StoreListItemModel>[],
    this.homeError,
    this.isHomePaginating = false,
    this.hasMoreHome = true,
    this.homeSkip = 0,
    this.categoryStatus = StoreLoadStatus.initial,
    this.categoryStores = const <StoreListItemModel>[],
    this.categoryError,
    this.isPaginating = false,
    this.hasMore = true,
    this.skip = 0,
    this.limit = 10,
    this.activeLocationId,
    this.filterMinRating,
    this.filterAnyRating = true,
  });

  final StoreLoadStatus homeStatus;
  final List<StoreListItemModel> homeStores;
  final String? homeError;
  final bool isHomePaginating;
  final bool hasMoreHome;
  final int homeSkip;
  final StoreLoadStatus categoryStatus;
  final List<StoreListItemModel> categoryStores;
  final String? categoryError;
  final bool isPaginating;
  final bool hasMore;
  final int skip;
  final int limit;
  final String? activeLocationId;
  final double? filterMinRating;
  final bool filterAnyRating;

  static const Object _unset = Object();

  StoreState copyWith({
    StoreLoadStatus? homeStatus,
    List<StoreListItemModel>? homeStores,
    Object? homeError = _unset,
    bool? isHomePaginating,
    bool? hasMoreHome,
    int? homeSkip,
    StoreLoadStatus? categoryStatus,
    List<StoreListItemModel>? categoryStores,
    Object? categoryError = _unset,
    bool? isPaginating,
    bool? hasMore,
    int? skip,
    int? limit,
    Object? activeLocationId = _unset,
    Object? filterMinRating = _unset,
    bool? filterAnyRating,
  }) {
    return StoreState(
      homeStatus: homeStatus ?? this.homeStatus,
      homeStores: homeStores ?? this.homeStores,
      homeError: identical(homeError, _unset)
          ? this.homeError
          : homeError as String?,
      isHomePaginating: isHomePaginating ?? this.isHomePaginating,
      hasMoreHome: hasMoreHome ?? this.hasMoreHome,
      homeSkip: homeSkip ?? this.homeSkip,
      categoryStatus: categoryStatus ?? this.categoryStatus,
      categoryStores: categoryStores ?? this.categoryStores,
      categoryError: identical(categoryError, _unset)
          ? this.categoryError
          : categoryError as String?,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMore: hasMore ?? this.hasMore,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      activeLocationId: identical(activeLocationId, _unset)
          ? this.activeLocationId
          : activeLocationId as String?,
      filterMinRating: identical(filterMinRating, _unset)
          ? this.filterMinRating
          : filterMinRating as double?,
      filterAnyRating: filterAnyRating ?? this.filterAnyRating,
    );
  }
}
