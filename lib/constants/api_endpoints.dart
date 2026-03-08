class ApiEndpoints {
  static const String baseUrl = "https://nine6sooq-backend-1.onrender.com";
  static const String getAllCategory = "$baseUrl/api/categories/";
  static const String getCategoriesByParent =
      "$baseUrl/api/categories/?parent_id=";
  static const String locations = "$baseUrl/api/locations/";
  static const String locationsByStateType =
      '$locations?type=state&is_active=true';
  static String locationsByCityType(String stateId) =>
      '$locations?type=city&parent_id=$stateId';
  static const String checkUser = "$baseUrl/api/auth/oauth/check-user";
  static const String createAccount =
      "$baseUrl/api/auth/oauth/complete-profile";
  static const String listingPrices =
      "$baseUrl/api/subscriptions/listing-prices";
  static const String featuredBanners = "$baseUrl/api/banners/featured";
  static const String offers = "$baseUrl/api/feed/offers";
  static String feedCategory(String categoryId) =>
      "$baseUrl/api/feed/category/$categoryId";
  static const String uploadToS3 = "$baseUrl/storage/upload";
  static const String stores = "$baseUrl/api/stores/";
  static const String checkStore = "$baseUrl/api/stores/check";
  static String storesList({
    required int skip,
    required int limit,
    String? locationId,
    double? minRating,
  }) {
    final query = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    if (locationId != null && locationId.trim().isNotEmpty) {
      query['location_id'] = locationId.trim();
    }
    if (minRating != null) {
      query['min_rating'] = minRating.toString();
    }
    return Uri.parse(stores).replace(queryParameters: query).toString();
  }

  static String listingPricesByStoreType({required bool isStore}) =>
      '$listingPrices?is_store=${isStore.toString().toLowerCase()}';

  static const String adPricesUrl = "$baseUrl/api/subscriptions/ad-prices";
  static String adPrices({required bool isStore}) =>
      '$adPricesUrl?is_store=${isStore.toString().toLowerCase()}';

  static String storeListings({
    required String storeId,
    required int skip,
    required int limit,
    String? status,
  }) {
    final baseUrl = '$stores$storeId/listings?skip=$skip&limit=$limit';
    if (status != null && status.isNotEmpty) {
      return '$baseUrl&status=$status';
    }
    return baseUrl;
  }

  static String storeReviews({
    required String storeId,
    required int skip,
    required int limit,
  }) {
    return '$stores$storeId/reviews?skip=$skip&limit=$limit';
  }

  // ─── Payments ───────────────────────────────────────────────────────────────
  static const String paymentCheckout = '$baseUrl/api/payments/checkout';
  static String paymentStatus(String transactionId) =>
      '$baseUrl/api/payments/payment-check?transaction_id=$transactionId';
  static const String myTransactions = '$baseUrl/api/payments/my-transactions';
  static String myListings({String? status, int? skip, int? limit}) {
    final query = <String, String>{};
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (skip != null) {
      query['skip'] = skip.toString();
    }
    if (limit != null) {
      query['limit'] = limit.toString();
    }
    final uri = Uri.parse('$baseUrl/api/listings/my-listings');
    if (query.isEmpty) {
      return uri.toString();
    }
    return uri.replace(queryParameters: query).toString();
  }

  static String listingDetail(String listingId) =>
      '$baseUrl/api/listings/${listingId.trim()}';

  // ─── Chats ─────────────────────────────────────────────────────────────────
  static const String chatInitiate = '$baseUrl/api/chats/initiate';
  static const String chatInbox = '$baseUrl/api/chats/inbox';
  static String chatMessages(String conversationId, {int limit = 50}) =>
      '$baseUrl/api/chats/$conversationId/messages?limit=$limit';
  static String chatRead(String conversationId) =>
      '$baseUrl/api/chats/$conversationId/read';
  static String chatSendMessage(String conversationId) =>
      '$baseUrl/api/chats/$conversationId/messages';
  static const String chatScreenAd = '$baseUrl/api/feed/chat-screen-ad';

  // ─── Notifications ─────────────────────────────────────────────────────────
  static const String registerNotificationToken =
      '$baseUrl/api/notifications/register-token';
  static const String unregisterNotificationToken =
      '$baseUrl/api/notifications/unregister-token';
}
