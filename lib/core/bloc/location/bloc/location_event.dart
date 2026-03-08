part of 'location_bloc.dart';

@immutable
sealed class LocationEvent {}

final class LocationStatesRequested extends LocationEvent {}

final class LocationCitiesRequested extends LocationEvent {
  LocationCitiesRequested(this.stateId);

  final String stateId;
}

final class LocationStateSelected extends LocationEvent {
  LocationStateSelected(this.state);

  final LocationItemModel state;
}

final class LocationCitySelected extends LocationEvent {
  LocationCitySelected({required this.state, required this.city});

  final LocationItemModel state;
  final LocationItemModel city;
}

final class LocationUseCurrentRequested extends LocationEvent {
  LocationUseCurrentRequested({this.isForceRefresh = false});

  final bool isForceRefresh;
}

final class LocationSelectionCleared extends LocationEvent {}

final class LocationCountryFallbackSelected extends LocationEvent {
  LocationCountryFallbackSelected({this.label = 'All in Oman'});

  final String label;
}
