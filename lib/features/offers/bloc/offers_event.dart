import 'package:equatable/equatable.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object> get props => [];
}

class FetchOffers extends OffersEvent {
  final int limit;
  final bool isRefresh;

  const FetchOffers({this.limit = 10, this.isRefresh = false});

  @override
  List<Object> get props => [limit, isRefresh];
}
