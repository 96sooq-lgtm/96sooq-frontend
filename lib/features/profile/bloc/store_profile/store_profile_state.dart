import 'package:_96_sooq/features/profile/model/store_check_response_model.dart';

enum StoreProfileLoadStatus { initial, loading, success, failure }

class StoreProfileState {
  const StoreProfileState({
    this.status = StoreProfileLoadStatus.initial,
    this.hasStore = false,
    this.store,
    this.error,
  });

  final StoreProfileLoadStatus status;
  final bool hasStore;
  final StoreProfileModel? store;
  final String? error;

  static const Object _unset = Object();

  StoreProfileState copyWith({
    StoreProfileLoadStatus? status,
    bool? hasStore,
    Object? store = _unset,
    Object? error = _unset,
  }) {
    return StoreProfileState(
      status: status ?? this.status,
      hasStore: hasStore ?? this.hasStore,
      store: identical(store, _unset)
          ? this.store
          : store as StoreProfileModel?,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}
