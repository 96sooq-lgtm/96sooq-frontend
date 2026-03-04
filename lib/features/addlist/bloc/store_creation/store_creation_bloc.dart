import 'dart:typed_data';

import 'package:_96_sooq/core/s3_upload/s3_upload_service.dart';
import 'package:_96_sooq/features/addlist/data/store_creation_api_service.dart';
import 'package:_96_sooq/features/addlist/model/create_store_request_model.dart';
import 'package:_96_sooq/features/location/data/location_api_service.dart';
import 'package:_96_sooq/features/location/model/location_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'store_creation_event.dart';
part 'store_creation_state.dart';

class StoreCreationBloc extends Bloc<StoreCreationEvent, StoreCreationState> {
  StoreCreationBloc({
    LocationApiService? locationApiService,
    StoreCreationApiService? storeCreationApiService,
    required S3UploadService s3UploadService,
  }) : _locationApiService = locationApiService ?? const LocationApiService(),
       _storeCreationApiService =
           storeCreationApiService ?? const StoreCreationApiService(),
       _s3UploadService = s3UploadService,
       super(const StoreCreationState()) {
    on<StoreCreationInitialized>(_onStoreCreationInitialized);
    on<StoreGovernoratesRequested>(_onStoreGovernoratesRequested);
    on<StoreDistrictsRequested>(_onStoreDistrictsRequested);
    on<StoreGovernorateSelected>(_onStoreGovernorateSelected);
    on<StoreDistrictSelected>(_onStoreDistrictSelected);
    on<StoreLogoUploadRequested>(_onStoreLogoUploadRequested);
    on<StoreSubmitted>(_onStoreSubmitted);
    on<StoreCreationReset>(_onStoreCreationReset);
    on<StoreEditInitialized>(_onStoreEditInitialized);
    on<StoreUpdateSubmitted>(_onStoreUpdateSubmitted);
  }

  final LocationApiService _locationApiService;
  final StoreCreationApiService _storeCreationApiService;
  final S3UploadService _s3UploadService;

  Future<void> _onStoreCreationInitialized(
    StoreCreationInitialized event,
    Emitter<StoreCreationState> emit,
  ) async {
    add(const StoreGovernoratesRequested());
  }

