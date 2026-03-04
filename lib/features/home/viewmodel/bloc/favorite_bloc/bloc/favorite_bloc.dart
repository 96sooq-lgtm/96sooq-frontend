import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_event.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_state.dart';
import 'package:_96_sooq/features/deals/viewmodel/bloc/favorites_list_bloc/favorites_list_bloc.dart';
import 'package:_96_sooq/features/deals/viewmodel/bloc/favorites_list_bloc/favorites_list_event.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

/// BLOC
class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoritesListBloc? _favoritesListBloc;

  FavoriteBloc({FavoritesListBloc? favoritesListBloc})
    : _favoritesListBloc = favoritesListBloc,
      super(FavoriteState(<String>{})) {
    on<ToggleFavoriteEvent>((event, emit) async {
      final updatedFavs = Set<String>.from(state.favorites);
      final updatedUnfavs = Set<String>.from(state.unfavorites);

      final isNowFavorite = !event.initialFavoriteState;

      // Optimistic update
      if (isNowFavorite) {
        updatedFavs.add(event.productId);
        updatedUnfavs.remove(event.productId);
      } else {
        updatedFavs.remove(event.productId);
        updatedUnfavs.add(event.productId);
      }
      emit(state.copyWith(favorites: updatedFavs, unfavorites: updatedUnfavs));

      try {
        final dio = DioServices.client;
        final response = await dio.post(
          '${ApiEndpoints.baseUrl}/api/favorites/${event.productId}',
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Refresh favorites list on success
          _favoritesListBloc?.add(RefreshFavoritesListEvent());
        } else {
          // Revert optimistic update on failure (non-2xx response)
          if (!isNowFavorite) {
            updatedFavs.add(event.productId);
            updatedUnfavs.remove(event.productId);
          } else {
            updatedFavs.remove(event.productId);
            updatedUnfavs.add(event.productId);
          }
          emit(
            state.copyWith(favorites: updatedFavs, unfavorites: updatedUnfavs),
          );
        }
      } on DioException catch (_) {
        // Revert optimistic update on network/dio error
        if (!isNowFavorite) {
          updatedFavs.add(event.productId);
          updatedUnfavs.remove(event.productId);
        } else {
          updatedFavs.remove(event.productId);
          updatedUnfavs.add(event.productId);
        }
        emit(
          state.copyWith(favorites: updatedFavs, unfavorites: updatedUnfavs),
        );
      } catch (_) {
        // Revert on unknown error
        if (!isNowFavorite) {
          updatedFavs.add(event.productId);
          updatedUnfavs.remove(event.productId);
        } else {
          updatedFavs.remove(event.productId);
          updatedUnfavs.add(event.productId);
        }
        emit(
          state.copyWith(favorites: updatedFavs, unfavorites: updatedUnfavs),
        );
      }
    });
  }
}
