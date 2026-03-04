import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'favorites_list_event.dart';
import 'favorites_list_state.dart';

class FavoritesListBloc extends Bloc<FavoritesListEvent, FavoritesListState> {
  final int _limit = 10;
  int _skip = 0;

  FavoritesListBloc() : super(FavoritesListInitial()) {
    on<LoadFavoritesListEvent>(_onLoadFavoritesList);
    on<RefreshFavoritesListEvent>(_onRefreshFavoritesList);
  }

  Future<void> _onLoadFavoritesList(
    LoadFavoritesListEvent event,
    Emitter<FavoritesListState> emit,
  ) async {
    if (state is FavoritesListLoaded &&
        (state as FavoritesListLoaded).hasReachedMax)
      return;

    try {
      if (state is FavoritesListInitial) {
        emit(const FavoritesListLoading([], isFirstFetch: true));
        final products = await _fetchFavorites();
        emit(
          FavoritesListLoaded(
            products,
            hasReachedMax: products.length < _limit,
          ),
        );
        return;
      }

      final currentState = state as FavoritesListLoaded;
      emit(FavoritesListLoading(currentState.favorites));
      final products = await _fetchFavorites();

      emit(
        products.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : FavoritesListLoaded(
                currentState.favorites + products,
                hasReachedMax: products.length < _limit,
              ),
      );
    } catch (e) {
      emit(FavoritesListError(e.toString()));
    }
  }

  Future<void> _onRefreshFavoritesList(
    RefreshFavoritesListEvent event,
    Emitter<FavoritesListState> emit,
  ) async {
    try {
      _skip = 0;
      emit(const FavoritesListLoading([], isFirstFetch: true));
      final products = await _fetchFavorites();
      emit(
        FavoritesListLoaded(products, hasReachedMax: products.length < _limit),
      );
    } catch (e) {
      emit(FavoritesListError(e.toString()));
    }
  }

  Future<List<ProductModel>> _fetchFavorites() async {
    final dio = DioServices.client;
    final response = await dio.get(
      '${ApiEndpoints.baseUrl}/api/favorites/',
      queryParameters: {'skip': _skip, 'limit': _limit},
    );

    if (response.statusCode == 200) {
      final List<dynamic> listings = response.data['listings'] ?? [];
      final List<ProductModel> products = listings
          .map((json) => ProductModel.fromJson(json))
          .toList();
      _skip += _limit;
      return products;
    } else {
      throw Exception('Failed to load favorites');
    }
  }
}

extension on FavoritesListLoaded {
  FavoritesListLoaded copyWith({
    List<ProductModel>? favorites,
    bool? hasReachedMax,
  }) {
    return FavoritesListLoaded(
      favorites ?? this.favorites,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
