import 'package:_96_sooq/features/deals/data/models/chat_conversation_model.dart';
import 'package:_96_sooq/features/deals/data/services/chat_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

sealed class ChatListEvent {
  const ChatListEvent();
}

class ChatListFetched extends ChatListEvent {
  const ChatListFetched();
}

class ChatListRefreshed extends ChatListEvent {
  const ChatListRefreshed();
}

// ─── States ──────────────────────────────────────────────────────────────────

enum ChatListStatus { initial, loading, success, failure }

class ChatListState {
  const ChatListState({
    this.status = ChatListStatus.initial,
    this.conversations = const <ChatConversationModel>[],
    this.error,
  });

  final ChatListStatus status;
  final List<ChatConversationModel> conversations;
  final String? error;

  ChatListState copyWith({
    ChatListStatus? status,
    List<ChatConversationModel>? conversations,
    String? error,
  }) {
    return ChatListState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      error: error,
    );
  }
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({ChatApiService? apiService})
    : _api = apiService ?? const ChatApiService(),
      super(const ChatListState()) {
    on<ChatListFetched>(_onFetched);
    on<ChatListRefreshed>(_onRefreshed);
  }

  final ChatApiService _api;

  Future<void> _onFetched(
    ChatListFetched event,
    Emitter<ChatListState> emit,
  ) async {
    emit(state.copyWith(status: ChatListStatus.loading));
    try {
      final conversations = await _api.getInbox();
      emit(
        state.copyWith(
          status: ChatListStatus.success,
          conversations: conversations,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatListStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onRefreshed(
    ChatListRefreshed event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      final conversations = await _api.getInbox();
      emit(
        state.copyWith(
          status: ChatListStatus.success,
          conversations: conversations,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ChatListStatus.failure, error: e.toString()));
    }
  }
}
