import 'package:_96_sooq/features/categories/bloc/store_bloc/store_api_service.dart';
import 'package:_96_sooq/features/categories/model/store_list_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'store_event.dart';
part 'store_state.dart';

class StoreBloc extends Bloc<StoreEvent, StoreState> {
  StoreBloc({StoreApiService? storeApiService})
    : _storeApiService = storeApiService ?? const StoreApiService(),
      super(const StoreState()) {
    on<HomeStoresRequested>(_onHomeStoresRequested);
    on<HomeStoresLoadMoreRequested>(_onHomeStoresLoadMoreRequested);
    on<CategoryStoresInitialRequested>(_onCategoryStoresInitialRequested);
    on<CategoryStoresLoadMoreRequested>(_onCategoryStoresLoadMoreRequested);
    on<StoreLocationChanged>(_onStoreLocationChanged);
    on<StoreStateReset>(_onStoreStateReset);
    on<StoreFilterChanged>(_onStoreFilterChanged);
    on<StoreFilterReset>(_onStoreFilterReset);
  }

  final StoreApiService _storeApiService;

  static const int _homePageSize = 20;

  Future<void> _onHomeStoresRequested(
    HomeStoresRequested event,
    Emitter<StoreState> emit,
  ) async {
    emit(
      state.copyWith(
        homeStatus: StoreLoadStatus.loading,
        homeError: null,
        isHomePaginating: false,
        hasMoreHome: true,
        homeSkip: 0,
      ),
    );

    try {
      final stores = await _storeApiService.fetchStores(
        skip: 0,
        limit: _homePageSize,
        locationId: event.locationId,
      );
      emit(
        state.copyWith(
          homeStatus: StoreLoadStatus.success,
          homeStores: stores,
          homeError: null,
          hasMoreHome: stores.length >= _homePageSize,
          homeSkip: 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          homeStatus: StoreLoadStatus.failure,
          homeStores: const <StoreListItemModel>[],
          homeError: e.toString(),
          hasMoreHome: false,
        ),
      );
    }
  }

  Future<void> _onHomeStoresLoadMoreRequested(
    HomeStoresLoadMoreRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (state.homeStatus != StoreLoadStatus.success ||
        state.isHomePaginating ||
        !state.hasMoreHome) {
      return;
    }

    final nextSkip = state.homeSkip + _homePageSize;
    emit(state.copyWith(isHomePaginating: true));

    try {
      final stores = await _storeApiService.fetchStores(
        skip: nextSkip,
        limit: _homePageSize,
        locationId: state.activeLocationId,
      );
      emit(
        state.copyWith(
          isHomePaginating: false,
          homeStores: <StoreListItemModel>[...state.homeStores, ...stores],
          hasMoreHome: stores.length >= _homePageSize,
          homeSkip: nextSkip,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isHomePaginating: false));
    }
  }

  Future<void> _onCategoryStoresInitialRequested(
    CategoryStoresInitialRequested event,
    Emitter<StoreState> emit,
  ) async {
    emit(
      state.copyWith(
        categoryStatus: StoreLoadStatus.loading,
        categoryError: null,
        isPaginating: false,
        hasMore: true,
        skip: 0,
        limit: 10,
        activeLocationId: event.locationId,
      ),
    );

    try {
      final effectiveMinRating = state.filterAnyRating
          ? null
          : state.filterMinRating;
      final stores = await _storeApiService.fetchStores(
        skip: 0,
        limit: 10,
        locationId: event.locationId,
        minRating: effectiveMinRating,
      );
      emit(
        state.copyWith(
          categoryStatus: StoreLoadStatus.success,
          categoryStores: stores,
          categoryError: null,
          hasMore: stores.isNotEmpty,
          skip: 0,
          limit: 10,
          activeLocationId: event.locationId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          categoryStatus: StoreLoadStatus.failure,
          categoryStores: const <StoreListItemModel>[],
          categoryError: e.toString(),
          hasMore: false,
        ),
      );
    }
  }

  Future<void> _onCategoryStoresLoadMoreRequested(
    CategoryStoresLoadMoreRequested event,
    Emitter<StoreState> emit,
  ) async {
    if (state.categoryStatus != StoreLoadStatus.success ||
        state.isPaginating ||
        !state.hasMore) {
      return;
    }

    final nextSkip = state.skip + 10;
    final nextLimit = state.limit + 10;

    final effectiveMinRating = state.filterAnyRating
        ? null
        : state.filterMinRating;
    emit(state.copyWith(isPaginating: true));
    try {
      final stores = await _storeApiService.fetchStores(
        skip: nextSkip,
        limit: nextLimit,
        locationId: state.activeLocationId,
        minRating: effectiveMinRating,
      );
      emit(
        state.copyWith(
          isPaginating: false,
          categoryStores: <StoreListItemModel>[
            ...state.categoryStores,
            ...stores,
          ],
          hasMore: stores.isNotEmpty,
          skip: nextSkip,
          limit: nextLimit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isPaginating: false, categoryError: e.toString()));
    }
  }

  Future<void> _onStoreLocationChanged(
    StoreLocationChanged event,
    Emitter<StoreState> emit,
  ) async {
    if (state.activeLocationId == event.locationId) return;
    add(HomeStoresRequested(locationId: event.locationId));
    add(CategoryStoresInitialRequested(locationId: event.locationId));
  }

  void _onStoreStateReset(StoreStateReset event, Emitter<StoreState> emit) {
    emit(const StoreState());
  }

  Future<void> _onStoreFilterChanged(
    StoreFilterChanged event,
    Emitter<StoreState> emit,
  ) async {
    emit(
      state.copyWith(
        filterMinRating: event.minRating,
        filterAnyRating: event.anyRating,
      ),
    );
    add(CategoryStoresInitialRequested(locationId: state.activeLocationId));
  }

  Future<void> _onStoreFilterReset(
    StoreFilterReset event,
    Emitter<StoreState> emit,
  ) async {
    emit(state.copyWith(filterMinRating: null, filterAnyRating: true));
    add(CategoryStoresInitialRequested(locationId: state.activeLocationId));
  }
}
