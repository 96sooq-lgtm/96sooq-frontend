import 'package:equatable/equatable.dart';

abstract class FavoritesListEvent extends Equatable {
  const FavoritesListEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesListEvent extends FavoritesListEvent {}

class RefreshFavoritesListEvent extends FavoritesListEvent {}
