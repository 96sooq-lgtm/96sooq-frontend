import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/categories/view/screens/product_listing_screen.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  final _recentSearches = [
    'Mobile Phones',
    'pet',
    'Cars',
    'Smart Watches',
    'Commercial Spaces',
  ];

  final _popularSearches = [
    'Mobile Phones',
    'Home Appliances',
    "Men's Clothing",
    'Footwear',
    'Furniture',
    'Stationerys',
  ];

  @override
  void initState() {
    super.initState();
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

  void _performSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductListingScreen(categoryId: '', searchQuery: trimmed),
      ),
    );
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
                  const Expanded(
                    child: Center(
                      child: Text('Search', style: AppThemes.f18w600),
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
                  hintText: 'Search electronics',
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
                      // ── Recent Searches ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Searches',
                            style: AppThemes.f16w600,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _recentSearches.clear());
                            },
                            child: Text(
                              'Clear All',
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

                      // ── Popular Searches ──
                      const Text('Popular Searches', style: AppThemes.f16w600),
                      const SizedBox(height: 14),
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
