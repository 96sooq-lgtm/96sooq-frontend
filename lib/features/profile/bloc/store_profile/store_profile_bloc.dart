import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_state.dart';
import 'package:_96_sooq/features/profile/data/store_profile_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreProfileBloc extends Bloc<StoreProfileEvent, StoreProfileState> {
  StoreProfileBloc({StoreProfileApiService? storeProfileApiService})
    : _storeProfileApiService =
          storeProfileApiService ?? const StoreProfileApiService(),
      super(const StoreProfileState()) {
    on<StoreProfileCheckRequested>(_onStoreProfileCheckRequested);
    on<StoreProfileCleared>(_onStoreProfileCleared);
    on<StoreProfileMarkedCreated>(_onStoreProfileMarkedCreated);
  }

  final StoreProfileApiService _storeProfileApiService;

  Future<void> _onStoreProfileCheckRequested(
    StoreProfileCheckRequested event,
    Emitter<StoreProfileState> emit,
  ) async {
    emit(state.copyWith(status: StoreProfileLoadStatus.loading, error: null));

    try {
      final response = await _storeProfileApiService.checkStore();
      emit(
        state.copyWith(
          status: StoreProfileLoadStatus.success,
          hasStore: response.hasStore,
          store: response.store,
          error: null,
        ),
      );
    } catch (e) {
      final keepOptimisticStore = state.hasStore;
      emit(
        state.copyWith(
          status: keepOptimisticStore
              ? StoreProfileLoadStatus.success
              : StoreProfileLoadStatus.failure,
          hasStore: keepOptimisticStore,
          store: keepOptimisticStore ? state.store : null,
          error: e.toString(),
        ),
      );
    }
  }

  void _onStoreProfileCleared(
    StoreProfileCleared event,
    Emitter<StoreProfileState> emit,
  ) {
    emit(const StoreProfileState());
  }

  void _onStoreProfileMarkedCreated(
    StoreProfileMarkedCreated event,
    Emitter<StoreProfileState> emit,
  ) {
    emit(
      state.copyWith(
        status: StoreProfileLoadStatus.success,
        hasStore: true,
        error: null,
      ),
    );
  }
}
