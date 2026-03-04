import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/deals/bloc/chat/chat_bloc.dart';
import 'package:_96_sooq/features/deals/bloc/chat_list/chat_list_bloc.dart';
import 'package:_96_sooq/features/deals/data/models/chat_conversation_model.dart';
import 'package:_96_sooq/features/deals/view/screens/chats/chat_screen.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/shared/global_widgets/search_white_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum _ChatFilter { all, buying, selling }

class ChatListingScreen extends StatefulWidget {
  const ChatListingScreen({super.key});

  @override
  State<ChatListingScreen> createState() => _ChatListingScreenState();
}

class _ChatListingScreenState extends State<ChatListingScreen> {
  _ChatFilter _filter = _ChatFilter.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  Future<void> _loadUserAndFetch() async {
    final user = await AuthSessionRepository().getCachedUser();
    if (mounted) {
      setState(() => _currentUserId = user?.id);
      context.read<ChatListBloc>().add(const ChatListFetched());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatConversationModel> _applyFilters(
    List<ChatConversationModel> conversations,
  ) {
    var filtered = conversations;

    // Filter by role
    if (_filter == _ChatFilter.buying && _currentUserId != null) {
      filtered = filtered.where((c) => c.buyerId == _currentUserId).toList();
    } else if (_filter == _ChatFilter.selling && _currentUserId != null) {
      filtered = filtered.where((c) => c.sellerId == _currentUserId).toList();
    }

    // Filter by search query (search in listing title, store name, or sender name)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        String displayName = '';
        if (c.otherParticipantType == 'store') {
          displayName = c.storeName ?? '';
        } else {
          displayName = c.otherParticipantName ?? c.senderName ?? '';
        }

        final title = c.listing?.title?.toLowerCase() ?? '';
        final name = displayName.toLowerCase();

        return title.contains(_searchQuery) || name.contains(_searchQuery);
      }).toList();
    }

    return filtered;
  }

  void _openChat(ChatConversationModel conversation) {
    final userId = _currentUserId ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatBloc(
            currentUserId: userId,
            onInboxRefresh: () {
              // Silently refresh inbox when a message is sent/received
              if (mounted) {
                context.read<ChatListBloc>().add(const ChatListRefreshed());
              }
            },
          )..add(ChatOpened(conversation: conversation)),
          child: ChatScreen(
            currentUserId: userId,
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // ── Back Button + Title ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              BackButtonWidget(ontap: () => Navigator.pop(context)),
              Expanded(
                child: Center(
                  child: Text(
                    localizations.chatsTitle,
                    style: AppThemes.f18w600,
                  ),
                ),
              ),
              const SizedBox(width: 43), // balance the back button
            ],
          ),
        ),

        // ── Search Bar ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchbarWhiteWidget(
            labelText: localizations.search,
            controller: _searchController,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(height: 16),

        // ── Filter Chips ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: localizations.allText,
                isSelected: _filter == _ChatFilter.all,
                onTap: () => setState(() => _filter = _ChatFilter.all),
              ),
              const SizedBox(width: 10),
              _FilterChip(
                label: localizations.buyingText,
                isSelected: _filter == _ChatFilter.buying,
                onTap: () => setState(() => _filter = _ChatFilter.buying),
              ),
              const SizedBox(width: 10),
              _FilterChip(
                label: localizations.sellingText,
                isSelected: _filter == _ChatFilter.selling,
                onTap: () => setState(() => _filter = _ChatFilter.selling),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Chat List ──
        Expanded(
          child: BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, state) {
              if (state.status == ChatListStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state.status == ChatListStatus.failure) {
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
                        Text('Could not load chats', style: AppThemes.f16w600),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.read<ChatListBloc>().add(
                            const ChatListFetched(),
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

              final conversations = _applyFilters(state.conversations);

              if (conversations.isEmpty) {
                return Center(
                  child: Text(
                    localizations.noConversationsYetText,
                    style: AppThemes.f16w500.copyWith(
                      color: AppColors.productListingTextColor,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () async {
                  context.read<ChatListBloc>().add(const ChatListRefreshed());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: conversations.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _ChatRow(
                      conversation: conversation,
                      onTap: () => _openChat(conversation),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFDDE2EA),
          ),
        ),
        child: Text(
          label,
          style: AppThemes.f14w600.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6E7A8A),
          ),
        ),
      ),
    );
  }
}

// ─── Chat Row ────────────────────────────────────────────────────────────────

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.conversation, required this.onTap});

  final ChatConversationModel conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Determine the display name and image depending on participant type
    String displayName = 'Chat';
    String? displayImage;

    if (conversation.otherParticipantType == 'store') {
      displayName = conversation.storeName ?? 'Store';
      displayImage = conversation.storeLogo;
    } else {
      displayName =
          conversation.otherParticipantName ??
          conversation.senderName ??
          'User';
      displayImage =
          conversation.otherParticipantImage ?? conversation.senderLogo;
    }

    final lastMsg = conversation.lastMessage ?? 'Tap to start chatting';
    final time = conversation.lastMessageAt != null
        ? DateFormat('hh:mm a').format(conversation.lastMessageAt!.toLocal())
        : '';
    final unread = conversation.unreadCount;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // ── Avatar ──
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: displayImage != null && displayImage.isNotEmpty
                  ? AppNetworkImage(
                      imageUrl: displayImage,
                      width: 52,
                      height: 52,
                      shape: BoxShape.circle,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFFE0E4E8),
                      alignment: Alignment.center,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: AppThemes.f20w600.copyWith(
                          color: const Color(0xFF596579),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),

            // ── Text ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: unread > 0
                              ? AppThemes.f16w600
                              : AppThemes.f16w500,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: AppThemes.f12w500.copyWith(
                            color: unread > 0
                                ? AppColors.primaryColor
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppThemes.f14w400.copyWith(
                            color: unread > 0
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unread > 9 ? '9+' : unread.toString(),
                            style: AppThemes.f12w700.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
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
