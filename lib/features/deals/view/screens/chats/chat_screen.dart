import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/constants/api_endpoints.dart';
import 'package:_96_sooq/features/deals/bloc/chat/chat_bloc.dart';
import 'package:_96_sooq/features/deals/data/services/chat_screen_ad_api_service.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/shared/dio_services.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/features/home/widgets/product_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.currentUserId,
    this.userName = 'Seller',
    this.avatarUrl = '',
    this.listingTitle,
    this.listingPrice,
    this.listingImageUrl,
    this.listingCurrency,
    this.listingId,
  });

  final String currentUserId;
  final String userName;
  final String avatarUrl;
  final String? listingTitle;
  final String? listingPrice;
  final String? listingImageUrl;
  final String? listingCurrency;
  final String? listingId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ChatScreenAdApiService _chatScreenAdApiService =
      const ChatScreenAdApiService();

  // Product detail fetched from API
  String? _productTitle;
  String? _productPrice;
  String? _productCurrency;
  String? _productImageUrl;
  ProductModel? _chatScreenAdProduct;
  bool _hasShownChatAdPopup = false;

  @override
  void initState() {
    super.initState();
    // Initialize with passed-in data
    _productTitle = widget.listingTitle;
    _productPrice = widget.listingPrice;
    _productCurrency = widget.listingCurrency;
    _productImageUrl = widget.listingImageUrl;
    // Fetch full details from API
    if (widget.listingId != null) {
      _fetchListingDetail();
      _fetchChatScreenAd();
    }
  }

  Future<void> _fetchListingDetail() async {
    try {
      final response = await DioServices.client.get(
        ApiEndpoints.listingDetail(widget.listingId!),
      );
      final data = response.data as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _productTitle = data['title']?.toString() ?? _productTitle;
          _productPrice = data['price']?.toString() ?? _productPrice;
          _productCurrency = data['currency']?.toString() ?? _productCurrency;
          // Try to get the first image from images array
          final images = data['images'];
          if (images is List && images.isNotEmpty) {
            _productImageUrl = images.first.toString();
          } else if (data['image_url'] != null) {
            _productImageUrl = data['image_url'].toString();
          }
        });
      }
    } catch (_) {
      // Use fallback data from conversation
    }
  }

  Future<void> _fetchChatScreenAd() async {
    final adProduct = await _chatScreenAdApiService.fetchChatScreenAd();
    if (!mounted || adProduct == null || _hasShownChatAdPopup) return;

    _chatScreenAdProduct = adProduct;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _chatScreenAdProduct == null || _hasShownChatAdPopup) {
        return;
      }
      _hasShownChatAdPopup = true;
      _showChatAdPopup(_chatScreenAdProduct!);
    });
  }

  void _showChatAdPopup(ProductModel adProduct) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return _ChatAdPopup(
          product: adProduct,
          onClose: () => Navigator.pop(dialogContext),
          onTap: () {
            Navigator.pop(dialogContext);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => ProductDetailSheet(product: adProduct),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _conversationSenderName(ChatState state) {
    final conversation = state.conversation;
    if (conversation == null) return widget.userName;

    final isStorePeer = conversation.otherParticipantType == 'store';
    final storeName = (conversation.storeName ?? '').trim();
    final otherName = (conversation.otherParticipantName ?? '').trim();
    final senderName = (conversation.senderName ?? '').trim();

    if (isStorePeer && storeName.isNotEmpty) return storeName;
    if (otherName.isNotEmpty) return otherName;
    if (senderName.isNotEmpty) return senderName;
    if (storeName.isNotEmpty) return storeName;
    return widget.userName;
  }

  String _conversationSenderImage(ChatState state) {
    final conversation = state.conversation;
    if (conversation == null) return widget.avatarUrl;

    final isStorePeer = conversation.otherParticipantType == 'store';
    final storeLogo = (conversation.storeLogo ?? '').trim();
    final otherImage = (conversation.otherParticipantImage ?? '').trim();
    final senderLogo = (conversation.senderLogo ?? '').trim();

    if (isStorePeer && storeLogo.isNotEmpty) return storeLogo;
    if (otherImage.isNotEmpty) return otherImage;
    if (senderLogo.isNotEmpty) return senderLogo;
    if (storeLogo.isNotEmpty) return storeLogo;
    return widget.avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: _ChatComposer(
        onSend: (text) {
          context.read<ChatBloc>().add(ChatMessageSent(content: text));
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Show sender name from the first incoming message
            BlocBuilder<ChatBloc, ChatState>(
              buildWhen: (prev, curr) =>
                  prev.messages.length != curr.messages.length,
              builder: (context, state) {
                String displayName = _conversationSenderName(state);
                String displayAvatar = _conversationSenderImage(state);
                for (final msg in state.messages) {
                  if (!msg.isOutgoing(widget.currentUserId)) {
                    if (msg.senderName != null && msg.senderName!.isNotEmpty) {
                      displayName = msg.senderName!;
                    }
                    if (msg.senderImage != null &&
                        msg.senderImage!.isNotEmpty) {
                      displayAvatar = msg.senderImage!;
                    }
                    break;
                  }
                }
                return _HeaderSection(
                  userName: displayName,
                  avatarUrl: displayAvatar,
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFECEFF3)),
            // ── Product Info Card ──
            if (_productTitle != null)
              _ProductInfoCard(
                title: _productTitle!,
                price: _productPrice,
                currency: _productCurrency,
                imageUrl: _productImageUrl,
              ),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  // Auto-scroll when new messages arrive
                  if (state.status == ChatStatus.ready ||
                      state.status == ChatStatus.sending) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state.status == ChatStatus.initiating ||
                      state.status == ChatStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (state.status == ChatStatus.failure &&
                      state.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Color(0xFFCB3A31),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Could not load messages',
                              style: AppThemes.f16w600,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => context.read<ChatBloc>().add(
                                const ChatMessagesRequested(),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Retry',
                                  style: AppThemes.f14w600.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'No messages yet.\nSay hello! 👋',
                        textAlign: TextAlign.center,
                        style: AppThemes.f16w500.copyWith(
                          color: AppColors.productListingTextColor,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    itemCount: messages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isOutgoing = message.isOutgoing(
                        widget.currentUserId,
                      );
                      final timeStr = DateFormat(
                        'hh:mm a',
                      ).format(message.createdAt.toLocal());

                      if (isOutgoing) {
                        return _OutgoingBlock(
                          message: message.content,
                          time: timeStr,
                          hasError: message.hasError,
                          isSending: message.isSending,
                          onRetry: () {
                            context.read<ChatBloc>().add(
                              ChatMessageSent(
                                content: message.content,
                                messageType: message.messageType,
                                mediaUrl: message.mediaUrl,
                                offerAmount: message.offerAmount,
                                retryMessageId: message.id,
                              ),
                            );
                          },
                        );
                      } else {
                        final fallbackName = _conversationSenderName(state);
                        final fallbackImage = _conversationSenderImage(state);
                        return _IncomingBlock(
                          senderName:
                              (message.senderName ?? '').trim().isNotEmpty
                              ? message.senderName!
                              : fallbackName,
                          senderImage:
                              (message.senderImage ?? '').trim().isNotEmpty
                              ? message.senderImage!
                              : fallbackImage,
                          message: message.content,
                          time: timeStr,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAdPopup extends StatefulWidget {
  const _ChatAdPopup({
    required this.product,
    required this.onClose,
    required this.onTap,
  });

  final ProductModel product;
  final VoidCallback onClose;
  final VoidCallback onTap;

  @override
  State<_ChatAdPopup> createState() => _ChatAdPopupState();
}

class _ChatAdPopupState extends State<_ChatAdPopup> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> get _images {
    if (widget.product.images.isNotEmpty) return widget.product.images;
    if (widget.product.imageUrl.trim().isNotEmpty) {
      return <String>[widget.product.imageUrl.trim()];
    }
    return const <String>[];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.62,
                color: Colors.black,
                child: _images.isEmpty
                    ? const SizedBox.shrink()
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _images.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return AppNetworkImage(
                            imageUrl: _images[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
          if (_images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_images.length, (index) {
                  final isActive = _currentPage == index;
                  return Container(
                    width: isActive ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.userName, required this.avatarUrl});

  final String userName;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          BackButtonWidget(ontap: () => Navigator.pop(context)),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: avatarUrl,
                    width: 38,
                    height: 38,
                    shape: BoxShape.circle,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: const Color(0xFFE0E4E8),
                    alignment: Alignment.center,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: AppThemes.f16w600.copyWith(
                        color: const Color(0xFF596579),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(userName, style: AppThemes.f16w600)),
          // const Icon(Icons.call_outlined, size: 24, color: Color(0xFF111827)),
          // const SizedBox(width: 12),
          // const Icon(Icons.more_vert, size: 24, color: Color(0xFF111827)),
        ],
      ),
    );
  }
}

// ─── Product Info Card ───────────────────────────────────────────────────────

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({
    required this.title,
    this.price,
    this.currency,
    this.imageUrl,
  });

  final String title;
  final String? price;
  final String? currency;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          // Listing image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(10),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (price != null)
                  Text(
                    '$price ${currency ?? ''}',
                    style: AppThemes.f14w600.copyWith(
                      color: const Color(0xFF111827),
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppThemes.f12w500.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Outgoing Bubble ─────────────────────────────────────────────────────────

class _OutgoingBlock extends StatelessWidget {
  const _OutgoingBlock({
    required this.message,
    required this.time,
    this.hasError = false,
    this.isSending = false,
    this.onRetry,
  });

  final String message;
  final String time;
  final bool hasError;
  final bool isSending;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.68,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(
              message,
              style: AppThemes.f14w500.copyWith(
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (hasError)
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFCB3A31),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '!',
                    style: AppThemes.f12w600.copyWith(color: Colors.white),
                  ),
                ),
              )
            else ...[
              Icon(
                Icons.check_circle,
                size: 14,
                color: isSending
                    ? const Color(0xFFB1B7C0)
                    : AppColors.primaryColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              time,
              style: AppThemes.f12w500.copyWith(color: const Color(0xFF596579)),
            ),
            const SizedBox(width: 10),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB1B7C0),
              ),
              alignment: Alignment.center,
              child: Text(
                'You',
                style: AppThemes.f10w500.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Incoming Bubble ─────────────────────────────────────────────────────────

class _IncomingBlock extends StatelessWidget {
  const _IncomingBlock({
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.time,
  });

  final String senderName;
  final String senderImage;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF0F1F3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomRight: Radius.circular(22),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: Text(
            message,
            style: AppThemes.f12w500.copyWith(
              color: const Color(0xFF101418),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: senderImage.isNotEmpty
                  ? AppNetworkImage(
                      imageUrl: senderImage,
                      width: 30,
                      height: 30,
                      shape: BoxShape.circle,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFFE0E4E8),
                      alignment: Alignment.center,
                      child: Text(
                        senderName.isNotEmpty
                            ? senderName[0].toUpperCase()
                            : '?',
                        style: AppThemes.f12w600.copyWith(
                          color: const Color(0xFF596579),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Text(
              time,
              style: AppThemes.f12w500.copyWith(color: const Color(0xFF596579)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Composer ────────────────────────────────────────────────────────────────

class _ChatComposer extends StatefulWidget {
  const _ChatComposer({required this.onSend});
  final ValueChanged<String> onSend;

  @override
  State<_ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<_ChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    // Some static suggestions (you can easily localize these later)
    final suggestions = [
      "Is this available?",
      "Can you do a better price?",
      "I'm interested.",
      "Are you willing to trade?",
      "Where are you located?",
    ];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Suggestions List ──
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _controller.text = suggestions[index];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.primaryColor.withValues(alpha: 0.05),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        suggestions[index],
                        style: AppThemes.f14w500.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Input Row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: AppColors.primaryColor,
                        style: AppThemes.f14w500.copyWith(
                          color: AppColors.brandBlack,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.typeAMessage,
                          hintStyle: AppThemes.f14w400.copyWith(
                            color: const Color(0xFF465569),
                          ),
                          isCollapsed: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _handleSend,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
