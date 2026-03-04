part of 'store_creation_bloc.dart';

enum StoreLoadStatus { initial, loading, success, failure }

class StoreCreationState {
  const StoreCreationState({
    this.governoratesStatus = StoreLoadStatus.initial,
    this.governorates = const <LocationItemModel>[],
    this.governoratesError,
    this.districtsStatus = StoreLoadStatus.initial,
    this.districts = const <LocationItemModel>[],
    this.districtsError,
    this.selectedGovernorate,
    this.selectedDistrict,
    this.logoUploadStatus = StoreLoadStatus.initial,
    this.logoUrl,
    this.logoUploadError,
    this.submitStatus = StoreLoadStatus.initial,
    this.submitError,
    this.isEditMode = false,
    this.editStoreId,
  });

  final StoreLoadStatus governoratesStatus;
  final List<LocationItemModel> governorates;
  final String? governoratesError;
  final StoreLoadStatus districtsStatus;
  final List<LocationItemModel> districts;
  final String? districtsError;
  final LocationItemModel? selectedGovernorate;
  final LocationItemModel? selectedDistrict;
  final StoreLoadStatus logoUploadStatus;
  final String? logoUrl;
  final String? logoUploadError;
  final StoreLoadStatus submitStatus;
  final String? submitError;
  final bool isEditMode;
  final String? editStoreId;

  static const Object _unset = Object();

  StoreCreationState copyWith({
    StoreLoadStatus? governoratesStatus,
    List<LocationItemModel>? governorates,
    Object? governoratesError = _unset,
    StoreLoadStatus? districtsStatus,
    List<LocationItemModel>? districts,
    Object? districtsError = _unset,
    Object? selectedGovernorate = _unset,
    Object? selectedDistrict = _unset,
    StoreLoadStatus? logoUploadStatus,
    Object? logoUrl = _unset,
    Object? logoUploadError = _unset,
    StoreLoadStatus? submitStatus,
    Object? submitError = _unset,
    bool? isEditMode,
    Object? editStoreId = _unset,
  }) {
    return StoreCreationState(
      governoratesStatus: governoratesStatus ?? this.governoratesStatus,
      governorates: governorates ?? this.governorates,
      governoratesError: identical(governoratesError, _unset)
          ? this.governoratesError
          : governoratesError as String?,
      districtsStatus: districtsStatus ?? this.districtsStatus,
      districts: districts ?? this.districts,
      districtsError: identical(districtsError, _unset)
          ? this.districtsError
          : districtsError as String?,
      selectedGovernorate: identical(selectedGovernorate, _unset)
          ? this.selectedGovernorate
          : selectedGovernorate as LocationItemModel?,
      selectedDistrict: identical(selectedDistrict, _unset)
          ? this.selectedDistrict
          : selectedDistrict as LocationItemModel?,
      logoUploadStatus: logoUploadStatus ?? this.logoUploadStatus,
      logoUrl: identical(logoUrl, _unset) ? this.logoUrl : logoUrl as String?,
      logoUploadError: identical(logoUploadError, _unset)
          ? this.logoUploadError
          : logoUploadError as String?,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: identical(submitError, _unset)
          ? this.submitError
          : submitError as String?,
      isEditMode: isEditMode ?? this.isEditMode,
      editStoreId: identical(editStoreId, _unset)
          ? this.editStoreId
          : editStoreId as String?,
    );
  }
}
