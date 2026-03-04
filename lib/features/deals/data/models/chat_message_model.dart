class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.senderName,
    this.senderImage,
    this.mediaUrl,
    this.offerAmount,
    this.hasError = false,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final String? senderName;
  final String? senderImage;
  final String? mediaUrl;
  final double? offerAmount;
  final DateTime createdAt;
  final bool hasError;

  bool get isSending => id.startsWith('temp_');

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? messageType,
    String? senderName,
    String? senderImage,
    String? mediaUrl,
    double? offerAmount,
    DateTime? createdAt,
    bool? hasError,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      offerAmount: offerAmount ?? this.offerAmount,
      createdAt: createdAt ?? this.createdAt,
      hasError: hasError ?? this.hasError,
    );
  }

  bool isOutgoing(String currentUserId) => senderId == currentUserId;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: (json['id'] ?? '').toString(),
      chatId: (json['chat_id'] ?? json['conversation_id'] ?? '').toString(),
      senderId: (json['sender_id'] ?? '').toString(),
      senderName: json['sender_name']?.toString(),
      senderImage: json['sender_image']?.toString(),
      content: (json['content'] ?? '').toString(),
      messageType: (json['message_type'] ?? 'text').toString(),
      mediaUrl: json['media_url']?.toString(),
      offerAmount: double.tryParse((json['offer_amount'] ?? '').toString()),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      hasError: json['has_error'] == true,
    );
  }
}
