import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/categories/view/screens/product_listing_screen.dart';
import 'package:_96_sooq/features/search/data/popular_searches_api_service.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const String _recentSearchKey = 'recent_searches_v1';
  static const int _maxRecentSearches = 10;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  List<String> _recentSearches = [];
  final PopularSearchesApiService _popularSearchesApiService =
      const PopularSearchesApiService();
  List<String> _popularSearches = [];
  bool _isPopularSearchesLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _fetchPopularSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_recentSearchKey) ?? <String>[];
    if (!mounted) return;
    setState(() => _recentSearches = List<String>.from(stored));
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchKey, _recentSearches);
  }

  Future<void> _addRecentSearch(String term) async {
    final normalized = term.trim();
    if (normalized.isEmpty) return;
    _recentSearches.removeWhere(
      (item) => item.toLowerCase() == normalized.toLowerCase(),
    );
    _recentSearches.insert(0, normalized);
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.take(_maxRecentSearches).toList();
    }
    await _saveRecentSearches();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _clearRecentSearches() async {
    _recentSearches = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchKey);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await _addRecentSearch(trimmed);
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductListingScreen(categoryId: '', searchQuery: trimmed),
      ),
    );
  }

  Future<void> _fetchPopularSearches() async {
    if (mounted) {
      setState(() => _isPopularSearchesLoading = true);
    }
    try {
      final items = await _popularSearchesApiService.fetchPopularSearches();
      if (!mounted) return;
      setState(() {
        _popularSearches = items;
        _isPopularSearchesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _popularSearches = [];
        _isPopularSearchesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── Header ──
              Row(
                children: [
                  BackButtonWidget(ontap: () => Navigator.pop(context)),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.search,
                        style: AppThemes.f18w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),

              // ── Search Field ──
              TextField(
                controller: _searchController,
                focusNode: _focusNode,
                style: AppThemes.f14w400,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchPlaceholder,
                  hintStyle: AppThemes.f14w400.copyWith(
                    color: const Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _performSearch,
              ),
              const SizedBox(height: 28),

              // ── Scrollable content ──
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_recentSearches.isNotEmpty) ...[
                        // ── Recent Searches ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.recentSearchesTitle,
                              style: AppThemes.f16w600,
                            ),
                            GestureDetector(
                              onTap: _clearRecentSearches,
                              child: Text(
                                AppLocalizations.of(context)!.clearAllText,
                                style: AppThemes.f14w500.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _recentSearches
                              .map(
                                (term) => _SearchChip(
                                  label: term,
                                  onTap: () => _performSearch(term),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 28),
                      ],

                      if (_isPopularSearchesLoading ||
                          _popularSearches.isNotEmpty) ...[
                        // ── Popular Searches ──
                        Text(
                          AppLocalizations.of(context)!.popularSearchesTitle,
                          style: AppThemes.f16w600,
                        ),
                        const SizedBox(height: 14),
                        if (_isPopularSearchesLoading)
                          _PopularSearchesShimmer()
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _popularSearches
                                .map(
                                  (term) => _SearchChip(
                                    label: term,
                                    showTrendIcon: true,
                                    onTap: () => _performSearch(term),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search Chip ─────────────────────────────────────────────────────────────

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.label,
    this.showTrendIcon = false,
    this.onTap,
  });

  final String label;
  final bool showTrendIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showTrendIcon) ...[
              Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppThemes.f14w500.copyWith(color: const Color(0xFF2A2F3B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularSearchesShimmer extends StatelessWidget {
  _PopularSearchesShimmer();

  final List<double> _chipWidths = const [
    90,
    130,
    110,
    150,
    100,
    140,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _chipWidths
          .map((width) => _ShimmerChip(width: width))
          .toList(),
    );
  }
}

class _ShimmerChip extends StatelessWidget {
  const _ShimmerChip({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