  Future<void> _onStoreGovernoratesRequested(
    StoreGovernoratesRequested event,
    Emitter<StoreCreationState> emit,
  ) async {
    emit(
      state.copyWith(
        governoratesStatus: StoreLoadStatus.loading,
        governoratesError: null,
      ),
    );

    try {
      final governorates = await _locationApiService.fetchStates();
      emit(
        state.copyWith(
          governoratesStatus: StoreLoadStatus.success,
          governorates: governorates,
          governoratesError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          governoratesStatus: StoreLoadStatus.failure,
          governorates: const <LocationItemModel>[],
          governoratesError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStoreDistrictsRequested(
    StoreDistrictsRequested event,
    Emitter<StoreCreationState> emit,
  ) async {
    emit(
      state.copyWith(
        districtsStatus: StoreLoadStatus.loading,
        districtsError: null,
      ),
    );

    try {
      final districts = await _locationApiService.fetchCities(
        stateId: event.governorateId,
      );
      emit(
        state.copyWith(
          districtsStatus: StoreLoadStatus.success,
          districts: districts,
          districtsError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          districtsStatus: StoreLoadStatus.failure,
          districts: const <LocationItemModel>[],
          districtsError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStoreGovernorateSelected(
    StoreGovernorateSelected event,
    Emitter<StoreCreationState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedGovernorate: event.governorate,
        selectedDistrict: null,
        districts: const <LocationItemModel>[],
        districtsStatus: StoreLoadStatus.initial,
        districtsError: null,
      ),
    );
    add(StoreDistrictsRequested(governorateId: event.governorate.id));
  }

  void _onStoreDistrictSelected(
    StoreDistrictSelected event,
    Emitter<StoreCreationState> emit,
  ) {
    emit(state.copyWith(selectedDistrict: event.district));
  }

  Future<void> _onStoreLogoUploadRequested(
    StoreLogoUploadRequested event,
    Emitter<StoreCreationState> emit,
  ) async {
    emit(
      state.copyWith(
        logoUploadStatus: StoreLoadStatus.loading,
        logoUploadError: null,
      ),
    );
    try {
      final uploadResult = await _s3UploadService.uploadFile(
        bytes: event.bytes,
        filename: event.filename,
        folder: event.folder,
      );
      emit(
        state.copyWith(
          logoUploadStatus: StoreLoadStatus.success,
          logoUrl: uploadResult.url,
          logoUploadError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          logoUploadStatus: StoreLoadStatus.failure,
          logoUploadError: e.toString(),
        ),
      );
    }
  }

  Future<void> _onStoreSubmitted(
    StoreSubmitted event,
    Emitter<StoreCreationState> emit,
  ) async {
    if (!_canSubmit(event)) {
      emit(
        state.copyWith(
          submitStatus: StoreLoadStatus.failure,
          submitError: _buildValidationError(event),
        ),
      );
      return;
    }

    emit(
      state.copyWith(submitStatus: StoreLoadStatus.loading, submitError: null),
    );
    final request = CreateStoreRequestModel(
      nameEn: event.nameEn.trim(),
      nameAr: event.nameAr.trim(),
      description: event.description.trim(),
      governorateId: state.selectedGovernorate!.id,
      wilayatId: state.selectedDistrict!.id,
      logo: state.logoUrl!.trim(),
      planId: null,
      storeNumber: event.storeNumber.trim(),
    );

    try {
      await _storeCreationApiService.createStore(request: request);
      emit(
        state.copyWith(
          submitStatus: StoreLoadStatus.success,
          submitError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: StoreLoadStatus.failure,
          submitError: e.toString(),
        ),
      );
    }
  }

  bool _canSubmit(StoreSubmitted event) {
    return event.nameEn.trim().isNotEmpty &&
        event.nameAr.trim().isNotEmpty &&
        event.description.trim().isNotEmpty &&
        event.storeNumber.trim().isNotEmpty &&
        state.selectedGovernorate != null &&
        state.selectedDistrict != null &&
        (state.logoUrl?.trim().isNotEmpty ?? false);
  }

  String _buildValidationError(StoreSubmitted event) {
    if (event.nameEn.trim().isEmpty) return 'Store name in English is required';
    if (event.nameAr.trim().isEmpty) return 'Store name in Arabic is required';
    if (event.storeNumber.trim().isEmpty) {
      return 'Store mobile number is required';
    }
    if (state.selectedGovernorate == null) return 'Governorate is required';
    if (state.selectedDistrict == null) return 'District is required';
    if (event.description.trim().isEmpty) return 'Description is required';
    if (!(state.logoUrl?.trim().isNotEmpty ?? false)) {
      return 'Business logo upload is required';
    }
    return 'Please fill all required fields';
  }

  void _onStoreCreationReset(
    StoreCreationReset event,
    Emitter<StoreCreationState> emit,
  ) {
    emit(const StoreCreationState());
  }

  void _onStoreEditInitialized(
    StoreEditInitialized event,
    Emitter<StoreCreationState> emit,
  ) {
    emit(
      state.copyWith(
        isEditMode: true,
        editStoreId: event.storeId,
        logoUrl: event.logoUrl,
        logoUploadStatus: event.logoUrl.isNotEmpty
            ? StoreLoadStatus.success
            : StoreLoadStatus.initial,
      ),
    );
    add(const StoreGovernoratesRequested());
  }

  Future<void> _onStoreUpdateSubmitted(
    StoreUpdateSubmitted event,
    Emitter<StoreCreationState> emit,
  ) async {
    final governorateId =
        state.selectedGovernorate?.id ?? event.originalGovernorateId;
    final wilayat = state.selectedDistrict?.nameEn ?? event.originalWilayatId;

    if (event.nameEn.trim().isEmpty ||
        event.nameAr.trim().isEmpty ||
        event.description.trim().isEmpty ||
        event.storeNumber.trim().isEmpty ||
        governorateId.isEmpty ||
        wilayat.isEmpty ||
        !(state.logoUrl?.trim().isNotEmpty ?? false)) {
      emit(
        state.copyWith(
          submitStatus: StoreLoadStatus.failure,
          submitError: 'Please fill all required fields',
        ),
      );
      return;
    }

    emit(
      state.copyWith(submitStatus: StoreLoadStatus.loading, submitError: null),
    );

    final body = <String, dynamic>{
      'name': event.nameEn.trim(),
      'name_ar': event.nameAr.trim(),
      'description': event.description.trim(),
      'governorate_id': governorateId,
      'wilayat': wilayat,
      'logo': state.logoUrl!.trim(),
      'store_number': event.storeNumber.trim(),
    };

    try {
      await _storeCreationApiService.updateStore(
        storeId: event.storeId,
        body: body,
      );
      emit(
        state.copyWith(
          submitStatus: StoreLoadStatus.success,
          submitError: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitStatus: StoreLoadStatus.failure,
          submitError: e.toString(),
        ),
      );
    }
  }
}
