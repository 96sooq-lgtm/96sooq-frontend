/// STATE
class FavoriteState {
  final Set<String> favorites;
  final Set<String> unfavorites;

  FavoriteState(this.favorites, {this.unfavorites = const <String>{}});

  FavoriteState copyWith({Set<String>? favorites, Set<String>? unfavorites}) {
    return FavoriteState(
      favorites ?? this.favorites,
      unfavorites: unfavorites ?? this.unfavorites,
    );
  }
}
