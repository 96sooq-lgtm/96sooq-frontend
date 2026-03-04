part of 'store_bloc.dart';

sealed class StoreEvent {
  const StoreEvent();
}

class HomeStoresRequested extends StoreEvent {
  const HomeStoresRequested({this.locationId});

  final String? locationId;
}

class CategoryStoresInitialRequested extends StoreEvent {
  const CategoryStoresInitialRequested({this.locationId});

  final String? locationId;
}

class CategoryStoresLoadMoreRequested extends StoreEvent {
  const CategoryStoresLoadMoreRequested();
}

class HomeStoresLoadMoreRequested extends StoreEvent {
  const HomeStoresLoadMoreRequested();
}

class StoreLocationChanged extends StoreEvent {
  const StoreLocationChanged({this.locationId});

  final String? locationId;
}

class StoreStateReset extends StoreEvent {
  const StoreStateReset();
}

class StoreFilterChanged extends StoreEvent {
  const StoreFilterChanged({this.minRating, required this.anyRating});

  final double? minRating;
  final bool anyRating;
}

class StoreFilterReset extends StoreEvent {
  const StoreFilterReset();
}
