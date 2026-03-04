part of 'location_bloc.dart';

enum LocationLoadStatus { initial, loading, success, failure }

enum LocationFailureType { none, servicesDisabled, permissionDenied, unknown }

@immutable
class LocationState {
  const LocationState({
    this.statesStatus = LocationLoadStatus.initial,
    this.citiesStatus = LocationLoadStatus.initial,
    this.currentLocationStatus = LocationLoadStatus.initial,
    this.states = const <LocationItemModel>[],
    this.cities = const <LocationItemModel>[],
    this.selectedState,
    this.selectedCity,
    this.selectedCountryLabel,
    this.isCountryFallback = false,
    this.selectedLatitude,
    this.selectedLongitude,
    this.errorMessage,
    this.failureType = LocationFailureType.none,
  });

  final LocationLoadStatus statesStatus;
  final LocationLoadStatus citiesStatus;
  final LocationLoadStatus currentLocationStatus;
  final List<LocationItemModel> states;
  final List<LocationItemModel> cities;
  final LocationItemModel? selectedState;
  final LocationItemModel? selectedCity;
  final String? selectedCountryLabel;
  final bool isCountryFallback;
  final double? selectedLatitude;
  final double? selectedLongitude;
  final String? errorMessage;
  final LocationFailureType failureType;

  bool get hasSelection => selectedState != null && selectedCity != null;

  static const Object _unset = Object();

  LocationState copyWith({
    LocationLoadStatus? statesStatus,
    LocationLoadStatus? citiesStatus,
    LocationLoadStatus? currentLocationStatus,
    List<LocationItemModel>? states,
    List<LocationItemModel>? cities,
    Object? selectedState = _unset,
    Object? selectedCity = _unset,
    Object? selectedCountryLabel = _unset,
    bool? isCountryFallback,
    Object? selectedLatitude = _unset,
    Object? selectedLongitude = _unset,
    Object? errorMessage = _unset,
    LocationFailureType? failureType,
  }) {
    return LocationState(
      statesStatus: statesStatus ?? this.statesStatus,
      citiesStatus: citiesStatus ?? this.citiesStatus,
      currentLocationStatus:
          currentLocationStatus ?? this.currentLocationStatus,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      selectedState: identical(selectedState, _unset)
          ? this.selectedState
          : selectedState as LocationItemModel?,
      selectedCity: identical(selectedCity, _unset)
          ? this.selectedCity
          : selectedCity as LocationItemModel?,
      selectedCountryLabel: identical(selectedCountryLabel, _unset)
          ? this.selectedCountryLabel
          : selectedCountryLabel as String?,
      isCountryFallback: isCountryFallback ?? this.isCountryFallback,
      selectedLatitude: identical(selectedLatitude, _unset)
          ? this.selectedLatitude
          : selectedLatitude as double?,
      selectedLongitude: identical(selectedLongitude, _unset)
          ? this.selectedLongitude
          : selectedLongitude as double?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      failureType: failureType ?? this.failureType,
    );
  }
}
