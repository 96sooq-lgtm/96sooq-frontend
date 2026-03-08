import 'package:_96_sooq/features/location/data/location_api_service.dart';
import 'package:_96_sooq/features/location/model/location_item_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc({LocationApiService? apiService})
    : _apiService = apiService ?? const LocationApiService(),
      super(const LocationState()) {
    on<LocationStatesRequested>(_onLocationStatesRequested);
    on<LocationCitiesRequested>(_onLocationCitiesRequested);
    on<LocationStateSelected>(_onLocationStateSelected);
    on<LocationCitySelected>(_onLocationCitySelected);
    on<LocationUseCurrentRequested>(_onLocationUseCurrentRequested);
    on<LocationSelectionCleared>(_onLocationSelectionCleared);
    on<LocationCountryFallbackSelected>(_onLocationCountryFallbackSelected);
  }

  final LocationApiService _apiService;
  // Debug helper: set to e.g. '23.6870,57.5820' to force test coordinates.
  // Keep null to use real device GPS.
  static const String? _testCoordinatesOverride = null;

  Future<void> _onLocationStatesRequested(
    LocationStatesRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(
        statesStatus: LocationLoadStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final states = await _apiService.fetchStates();
      emit(
        state.copyWith(
          statesStatus: LocationLoadStatus.success,
          states: states,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          statesStatus: LocationLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLocationCitiesRequested(
    LocationCitiesRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(
        citiesStatus: LocationLoadStatus.loading,
        cities: const <LocationItemModel>[],
        errorMessage: null,
      ),
    );
    try {
      final cities = await _apiService.fetchCities(stateId: event.stateId);
      emit(
        state.copyWith(
          citiesStatus: LocationLoadStatus.success,
          cities: cities,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          citiesStatus: LocationLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLocationStateSelected(
    LocationStateSelected event,
    Emitter<LocationState> emit,
  ) async {
    emit(
      state.copyWith(
        cities: const <LocationItemModel>[],
        citiesStatus: LocationLoadStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final cities = await _apiService.fetchCities(stateId: event.state.id);
      emit(
        state.copyWith(
          citiesStatus: LocationLoadStatus.success,
          cities: cities,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          citiesStatus: LocationLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onLocationCitySelected(
    LocationCitySelected event,
    Emitter<LocationState> emit,
  ) {
    emit(
      state.copyWith(
        selectedState: event.state,
        selectedCity: event.city,
        selectedCountryLabel: null,
        isCountryFallback: false,
        isManuallySelected: true,
        errorMessage: null,
        failureType: LocationFailureType.none,
      ),
    );
  }

  Future<void> _onLocationUseCurrentRequested(
    LocationUseCurrentRequested event,
    Emitter<LocationState> emit,
  ) async {
    if (state.isManuallySelected && !event.isForceRefresh) {
      return;
    }

    emit(
      state.copyWith(
        currentLocationStatus: LocationLoadStatus.loading,
        errorMessage: null,
        failureType: LocationFailureType.none,
      ),
    );

    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        emit(
          state.copyWith(
            currentLocationStatus: LocationLoadStatus.failure,
            failureType: LocationFailureType.permissionDenied,
            errorMessage:
                'Location permission denied. Please enable it and try again.',
          ),
        );
        return;
      }

      var availableStates = state.states;
      if (state.statesStatus != LocationLoadStatus.success ||
          state.states.isEmpty) {
        availableStates = await _apiService.fetchStates();
        emit(
          state.copyWith(
            statesStatus: LocationLoadStatus.success,
            states: availableStates,
          ),
        );
      }

      final override = _parseCoordinatePair(_testCoordinatesOverride);
      final effectiveLatitude = override?.$1;
      final effectiveLongitude = override?.$2;
      final currentPosition =
          effectiveLatitude != null && effectiveLongitude != null
          ? null
          : await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            );
      final latitude = effectiveLatitude ?? currentPosition!.latitude;
      final longitude = effectiveLongitude ?? currentPosition!.longitude;

      if (kDebugMode) {
        if (effectiveLatitude != null && effectiveLongitude != null) {
          debugPrint(
            '[Location] Using test override coordinates: $effectiveLatitude,$effectiveLongitude',
          );
        } else {
          debugPrint(
            '[Location] Using device coordinates: $latitude,$longitude',
          );
        }
      }

      final mappedFromLive = await _resolveFromCoordinates(
        latitude: latitude,
        longitude: longitude,
        states: availableStates,
      );

      final resolved = mappedFromLive;

      if (resolved == null) {
        emit(
          state.copyWith(
            selectedState: null,
            selectedCity: null,
            selectedCountryLabel: 'All in Oman',
            isCountryFallback: true,
            isManuallySelected: false,
            selectedLatitude: latitude,
            selectedLongitude: longitude,
            currentLocationStatus: LocationLoadStatus.success,
            errorMessage: null,
            failureType: LocationFailureType.none,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          selectedState: resolved.state,
          selectedCity: resolved.city,
          selectedCountryLabel: null,
          isCountryFallback: false,
          isManuallySelected: false,
          selectedLatitude: resolved.latitude,
          selectedLongitude: resolved.longitude,
          cities: resolved.cities,
          citiesStatus: LocationLoadStatus.success,
          currentLocationStatus: LocationLoadStatus.success,
          errorMessage: null,
          failureType: LocationFailureType.none,
        ),
      );
    } on _LocationServicesDisabledException {
      emit(
        state.copyWith(
          currentLocationStatus: LocationLoadStatus.failure,
          failureType: LocationFailureType.servicesDisabled,
          errorMessage: 'Location services are disabled on this device.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          currentLocationStatus: LocationLoadStatus.failure,
          failureType: LocationFailureType.unknown,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onLocationSelectionCleared(
    LocationSelectionCleared event,
    Emitter<LocationState> emit,
  ) {
    emit(
      state.copyWith(
        selectedState: null,
        selectedCity: null,
        selectedCountryLabel: null,
        isCountryFallback: false,
        isManuallySelected: false,
        selectedLatitude: null,
        selectedLongitude: null,
        failureType: LocationFailureType.none,
      ),
    );
  }

  void _onLocationCountryFallbackSelected(
    LocationCountryFallbackSelected event,
    Emitter<LocationState> emit,
  ) {
    emit(
      state.copyWith(
        selectedState: null,
        selectedCity: null,
        selectedCountryLabel: event.label,
        isCountryFallback: true,
        isManuallySelected: true,
        currentLocationStatus: LocationLoadStatus.success,
        errorMessage: null,
        failureType: LocationFailureType.none,
      ),
    );
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const _LocationServicesDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<_ResolvedLocation?> _resolveFromCoordinates({
    required double latitude,
    required double longitude,
    required List<LocationItemModel> states,
  }) async {
    if (states.isEmpty) return null;

    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;

    final placemark = placemarks.first;
    final stateCandidates = _extractStateCandidates(placemark);
    final cityCandidates = _extractCityCandidates(placemark);

    final matchedState = _findExactOrContainsMatch(
      items: states,
      candidates: stateCandidates,
    );
    if (matchedState == null) return null;

    final cities = await _apiService.fetchCities(stateId: matchedState.id);
    if (cities.isEmpty) return null;

    final matchedCity = _findExactOrContainsMatch(
      items: cities,
      candidates: cityCandidates,
    );
    final finalCity = matchedCity ?? cities.first;

    if (kDebugMode) {
      debugPrint(
        '[Location] candidates(state)=$stateCandidates candidates(city)=$cityCandidates',
      );
      debugPrint(
        '[Location] matchedState=${matchedState.nameEn} matchedCity=${finalCity.nameEn} cityFallback=${matchedCity == null}',
      );
    }

    return _ResolvedLocation(
      state: matchedState,
      city: finalCity,
      cities: cities,
      latitude: latitude,
      longitude: longitude,
    );
  }

  String _normalizeName(String value) {
    return value
        .toLowerCase()
        .replaceAll('governorate', '')
        .replaceAll('province', '')
        .replaceAll('محافظة', '')
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _extractStateCandidates(Placemark placemark) {
    final raw = <String>[
      placemark.administrativeArea ?? '',
      placemark.subAdministrativeArea ?? '',
    ];
    return raw
        .map(_normalizeName)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> _extractCityCandidates(Placemark placemark) {
    final raw = <String>[
      placemark.locality ?? '',
      placemark.subLocality ?? '',
      placemark.subAdministrativeArea ?? '',
    ];
    return raw
        .map(_normalizeName)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();
  }

  LocationItemModel? _findExactOrContainsMatch({
    required List<LocationItemModel> items,
    required List<String> candidates,
  }) {
    if (candidates.isEmpty) return null;
    for (final item in items) {
      final names = <String>[
        _normalizeName(item.nameEn),
        _normalizeName(item.nameAr),
      ].where((name) => name.isNotEmpty);
      for (final name in names) {
        final hasExact = candidates.any((candidate) => candidate == name);
        if (hasExact) return item;
      }
    }

    for (final item in items) {
      final names = <String>[
        _normalizeName(item.nameEn),
        _normalizeName(item.nameAr),
      ].where((name) => name.isNotEmpty);
      for (final name in names) {
        final hasContains = candidates.any(
          (candidate) => candidate.contains(name) || name.contains(candidate),
        );
        if (hasContains) return item;
      }
    }
    return null;
  }

  (double, double)? _parseCoordinatePair(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }
}

class _ResolvedLocation {
  const _ResolvedLocation({
    required this.state,
    required this.city,
    required this.cities,
    required this.latitude,
    required this.longitude,
  });

  final LocationItemModel state;
  final LocationItemModel city;
  final List<LocationItemModel> cities;
  final double latitude;
  final double longitude;
}

class _LocationServicesDisabledException implements Exception {
  const _LocationServicesDisabledException();
}
