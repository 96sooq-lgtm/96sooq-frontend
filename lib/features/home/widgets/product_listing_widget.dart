import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/home/model/product_model.dart';
import 'package:_96_sooq/features/home/widgets/product_card.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class ProductListingWidget extends StatelessWidget {
  final String category;
  final List<ProductModel> products;
  final void Function(ProductModel product) onProductTap;
  final void Function() onSeeAllTap;
  final bool showFavoriteIcon;
  final bool showStatus;

  const ProductListingWidget({
    super.key,
    required this.category,
    required this.products,
    required this.onProductTap,
    required this.onSeeAllTap,
    this.showFavoriteIcon = true,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: .start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              category,
              style: isArabic
                  ? AppThemes.f16w600.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    )
                  : AppThemes.f16w600,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSeeAllTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        localizations.seeAllText,
                        style: isArabic
                            ? AppThemes.f12w500.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.subTextBlue,
                              )
                            : AppThemes.f12w500.copyWith(
                                color: AppColors.subTextBlue,
                              ),
                      ),
                      const Icon(
                        Icons.arrow_right,
                        color: AppColors.subTextBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 245,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];

              return SizedBox(
                width: 173,
                child: ProductCard(
                  product: product,
                  onTapProduct: () => onProductTap(product),
                  showFavoriteIcon: showFavoriteIcon,
                  showStatus: showStatus,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
