import 'package:_96_sooq/features/offers/data/offers_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'offers_event.dart';
import 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  final OffersApiService apiService;

  OffersBloc({required this.apiService}) : super(const OffersState()) {
    on<FetchOffers>(_onFetchOffers);
  }

  Future<void> _onFetchOffers(
    FetchOffers event,
    Emitter<OffersState> emit,
  ) async {
    if (state.hasReachedMax && !event.isRefresh) return;

    try {
      if (state.status == OffersStatus.initial || event.isRefresh) {
        emit(
          state.copyWith(
            status: OffersStatus.loading,
            skip: 0,
            hasReachedMax: false,
            offers: [],
            errorMessage: '',
          ),
        );

        final offers = await apiService.fetchOffers(
          skip: 0,
          limit: event.limit,
        );

        emit(
          state.copyWith(
            status: OffersStatus.success,
            offers: offers,
            hasReachedMax: offers.length < event.limit,
            skip: offers.length,
          ),
        );
      } else {
        emit(state.copyWith(status: OffersStatus.loading));
        final offers = await apiService.fetchOffers(
          skip: state.skip,
          limit: event.limit,
        );

        emit(
          offers.isEmpty
              ? state.copyWith(
                  hasReachedMax: true,
                  status: OffersStatus.success,
                )
              : state.copyWith(
                  status: OffersStatus.success,
                  offers: List.of(state.offers)..addAll(offers),
                  hasReachedMax: offers.length < event.limit,
                  skip: state.skip + offers.length,
                ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: OffersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
