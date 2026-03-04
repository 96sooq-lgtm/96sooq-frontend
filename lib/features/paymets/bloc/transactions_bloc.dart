import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/paymets/model/transaction_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

sealed class TransactionsEvent {
  const TransactionsEvent();
}

class TransactionsFetched extends TransactionsEvent {
  const TransactionsFetched();
}

// ─── States ──────────────────────────────────────────────────────────────────

enum TransactionsStatus { initial, loading, success, failure }

class TransactionsState {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const <TransactionModel>[],
    this.error,
  });

  final TransactionsStatus status;
  final List<TransactionModel> transactions;
  final String? error;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionModel>? transactions,
    String? error,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      error: error,
    );
  }
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc() : super(const TransactionsState()) {
    on<TransactionsFetched>(_onFetched);
  }

  Future<void> _onFetched(
    TransactionsFetched event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.myTransactions,
      );

      final data = response.data as Map<String, dynamic>?;
      final list = data?['transactions'] as List? ?? [];

      final transactions = list
          .whereType<Map<String, dynamic>>()
          .map(TransactionModel.fromJson)
          .toList();

      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: transactions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: TransactionsStatus.failure, error: e.toString()),
      );
    }
  }
}
