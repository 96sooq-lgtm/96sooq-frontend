import 'dart:async';
import 'dart:developer' as developer;

import 'package:_96_sooq/features/deals/data/models/chat_conversation_model.dart';
import 'package:_96_sooq/features/deals/data/models/chat_message_model.dart';
import 'package:_96_sooq/features/deals/data/services/chat_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

sealed class ChatEvent {
  const ChatEvent();
}

/// Initiate chat for a listing (from product detail sheet).
class ChatInitiated extends ChatEvent {
  const ChatInitiated({required this.listingId});
  final String listingId;
}

/// Open an existing conversation and load its messages.
class ChatOpened extends ChatEvent {
  const ChatOpened({required this.conversation});
  final ChatConversationModel conversation;
}

/// Load / reload messages for the current conversation.
class ChatMessagesRequested extends ChatEvent {
  const ChatMessagesRequested();
}

/// User tapped send.
class ChatMessageSent extends ChatEvent {
  const ChatMessageSent({
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.offerAmount,
    this.retryMessageId,
  });
  final String content;
  final String messageType;
  final String? mediaUrl;
  final double? offerAmount;
  final String? retryMessageId;
}

/// A new message arrived via Supabase Realtime.
class ChatMessageReceived extends ChatEvent {
  const ChatMessageReceived({required this.message});
  final ChatMessageModel message;
}

// ─── States ──────────────────────────────────────────────────────────────────

enum ChatStatus { initial, initiating, loading, ready, sending, failure }

class ChatState {
  const ChatState({
    this.status = ChatStatus.initial,
    this.conversation,
    this.messages = const <ChatMessageModel>[],
    this.error,
  });

  final ChatStatus status;
  final ChatConversationModel? conversation;
  final List<ChatMessageModel> messages;
  final String? error;

  ChatState copyWith({
    ChatStatus? status,
    ChatConversationModel? conversation,
    List<ChatMessageModel>? messages,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}

// ─── Bloc ────────────────────────────────────────────────────────────────────

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required this.currentUserId,
    ChatApiService? apiService,
    this.onInboxRefresh,
  }) : _api = apiService ?? const ChatApiService(),
       super(const ChatState()) {
    on<ChatInitiated>(_onInitiated);
    on<ChatOpened>(_onOpened);
    on<ChatMessagesRequested>(_onMessagesRequested);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatMessageReceived>(_onMessageReceived);
  }

  final String currentUserId;
  final ChatApiService _api;

  /// Called when a message is sent or received so the parent can refresh inbox.
  final void Function()? onInboxRefresh;

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onInitiated(
    ChatInitiated event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.initiating));
    try {
      final conversation = await _api.initiateChat(event.listingId);
      emit(
        state.copyWith(status: ChatStatus.loading, conversation: conversation),
      );
      add(const ChatMessagesRequested());
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onOpened(ChatOpened event, Emitter<ChatState> emit) async {
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        conversation: event.conversation,
      ),
    );
    add(const ChatMessagesRequested());
  }

  Future<void> _onMessagesRequested(
    ChatMessagesRequested event,
    Emitter<ChatState> emit,
  ) async {
    final conversationId = state.conversation?.id;
    if (conversationId == null) return;

    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final messages = await _api.getMessages(conversationId);
      _api.markRead(conversationId).catchError((_) {});

      emit(state.copyWith(status: ChatStatus.ready, messages: messages));
      _subscribeToRealtime(conversationId);
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final conversationId = state.conversation?.id;
    if (conversationId == null) return;

    final isRetry = event.retryMessageId != null;
    final tempId = isRetry
        ? event.retryMessageId!
        : 'temp_${DateTime.now().millisecondsSinceEpoch}';

    emit(state.copyWith(status: ChatStatus.sending));

    if (isRetry) {
      final retryMsgIndex = state.messages.indexWhere(
        (m) => m.id == tempId && m.hasError,
      );
      if (retryMsgIndex == -1) return;

      final updatedMessages = List<ChatMessageModel>.from(state.messages);
      updatedMessages[retryMsgIndex] = updatedMessages[retryMsgIndex].copyWith(
        hasError: false,
      );
      emit(state.copyWith(status: ChatStatus.ready, messages: updatedMessages));
    } else {
      // Create a temporary optimistic message
      final optimisticMsg = ChatMessageModel(
        id: tempId,
        chatId: conversationId,
        senderId: currentUserId,
        content: event.content,
        messageType: event.messageType,
        mediaUrl: event.mediaUrl,
        offerAmount: event.offerAmount,
        createdAt: DateTime.now(),
      );

      final optimisticMessages = List<ChatMessageModel>.from(state.messages)
        ..add(optimisticMsg);
      emit(
        state.copyWith(status: ChatStatus.ready, messages: optimisticMessages),
      );
    }

    try {
      final sentMessage = await _api.sendMessage(
        conversationId,
        content: event.content,
        messageType: event.messageType,
        mediaUrl: event.mediaUrl,
        offerAmount: event.offerAmount,
      );

      // Re-fetch local state because other messages might have arrived during API call
      final currentMessages = List<ChatMessageModel>.from(state.messages);
      final index = currentMessages.indexWhere((m) => m.id == tempId);

      if (index != -1) {
        currentMessages[index] = sentMessage;
      } else {
        currentMessages.add(sentMessage);
      }

      emit(state.copyWith(status: ChatStatus.ready, messages: currentMessages));
      onInboxRefresh?.call();
    } catch (e) {
      // Mark optimistic message as failed
      final currentMessages = List<ChatMessageModel>.from(state.messages);
      final index = currentMessages.indexWhere((m) => m.id == tempId);

      if (index != -1) {
        currentMessages[index] = currentMessages[index].copyWith(
          hasError: true,
        );
      }

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          messages: currentMessages,
          error: e.toString(),
        ),
      );
    }
  }

  void _onMessageReceived(ChatMessageReceived event, Emitter<ChatState> emit) {
    if (event.message.senderId == currentUserId) return;

    // Check if we already have this message by ID
    final exists = state.messages.any((m) => m.id == event.message.id);
    if (exists) return;

    // Check if we just sent this exact message (ignore duplicate payload)
    final recentlyAdded = state.messages.any(
      (m) =>
          m.content == event.message.content &&
          m.createdAt.difference(event.message.createdAt).inSeconds.abs() < 5,
    );
    if (recentlyAdded) return;

    final updatedMessages = List<ChatMessageModel>.from(state.messages)
      ..add(event.message);

    emit(state.copyWith(messages: updatedMessages));

    // Refresh inbox so last message updates in chat listing
    onInboxRefresh?.call();
  }

  // ── Supabase Broadcast (instant) only ──────────────────────────────────────

  void _subscribeToRealtime(String conversationId) {
    _activeChannel?.unsubscribe();
    _activeChannel = null;

    final channel = Supabase.instance.client
        .channel('db-messages-$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            try {
              final message = ChatMessageModel.fromJson(
                Map<String, dynamic>.from(payload.newRecord),
              );
              add(ChatMessageReceived(message: message));
            } catch (e) {
              developer.log('Realtime parse error: $e', name: 'ChatBloc');
            }
          },
        )
        .subscribe();

    _activeChannel = channel;
  }

  RealtimeChannel? _activeChannel;

  @override
  Future<void> close() async {
    _activeChannel?.unsubscribe();
    return super.close();
  }
}
