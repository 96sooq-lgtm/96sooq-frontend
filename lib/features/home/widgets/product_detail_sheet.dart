import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/deals/bloc/chat/chat_bloc.dart';
import 'package:_96_sooq/features/deals/data/services/chat_api_service.dart';
import 'package:_96_sooq/features/deals/view/screens/chats/chat_screen.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_bloc.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_event.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_state.dart';
import 'package:_96_sooq/features/profile/view/screens/store_details_screen.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:_96_sooq/shared/global_widgets/custom_icon_button_white.dart';
import 'package:_96_sooq/shared/global_widgets/custom_icon_button_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailSheet extends StatefulWidget {
  final ProductModel product;
  final bool hideActions;

  const ProductDetailSheet({
    super.key,
    required this.product,
    this.hideActions = false,
  });

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;

  @override
  void initState() {
    super.initState();
    _favoriteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _favoriteScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
        ]).animate(
          CurvedAnimation(
            parent: _favoriteAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final product = widget.product;
    final hideActions = widget.hideActions;
    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.93,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(46),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        _ImageCarousel(product: product),
                        PositionedDirectional(
                          top: 16,
                          start: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.brandBlack,
                              ),
                            ),
                          ),
                        ),
                        if (!hideActions) ...[
                          PositionedDirectional(
                            top: 16,
                            end: 16,
                            child: BlocBuilder<FavoriteBloc, FavoriteState>(
                              builder: (context, state) {
                                final isFavoriteLocal = state.favorites
                                    .contains(product.id);
                                final isUnfavoriteLocal = state.unfavorites
                                    .contains(product.id);
                                final isFavorite =
                                    isFavoriteLocal ||
                                    (product.isFavorite && !isUnfavoriteLocal);

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    HapticFeedback.lightImpact();

                                    final authState = context
                                        .read<AuthBloc>()
                                        .state;
                                    if (authState is! AuthAuthenticated) {
                                      // Not logged in, redirect to login screen
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );

                                      // If login was successful, change tab to Deals (index 2)
                                      if (result == true && context.mounted) {
                                        Navigator.pop(
                                          context,
                                        ); // Close the bottom sheet
                                        context.read<RootBloc>().add(
                                          ChangeTabEvent(2),
                                        );
                                      }
                                      return;
                                    }

                                    _favoriteAnimationController.forward(
                                      from: 0.0,
                                    );
                                    context.read<FavoriteBloc>().add(
                                      ToggleFavoriteEvent(
                                        product.id,
                                        initialFavoriteState: isFavorite,
                                      ),
                                    );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _favoriteScaleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _favoriteScaleAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.white,
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 20,
                                        color: isFavorite
                                            ? AppColors.favoriteRed
                                            : const Color(0xFF8F9BB3),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        // Status chip removed
                      ],
                    ),

                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final isIndividual =
                            product.sellerType?.toLowerCase() == 'individual';

                        final String displayName = isIndividual
                            ? ((product.userName?.trim().isNotEmpty == true)
                                  ? product.userName!
                                  : 'Seller')
                            : ((product.storeName?.trim().isNotEmpty == true)
                                  ? product.storeName!
                                  : 'Store');

                        final String? displayImageUrl = isIndividual
                            ? product.userProfilePicture
                            : product.storeLogo;

                        final Widget fallbackIcon = isIndividual
                            ? const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 20,
                              )
                            : const Icon(
                                Icons.storefront_outlined,
                                color: Colors.white,
                                size: 20,
                              );

                        final bool isStore = !isIndividual;

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: isStore
                              ? () {
                                  Navigator.pop(context); // close bottom sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StoreDetailsScreen(
                                        storeId: product.storeId,
                                        storeName: product.storeName,
                                        storeLogoUrl: product.storeLogo,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child:
                                    (displayImageUrl != null &&
                                        displayImageUrl.trim().isNotEmpty)
                                    ? AppNetworkImage(
                                        imageUrl: displayImageUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : fallbackIcon,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: AppThemes.f14w500.copyWith(
                                    color: AppColors.brandBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isStore)
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Color(0xFF8F9BB3),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: AppThemes.f20w700.copyWith(
                              color: AppColors.brandBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          product.amount,
                          style: AppThemes.f20w700.copyWith(
                            color: AppColors.brandBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_getLocationText(context).isNotEmpty)
                      IntrinsicWidth(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            color: const Color(0xFFF5F5F5),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Color(0xFF8F9BB3),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getLocationText(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppThemes.f12w500.copyWith(
                                  color: AppColors.brandBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (product.details.trim().isNotEmpty) ...[
                      Text(
                        product.details.trim(),
                        style: AppThemes.f14w400.copyWith(
                          color: const Color(0xFF8F9BB3),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        if ((product.condition ?? '').trim().isNotEmpty) ...[
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFFE6EFFF),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.verified_outlined,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Condition: ${product.condition}',
                                    style: AppThemes.f12w500.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if ((product.sellerType ?? '').trim().isNotEmpty)
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xFFE6F9F0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Seller: ${product.sellerType}',
                                    style: AppThemes.f12w500.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (product.attributesValues != null &&
                        product.attributesValues!.isNotEmpty) ...[
                      _buildAttributes(context, product.attributesValues!),
                      const SizedBox(height: 16),
                    ],
                    if (!hideActions) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CustomIconButtonWhite(
                              text: localizations.chatTitle,
                              onPressed: () async {
                                // Auth guard
                                final authState = context
                                    .read<AuthBloc>()
                                    .state;
                                if (authState is! AuthAuthenticated) {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                  if (result != true || !context.mounted)
                                    return;
                                }

                                final user = await AuthSessionRepository()
                                    .getCachedUser();
                                final currentUserId = user?.id ?? '';
                                if (currentUserId.isEmpty || !context.mounted) {
                                  return;
                                }

                                // Show loading dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                );

                                try {
                                  final conversation =
                                      await const ChatApiService().initiateChat(
                                        product.id,
                                      );

                                  if (!context.mounted) return;
                                  Navigator.pop(
                                    context,
                                  ); // Close loading dialog

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider(
                                        create: (_) =>
                                            ChatBloc(
                                              currentUserId: currentUserId,
                                            )..add(
                                              ChatOpened(
                                                conversation: conversation,
                                              ),
                                            ),
                                        child: ChatScreen(
                                          currentUserId: currentUserId,
                                          userName: 'Seller',
                                          avatarUrl:
                                              product.imageUrl.trim().isNotEmpty
                                              ? product.imageUrl
                                              : 'https://i.pravatar.cc/300?img=12',
                                          listingId: product.id,
                                          listingTitle: product.title,
                                          listingPrice: product.amount,
                                          listingCurrency: product.currency,
                                          listingImageUrl: product.imageUrl,
                                        ),
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  Navigator.pop(
                                    context,
                                  ); // Close loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Could not start chat: $e'),
                                    ),
                                  );
                                }
                              },
                              icon: AppAssets.chatIc,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomIconButtonWhite(
                              text: localizations.whatsappText,
                              onPressed: () async {
                                // Auth guard
                                final authState = context
                                    .read<AuthBloc>()
                                    .state;
                                if (authState is! AuthAuthenticated) {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                  if (result != true || !context.mounted)
                                    return;
                                }

                                final phone = product.sellerPhoneNumber ?? '';
                                if (phone.isNotEmpty) {
                                  final message = Uri.encodeComponent(
                                    'Hi, I\'m interested in "${product.title}"',
                                  );
                                  launchUrl(
                                    Uri.parse(
                                      'https://wa.me/$phone?text=$message',
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              icon: AppAssets.whatsappIc,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomIconButton(
                        text: localizations.callText,
                        onPressed: () async {
                          // Auth guard
                          final authState = context.read<AuthBloc>().state;
                          if (authState is! AuthAuthenticated) {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                            if (result != true || !context.mounted) return;
                          }

                          final phone = product.sellerPhoneNumber ?? '';
                          if (phone.isNotEmpty) {
                            launchUrl(
                              Uri.parse('tel:$phone'),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: AppAssets.callIc,
                      ),
                    ],
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLocationText(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final place = (isArabic
            ? widget.product.placeNameAr
            : widget.product.placeNameEn)
        ?.trim();
    final location = (isArabic
            ? widget.product.locationNameAr
            : widget.product.locationNameEn)
        ?.trim();

    final hasPlace = place != null && place.isNotEmpty;
    final hasLocation = location != null && location.isNotEmpty;
    if (hasPlace && hasLocation) return '$place, $location';
    if (hasPlace) return place;
    if (hasLocation) return location;

    // Backward compatibility fallback for older payloads
    final cityFallback = widget.product.city?.trim() ?? '';
    final placeFallback = widget.product.place?.trim() ?? '';
    if (cityFallback.isEmpty && placeFallback.isEmpty) return '';
    if (cityFallback.isEmpty) return placeFallback;
    if (placeFallback.isEmpty) return cityFallback;
    return '$cityFallback, $placeFallback';
  }

  Widget _buildAttributes(
    BuildContext context,
    Map<String, dynamic> attributes,
  ) {
    final entries = attributes.entries.toList();
    final list = <Widget>[];

    Map<String, dynamic> normalizeEntry(MapEntry<String, dynamic> entry) {
      dynamic rawValue = entry.value;
      String displayTitle = entry.key;
      String displayValue = rawValue.toString();
      String type = 'text';

      if (rawValue is Map) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        displayTitle =
            rawValue[isArabic ? 'label_ar' : 'label_en']?.toString() ??
            entry.key;
        displayValue = rawValue['value']?.toString() ?? '';
        type = rawValue['type']?.toString() ?? 'text';
      }

      return {
        'title': displayTitle,
        'value': displayValue,
        'isLongText': type == 'text' || displayValue.length > 18,
      };
    }

    for (int i = 0; i < entries.length;) {
      final entryNorm = normalizeEntry(entries[i]);
      final isLongText = entryNorm['isLongText'] as bool;

      if (isLongText) {
        list.add(
          Row(
            children: [
              Expanded(
                child: _buildAttributeBox(
                  entryNorm['title'] as String,
                  entryNorm['value'] as String,
                ),
              ),
            ],
          ),
        );
        list.add(const SizedBox(height: 10));
        i++;
      } else {
        if (i + 1 < entries.length) {
          final nextEntryNorm = normalizeEntry(entries[i + 1]);
          final nextIsLongText = nextEntryNorm['isLongText'] as bool;

          if (nextIsLongText) {
            list.add(
              Row(
                children: [
                  Expanded(
                    child: _buildAttributeBox(
                      entryNorm['title'] as String,
                      entryNorm['value'] as String,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: const SizedBox()),
                ],
              ),
            );
            list.add(const SizedBox(height: 10));
            i++;
          } else {
            list.add(
              Row(
                children: [
                  Expanded(
                    child: _buildAttributeBox(
                      entryNorm['title'] as String,
                      entryNorm['value'] as String,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildAttributeBox(
                      nextEntryNorm['title'] as String,
                      nextEntryNorm['value'] as String,
                    ),
                  ),
                ],
              ),
            );
            list.add(const SizedBox(height: 10));
            i += 2;
          }
        } else {
          list.add(
            Row(
              children: [
                Expanded(
                  child: _buildAttributeBox(
                    entryNorm['title'] as String,
                    entryNorm['value'] as String,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: const SizedBox()),
              ],
            ),
          );
          list.add(const SizedBox(height: 10));
          i++;
        }
      }
    }

    return Column(children: list);
  }

  Widget _buildAttributeBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppThemes.f12w500.copyWith(
              color: const Color(0xFF8F9BB3),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppThemes.f14w600.copyWith(
              color: AppColors.brandBlack,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final ProductModel product;
  const _ImageCarousel({required this.product});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  List<Widget> _buildImageWidgets() {
    final List<Widget> widgets = [];
    final localPaths = widget.product.localImagePaths ?? <String>[];

    if (localPaths.isNotEmpty) {
      for (int i = 0; i < localPaths.length; i++) {
        final p = localPaths[i];
        widgets.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageCarousel(
                    imageUrls: const [],
                    localImagePaths: localPaths,
                    initialIndex: i,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(46),
              child: Image.file(
                File(p),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => _imageFallback(),
              ),
            ),
          ),
        );
      }
    } else if (widget.product.images.isNotEmpty) {
      for (int i = 0; i < widget.product.images.length; i++) {
        final url = widget.product.images[i];
        widgets.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImageCarousel(
                    imageUrls: widget.product.images,
                    localImagePaths: const [],
                    initialIndex: i,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
            child: AppNetworkImage(
              imageUrl: url,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(46),
            ),
          ),
        );
      }
    } else if ((widget.product.localImagePath ?? '').trim().isNotEmpty) {
      widgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageCarousel(
                  imageUrls: const [],
                  localImagePaths: [widget.product.localImagePath!],
                  initialIndex: 0,
                ),
                fullscreenDialog: true,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(46),
            child: Image.file(
              File(widget.product.localImagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, __, ___) => _imageFallback(),
            ),
          ),
        ),
      );
    } else if (widget.product.imageUrl.trim().isNotEmpty) {
      widgets.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImageCarousel(
                  imageUrls: [widget.product.imageUrl],
                  localImagePaths: const [],
                  initialIndex: 0,
                ),
                fullscreenDialog: true,
              ),
            );
          },
          child: AppNetworkImage(
            imageUrl: widget.product.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(46),
          ),
        ),
      );
    }

    if (widgets.isEmpty) {
      widgets.add(_imageFallback());
    }
    return widgets;
  }

  Widget _imageFallback() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(46),
        color: const Color(0xFFE6E9EF),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF8A93A3),
          size: 44,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidgets = _buildImageWidgets();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              height: 384,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
              ),
              child: imageWidgets.length == 1
                  ? imageWidgets.first
                  : CarouselSlider(
                      carouselController: _controller,
                      items: imageWidgets,
                      options: CarouselOptions(
                        height: 384,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                    ),
            ),
            // if (imageWidgets.length > 1)
            //   Positioned(
            //     bottom: 12,
            //     left: 0,
            //     right: 0,
            //     child: Center(
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 10,
            //           vertical: 6,
            //         ),
            //         decoration: BoxDecoration(
            //           color: AppColors.white,
            //           borderRadius: BorderRadius.circular(16),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withValues(alpha: 0.1),
            //               blurRadius: 4,
            //               offset: const Offset(0, 2),
            //             ),
            //           ],
            //         ),
            //         child: Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             GestureDetector(
            //               onTap: () => _controller.previousPage(),
            //               child: const Icon(
            //                 Icons.arrow_back_ios_new_rounded,
            //                 size: 14,
            //                 color: AppColors.brandBlack,
            //               ),
            //             ),
            //             const SizedBox(width: 12),
            //             GestureDetector(
            //               onTap: () => _controller.nextPage(),
            //               child: const Icon(
            //                 Icons.arrow_forward_ios_rounded,
            //                 size: 14,
            //                 color: AppColors.brandBlack,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
        if (imageWidgets.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imageWidgets.asMap().entries.map((entry) {
              return Container(
                width: _currentIndex == entry.key ? 24.0 : 6.0,
                height: 6.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: _currentIndex == entry.key
                      ? AppColors.brandBlack
                      : const Color(0xFFD9D9D9),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class FullScreenImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> localImagePaths;
  final int initialIndex;

  const FullScreenImageCarousel({
    super.key,
    required this.imageUrls,
    required this.localImagePaths,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageCarousel> createState() =>
      _FullScreenImageCarouselState();
}

class _FullScreenImageCarouselState extends State<FullScreenImageCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(int index) {
    if (widget.localImagePaths.isNotEmpty) {
      if (index < widget.localImagePaths.length) {
        return InteractiveViewer(
          child: Image.file(
            File(widget.localImagePaths[index]),
            fit: BoxFit.contain,
          ),
        );
      }
    } else if (widget.imageUrls.isNotEmpty) {
      if (index < widget.imageUrls.length) {
        return InteractiveViewer(
          child: AppNetworkImage(
            imageUrl: widget.imageUrls[index],
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      }
    }
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white54,
        size: 44,
      ),
    );
  }

  int get _itemCount {
    if (widget.localImagePaths.isNotEmpty) return widget.localImagePaths.length;
    if (widget.imageUrls.isNotEmpty) return widget.imageUrls.length;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _itemCount,
            itemBuilder: (context, index) {
              return _buildImage(index);
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
