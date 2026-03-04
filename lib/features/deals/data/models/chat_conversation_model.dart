class ChatConversationModel {
  const ChatConversationModel({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.buyerUnread,
    required this.sellerUnread,
    required this.unreadCount,
    required this.createdAt,
    this.lastMessage,
    this.lastMessageAt,
    this.myRole,
    this.listing,
    this.otherParticipantName,
    this.otherParticipantImage,
    this.otherParticipantType,
    this.storeName,
    this.storeLogo,
    this.senderName,
    this.senderLogo,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final String status;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int buyerUnread;
  final int sellerUnread;
  final int unreadCount;
  final String? myRole;
  final ChatListingInfo? listing;
  final DateTime createdAt;
  final String? otherParticipantName;
  final String? otherParticipantImage;
  final String? otherParticipantType;
  final String? storeName;
  final String? storeLogo;
  final String? senderName;
  final String? senderLogo;

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final listingRaw = json['listing'];
    final listing = listingRaw is Map<String, dynamic>
        ? ChatListingInfo.fromJson(listingRaw)
        : null;

    return ChatConversationModel(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listing_id'] ?? '').toString(),
      buyerId: (json['buyer_id'] ?? '').toString(),
      sellerId: (json['seller_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      lastMessage: json['last_message']?.toString(),
      lastMessageAt: DateTime.tryParse(
        (json['last_message_at'] ?? '').toString(),
      ),
      buyerUnread: int.tryParse((json['buyer_unread'] ?? '0').toString()) ?? 0,
      sellerUnread:
          int.tryParse((json['seller_unread'] ?? '0').toString()) ?? 0,
      unreadCount: int.tryParse((json['unread_count'] ?? '0').toString()) ?? 0,
      myRole: json['my_role']?.toString(),
      listing: listing,
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      otherParticipantName: json['other_participant_name']?.toString(),
      otherParticipantImage: json['other_participant_image']?.toString(),
      otherParticipantType: json['other_participant_type']?.toString(),
      storeName: json['store_name']?.toString(),
      storeLogo: json['store_logo']?.toString(),
      senderName: json['sender_name']?.toString(),
      senderLogo: json['sender_logo']?.toString(),
    );
  }

  /// The other participant's ID relative to the current user.
  String otherParticipantId(String currentUserId) =>
      currentUserId == buyerId ? sellerId : buyerId;
}

class ChatListingInfo {
  const ChatListingInfo({
    required this.id,
    this.title,
    this.imageUrl,
    this.price,
    this.currency,
  });

  final String id;
  final String? title;
  final String? imageUrl;
  final String? price;
  final String? currency;

  factory ChatListingInfo.fromJson(Map<String, dynamic> json) {
    return ChatListingInfo(
      id: (json['id'] ?? '').toString(),
      title: json['title']?.toString(),
      imageUrl: (json['image_url'] ?? json['images']?.toString())?.toString(),
      price: json['price']?.toString(),
      currency: json['currency']?.toString(),
    );
  }
}
