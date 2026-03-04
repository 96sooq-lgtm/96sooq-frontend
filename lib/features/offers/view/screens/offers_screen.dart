import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/offers/model/offer_story_item.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({
    super.key,
    required this.offers,
    required this.initialOfferIndex,
  });

  final List<OfferStoryItem> offers;
  final int initialOfferIndex;

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _storyDuration = Duration(seconds: 4);
  static const Duration _offerTransitionDuration = Duration(milliseconds: 280);
  static const double _horizontalSwipeThreshold = 500;
  static const double _verticalDismissThreshold = 650;
  static const double _gestureBottomInset = 92;

  late final AnimationController _progressController;
  late final PageController _pageController;
  late final List<int> _storyIndexByOffer;
  late int _offerIndex;
  bool _isTransitioningOffer = false;

  OfferStoryItem get _currentOffer => widget.offers[_offerIndex];
  int get _currentStoryIndex => _storyIndexByOffer[_offerIndex];

  @override
  void initState() {
    super.initState();
    _offerIndex = widget.initialOfferIndex.clamp(0, widget.offers.length - 1);
    _pageController = PageController(initialPage: _offerIndex);
    _storyIndexByOffer = List<int>.filled(widget.offers.length, 0);
    _progressController =
        AnimationController(vsync: this, duration: _storyDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _goToNext();
            }
          });
    _startCurrentStory();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startCurrentStory() {
    _progressController
      ..stop()
      ..forward(from: 0);
  }

  void _dismissStories() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _animateToOffer(int targetOfferIndex) async {
    if (!mounted) return;
    _isTransitioningOffer = true;
    _progressController.stop();
    await _pageController.animateToPage(
      targetOfferIndex,
      duration: _offerTransitionDuration,
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    _offerIndex = targetOfferIndex;
    _isTransitioningOffer = false;
    _startCurrentStory();
  }

  Future<void> _goToNext() async {
    if (!mounted) return;
    if (_isTransitioningOffer) return;

    final currentStoryIndex = _currentStoryIndex;
    final isLastStory = currentStoryIndex == _currentOffer.stories.length - 1;
    final isLastOffer = _offerIndex == widget.offers.length - 1;

    if (!isLastStory) {
      setState(() => _storyIndexByOffer[_offerIndex] = currentStoryIndex + 1);
      _startCurrentStory();
      return;
    }

    if (!isLastOffer) {
      setState(() {
        _storyIndexByOffer[_offerIndex + 1] = 0;
      });
      await _animateToOffer(_offerIndex + 1);
      return;
    }

    _dismissStories();
  }

  Future<void> _goToPrevious() async {
    if (!mounted) return;
    if (_isTransitioningOffer) return;

    final currentStoryIndex = _currentStoryIndex;
    final isFirstStory = currentStoryIndex == 0;
    final isFirstOffer = _offerIndex == 0;

    if (!isFirstStory) {
      setState(() => _storyIndexByOffer[_offerIndex] = currentStoryIndex - 1);
      _startCurrentStory();
      return;
    }

    if (!isFirstOffer) {
      final previousOfferIndex = _offerIndex - 1;
      setState(() {
        _storyIndexByOffer[previousOfferIndex] =
            widget.offers[previousOfferIndex].stories.length - 1;
      });
      await _animateToOffer(previousOfferIndex);
      return;
    }

    _startCurrentStory();
  }

  Future<void> _handleHorizontalSwipe(DragEndDetails details) async {
    if (!mounted || _isTransitioningOffer) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _horizontalSwipeThreshold) {
      _startCurrentStory();
      return;
    }

    if (velocity < 0) {
      final isLastOffer = _offerIndex == widget.offers.length - 1;
      if (isLastOffer) {
        _startCurrentStory();
        return;
      }
      setState(() {
        _storyIndexByOffer[_offerIndex + 1] = 0;
      });
      await _animateToOffer(_offerIndex + 1);
      return;
    }

    final isFirstOffer = _offerIndex == 0;
    if (isFirstOffer) {
      _startCurrentStory();
      return;
    }
    final previousOfferIndex = _offerIndex - 1;
    setState(() {
      _storyIndexByOffer[previousOfferIndex] =
          widget.offers[previousOfferIndex].stories.length - 1;
    });
    await _animateToOffer(previousOfferIndex);
  }

  void _handleVerticalSwipe(DragEndDetails details) {
    if (!mounted || _isTransitioningOffer) return;

    final velocity = details.primaryVelocity ?? 0;
    if (velocity > _verticalDismissThreshold) {
      _dismissStories();
      return;
    }

    _startCurrentStory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.offers.length,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() {
                _offerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              final storyIndex = _storyIndexByOffer[index];
              return AppNetworkImage(
                imageUrl: offer.stories[storyIndex],
                fit: BoxFit.contain,
              );
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xA0000000),
                  Color(0x00000000),
                  Color(0x88000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: _gestureBottomInset,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _goToPrevious,
                    onHorizontalDragStart: (_) => _progressController.stop(),
                    onHorizontalDragEnd: _handleHorizontalSwipe,
                    onVerticalDragStart: (_) => _progressController.stop(),
                    onVerticalDragEnd: _handleVerticalSwipe,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _goToNext,
                    onHorizontalDragStart: (_) => _progressController.stop(),
                    onHorizontalDragEnd: _handleHorizontalSwipe,
                    onVerticalDragStart: (_) => _progressController.stop(),
                    onVerticalDragEnd: _handleVerticalSwipe,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Column(
                children: [
                  Row(
                    children: List.generate(_currentOffer.stories.length, (i) {
                      final completed = i < _currentStoryIndex;
                      final isCurrent = i == _currentStoryIndex;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: i == _currentOffer.stories.length - 1
                                ? 0
                                : 6,
                          ),
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: isCurrent
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, _) {
                                      return FractionallySizedBox(
                                        widthFactor: _progressController.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : completed
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (_currentOffer.avatarUrl != null &&
                          _currentOffer.avatarUrl!.trim().isNotEmpty)
                        ClipOval(
                          child: AppNetworkImage(
                            imageUrl: _currentOffer.avatarUrl!,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store_mall_directory_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _currentOffer.name,
                          style: AppThemes.f18w600.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (_currentOffer.linkUrl != null &&
                          _currentOffer.linkUrl!.trim().isNotEmpty)
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final uri = Uri.tryParse(_currentOffer.linkUrl!);
                              if (uri != null) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Open Link',
                                    style: AppThemes.f18w400.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SvgPicture.asset(
                                    AppAssets.offerLinkIc,
                                    width: 22,
                                    height: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 10),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppAssets.chatWhiteIc,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
