/// EVENTS
abstract class FavoriteEvent {}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String productId;
  final bool initialFavoriteState;

  ToggleFavoriteEvent(this.productId, {this.initialFavoriteState = false});
}
