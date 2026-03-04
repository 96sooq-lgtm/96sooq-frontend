import 'package:_96_sooq/features/offers/model/offer_story_item.dart';
import 'package:equatable/equatable.dart';

enum OffersStatus { initial, loading, success, failure }

class OffersState extends Equatable {
  final OffersStatus status;
  final List<OfferStoryItem> offers;
  final bool hasReachedMax;
  final int skip;
  final String errorMessage;

  const OffersState({
    this.status = OffersStatus.initial,
    this.offers = const <OfferStoryItem>[],
    this.hasReachedMax = false,
    this.skip = 0,
    this.errorMessage = '',
  });

  OffersState copyWith({
    OffersStatus? status,
    List<OfferStoryItem>? offers,
    bool? hasReachedMax,
    int? skip,
    String? errorMessage,
  }) {
    return OffersState(
      status: status ?? this.status,
      offers: offers ?? this.offers,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      skip: skip ?? this.skip,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, offers, hasReachedMax, skip, errorMessage];
}
