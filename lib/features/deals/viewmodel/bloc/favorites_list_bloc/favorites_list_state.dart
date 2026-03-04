import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:equatable/equatable.dart';

abstract class FavoritesListState extends Equatable {
  const FavoritesListState();

  @override
  List<Object?> get props => [];
}

class FavoritesListInitial extends FavoritesListState {}

class FavoritesListLoading extends FavoritesListState {
  final List<ProductModel> oldFavorites;
  final bool isFirstFetch;

  const FavoritesListLoading(this.oldFavorites, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldFavorites, isFirstFetch];
}

class FavoritesListLoaded extends FavoritesListState {
  final List<ProductModel> favorites;
  final bool hasReachedMax;

  const FavoritesListLoaded(this.favorites, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [favorites, hasReachedMax];
}

class FavoritesListError extends FavoritesListState {
  final String message;

  const FavoritesListError(this.message);

  @override
  List<Object?> get props => [message];
}
