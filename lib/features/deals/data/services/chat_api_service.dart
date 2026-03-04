import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/deals/data/models/chat_conversation_model.dart';
import 'package:_96_sooq/features/deals/data/models/chat_message_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';

class ChatApiService {
  const ChatApiService();

  /// POST /api/chats/initiate — start or return existing conversation.
  Future<ChatConversationModel> initiateChat(String listingId) async {
    final response = await DioServices.client.post(
      ApiEndpoints.chatInitiate,
      data: {'listing_id': listingId},
    );
    return ChatConversationModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// GET /api/chats/inbox — inbox list.
  Future<List<ChatConversationModel>> getInbox() async {
    final response = await DioServices.client.get(ApiEndpoints.chatInbox);
    final data = response.data;

    List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map<String, dynamic>) {
      rawList = data['conversations'] as List? ?? [];
    } else {
      rawList = [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ChatConversationModel.fromJson)
        .toList();
  }

  /// GET /api/chats/{id}/messages?limit=50 — message history.
  Future<List<ChatMessageModel>> getMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final response = await DioServices.client.get(
      ApiEndpoints.chatMessages(conversationId, limit: limit),
    );
    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ChatMessageModel.fromJson)
          .toList();
    }
    return <ChatMessageModel>[];
  }

  /// POST /api/chats/{id}/read — mark conversation read.
  Future<void> markRead(String conversationId) async {
    await DioServices.client.post(ApiEndpoints.chatRead(conversationId));
  }

  /// POST /api/chats/{id}/messages — send a message.
  Future<ChatMessageModel> sendMessage(
    String conversationId, {
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    double? offerAmount,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      'message_type': messageType,
    };
    if (mediaUrl != null) body['media_url'] = mediaUrl;
    if (offerAmount != null) body['offer_amount'] = offerAmount;

    final response = await DioServices.client.post(
      ApiEndpoints.chatSendMessage(conversationId),
      data: body,
    );
    return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
