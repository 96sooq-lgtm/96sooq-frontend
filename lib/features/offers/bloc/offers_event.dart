import 'package:equatable/equatable.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object> get props => [];
}

class FetchOffers extends OffersEvent {
  final int limit;
  final bool isRefresh;
  final String? governorate;

  const FetchOffers({
    this.limit = 10,
    this.isRefresh = false,
    this.governorate,
  });

  @override
  List<Object> get props => [
    limit,
    isRefresh,
    if (governorate != null) governorate!,
  ];
}
