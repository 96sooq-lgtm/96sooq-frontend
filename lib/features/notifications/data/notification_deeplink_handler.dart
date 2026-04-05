import 'dart:async';

import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/deals/bloc/chat/chat_bloc.dart';
import 'package:_96_sooq/features/deals/data/models/chat_conversation_model.dart';
import 'package:_96_sooq/features/deals/data/services/chat_api_service.dart';
import 'package:_96_sooq/features/deals/view/screens/chats/chat_screen.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:_96_sooq/shared/app_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationDeepLinkHandler {
  NotificationDeepLinkHandler._();

  static const String _typeNewMessage = 'new_message';

  static Future<void> handle(Map<String, dynamic> data) async {
    final payload = _NotificationPayload.fromMap(data);
    if (payload == null) return;

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      await _retryOnce(data);
      return;
    }

    if (payload.type == _typeNewMessage) {
      await _openChat(navigator, payload);
    } else {
      _switchToDealsTab(navigator);
    }
  }

  static Future<void> _retryOnce(Map<String, dynamic> data) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;
    await handle(data);
  }

  static void _switchToDealsTab(NavigatorState navigator) {
    if (!navigator.mounted) return;
    navigator.context.read<RootBloc>().add(ChangeTabEvent(2));
  }

  static Future<void> _openChat(
    NavigatorState navigator,
    _NotificationPayload payload,
  ) async {
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id.trim();
    if (currentUserId == null || currentUserId.isEmpty) {
      if (navigator.mounted) {
        navigator.push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    _switchToDealsTab(navigator);

    final conversation = await _resolveConversation(payload);
    if (conversation == null || !navigator.mounted) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatBloc(currentUserId: currentUserId)
            ..add(ChatOpened(conversation: conversation)),
          child: ChatScreen(
            currentUserId: currentUserId,
            userName: conversation.listing?.title ?? 'Chat',
            listingTitle: conversation.listing?.title,
            listingPrice: conversation.listing?.price,
            listingCurrency: conversation.listing?.currency,
            listingImageUrl: conversation.listing?.imageUrl,
            listingId: conversation.listingId,
          ),
        ),
      ),
    );
  }

  static Future<ChatConversationModel?> _resolveConversation(
    _NotificationPayload payload,
  ) async {
    final api = const ChatApiService();

    if (payload.conversationId != null &&
        payload.conversationId!.isNotEmpty) {
      try {
        final inbox = await api.getInbox();
        for (final conversation in inbox) {
          if (conversation.id == payload.conversationId) {
            return conversation;
          }
        }
      } catch (_) {
        // Fall through to listing-based initiate
      }
    }

    final listingId = payload.listingId;
    if (listingId != null && listingId.isNotEmpty) {
      try {
        return await api.initiateChat(listingId);
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}

class _NotificationPayload {
  _NotificationPayload({
    required this.type,
    this.conversationId,
    this.listingId,
  });

  final String type;
  final String? conversationId;
  final String? listingId;

  static _NotificationPayload? fromMap(Map<String, dynamic> data) {
    final type = data['type']?.toString().trim() ?? '';
    if (type.isEmpty) return null;
    return _NotificationPayload(
      type: type,
      conversationId: data['conversation_id']?.toString().trim(),
      listingId: data['listing_id']?.toString().trim(),
    );
  }
}
