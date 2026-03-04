import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/product_listing/product_listing_event.dart';
import 'package:_96_sooq/features/categories/bloc/product_listing/product_listing_state.dart';
import 'package:_96_sooq/features/categories/data/product_listing_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductListingBloc
    extends Bloc<ProductListingEvent, ProductListingState> {
  ProductListingBloc({required this.apiService, required this.locationBloc})
    : super(const ProductListingState()) {
    on<FetchProducts>(_onFetchProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<ApplyFilters>(_onApplyFilters);
  }

  final ProductListingApiService apiService;
  final LocationBloc locationBloc;

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductListingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProductListingStatus.loading,
        categoryId: event.categoryId,
        searchQuery: event.searchQuery,
        products: const [],
        page: 0,
        hasReachedMax: false,
      ),
    );

    try {
      double? lat;
      double? lng;
      final locationState = locationBloc.state;
      if (locationState.currentLocationStatus == LocationLoadStatus.success) {
        lat = locationState.selectedLatitude;
        lng = locationState.selectedLongitude;
      }

      final ProductListingResponse response;
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        response = await apiService.fetchBySearch(
          query: event.searchQuery!,
          page: 0,
          limit: state.limit,
        );
      } else {
        response = await apiService.fetchProductsByCategory(
          categoryId: event.categoryId,
          lat: lat,
          lng: lng,
          page: 0,
          limit: state.limit,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          condition: state.condition,
          sellerType: state.sellerType,
        );
      }

      emit(
        state.copyWith(
          status: ProductListingStatus.success,
          category: response.category,
          products: response.products,
          page: response.page,
          limit: response.limit,
          totalPages: response.pages,
          totalItems: response.total,
          hasReachedMax:
              response.page >= (response.pages - 1) ||
              response.products.isEmpty,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductListingStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductListingState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == ProductListingStatus.loading ||
        state.isPaginating) {
      return;
    }

    emit(state.copyWith(isPaginating: true));

    try {
      double? lat;
      double? lng;
      final locationState = locationBloc.state;
      if (locationState.currentLocationStatus == LocationLoadStatus.success) {
        lat = locationState.selectedLatitude;
        lng = locationState.selectedLongitude;
      }

      final nextPage = state.page + 1;

      final ProductListingResponse response;
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        response = await apiService.fetchBySearch(
          query: state.searchQuery!,
          page: nextPage,
          limit: state.limit,
        );
      } else {
        response = await apiService.fetchProductsByCategory(
          categoryId: state.categoryId,
          lat: lat,
          lng: lng,
          page: nextPage,
          limit: state.limit,
          minPrice: state.minPrice,
          maxPrice: state.maxPrice,
          condition: state.condition,
          sellerType: state.sellerType,
        );
      }

      if (response.products.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, isPaginating: false));
      } else {
        emit(
          state.copyWith(
            status: ProductListingStatus.success,
            category: response.category ?? state.category,
            products: List.of(state.products)..addAll(response.products),
            page: response.page,
            limit: response.limit,
            totalPages: response.pages,
            totalItems: response.total,
            hasReachedMax:
                response.page >= (response.pages - 1) ||
                response.products.isEmpty,
            isPaginating: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductListingStatus.failure,
          error: e.toString(),
          isPaginating: false,
        ),
      );
    }
  }

  void _onApplyFilters(ApplyFilters event, Emitter<ProductListingState> emit) {
    emit(
      state.copyWith(
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        condition: event.condition,
        sellerType: event.sellerType,
        clearMinPrice: event.minPrice == null,
        clearMaxPrice: event.maxPrice == null,
        clearCondition: event.condition == null,
        clearSellerType: event.sellerType == null,
      ),
    );

    // Re-trigger fetch to apply them
    if (state.categoryId.isNotEmpty) {
      add(FetchProducts(state.categoryId, searchQuery: state.searchQuery));
    }
  }
}
