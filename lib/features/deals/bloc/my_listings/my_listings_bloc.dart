import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/profile/data/store_profile_api_service.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

sealed class MyListingsEvent {
  const MyListingsEvent();
}

class MyListingsFetched extends MyListingsEvent {
  const MyListingsFetched({
    required this.hasStore,
    this.storeId,
    this.status,
    this.skip = 0,
    this.limit = 20,
    this.fetchAllStatuses = false,
  });
  final bool hasStore;
  final String? storeId;
  final String? status;
  final int skip;
  final int limit;
  final bool fetchAllStatuses;
}

/// Load more (pagination). Appends to existing products.
class MyListingsLoadMore extends MyListingsEvent {
  const MyListingsLoadMore();
}

// ─── States ──────────────────────────────────────────────────────────────────

enum MyListingsStatus { initial, loading, success, failure, loadingMore }

class MyListingsState {
  const MyListingsState({
    this.status = MyListingsStatus.initial,
    this.products = const <ProductModel>[],
    this.error,
    this.hasReachedMax = false,
    this.hasStore = false,
    this.storeId,
    this.statusFilter,
    this.fetchAllStatuses = false,
    this.limit = 20,
  });

  final MyListingsStatus status;
  final List<ProductModel> products;
  final String? error;
  final bool hasReachedMax;

  // Pagination context — remembers what the last fetch was for
  final bool hasStore;
  final String? storeId;
  final String? statusFilter;
  final bool fetchAllStatuses;
  final int limit;

  MyListingsState copyWith({
    MyListingsStatus? status,
    List<ProductModel>? products,
    String? error,
    bool? hasReachedMax,
    bool? hasStore,
    String? storeId,
    String? statusFilter,
    bool? fetchAllStatuses,
    int? limit,
  }) {
    return MyListingsState(
      status: status ?? this.status,
      products: products ?? this.products,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      hasStore: hasStore ?? this.hasStore,
      storeId: storeId ?? this.storeId,
      statusFilter: statusFilter ?? this.statusFilter,
      fetchAllStatuses: fetchAllStatuses ?? this.fetchAllStatuses,
      limit: limit ?? this.limit,
    );
  }
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class MyListingsBloc extends Bloc<MyListingsEvent, MyListingsState> {
  MyListingsBloc() : super(const MyListingsState()) {
    on<MyListingsFetched>(_onFetched);
    on<MyListingsLoadMore>(_onLoadMore);
  }

  final _storeService = const StoreProfileApiService();
  bool _isFetching = false;

  Future<void> _onFetched(
    MyListingsFetched event,
    Emitter<MyListingsState> emit,
  ) async {
    if (_isFetching) return;
    _isFetching = true;
    emit(
      state.copyWith(
        status: MyListingsStatus.loading,
        hasReachedMax: false,
        hasStore: event.hasStore,
        storeId: event.storeId,
        statusFilter: event.fetchAllStatuses ? null : event.status,
        fetchAllStatuses: event.fetchAllStatuses,
        limit: event.limit,
      ),
    );
    try {
      final effectiveStatus = event.fetchAllStatuses ? null : event.status;
      final products = await _fetchByStatus(
        hasStore: event.hasStore,
        storeId: event.storeId,
        status: effectiveStatus,
        skip: event.skip,
        limit: event.limit,
      );

      debugPrint('[MyListingsBloc] Loaded ${products.length} products');

      emit(
        state.copyWith(
          status: MyListingsStatus.success,
          products: products,
          error: null,
          hasReachedMax: products.length < event.limit,
        ),
      );
    } catch (e) {
      debugPrint('[MyListingsBloc] Error: $e');
      emit(
        state.copyWith(status: MyListingsStatus.failure, error: e.toString()),
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onLoadMore(
    MyListingsLoadMore event,
    Emitter<MyListingsState> emit,
  ) async {
    if (_isFetching || state.hasReachedMax) return;
    _isFetching = true;
    emit(state.copyWith(status: MyListingsStatus.loadingMore));
    try {
      final products = await _fetchByStatus(
        hasStore: state.hasStore,
        storeId: state.storeId,
        status: state.statusFilter,
        skip: state.products.length,
        limit: state.limit,
      );

      debugPrint('[MyListingsBloc] Loaded more ${products.length} products');

      emit(
        state.copyWith(
          status: MyListingsStatus.success,
          products: [...state.products, ...products],
          error: null,
          hasReachedMax: products.length < state.limit,
        ),
      );
    } catch (e) {
      debugPrint('[MyListingsBloc] LoadMore error: $e');
      // On load-more failure, revert to success so existing items stay visible
      emit(state.copyWith(status: MyListingsStatus.success));
    } finally {
      _isFetching = false;
    }
  }

  Future<List<ProductModel>> _fetchByStatus({
    required bool hasStore,
    required String? storeId,
    required String? status,
    required int skip,
    required int limit,
  }) async {
    if (hasStore && storeId != null) {
      return _storeService.fetchStoreListings(
        storeId: storeId,
        skip: skip,
        limit: limit,
        status: status,
      );
    }

    final response = await DioServices.client.get(
      ApiEndpoints.myListings(status: status, skip: skip, limit: limit),
    );
    final data = response.data;
    List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      rawList =
          data['listings'] as List? ??
          data['items'] as List? ??
          data.values.whereType<List>().firstOrNull ??
          [];
    } else {
      rawList = [];
    }
    return rawList
        .whereType<Map>()
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
