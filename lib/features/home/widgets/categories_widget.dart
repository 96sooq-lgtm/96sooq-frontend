import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';

class CategoriesWidget extends StatelessWidget {
  final List<String> categoryNames;
  final List<String> categoryImages;
  final ValueChanged<int>? onCategoryTap;

  const CategoriesWidget({
    super.key,
    required this.categoryNames,
    required this.categoryImages,
    this.onCategoryTap,
  });

  String _splitAtFirstSpace(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return normalized;

    final firstWhitespace = RegExp(r'\s+').firstMatch(normalized);
    if (firstWhitespace == null) return normalized;

    final splitIndex = firstWhitespace.start;
    final firstPart = normalized.substring(0, splitIndex).trimRight();
    final secondPart = normalized.substring(splitIndex).trimLeft();

    if (firstPart.isEmpty || secondPart.isEmpty) {
      return normalized;
    }

    return '$firstPart\n$secondPart';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    return SizedBox(
      height: 100,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: onCategoryTap == null ? null : () => onCategoryTap!(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: .center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.subTextColor,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        (index < categoryImages.length &&
                            categoryImages[index].trim().isNotEmpty)
                        ? AppNetworkImage(
                            imageUrl: categoryImages[index],
                            width: 60,
                            height: 60,
                            shape: BoxShape.circle,
                          )
                        : Image.asset(
                            AppAssets.logo,
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                          ),
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: 72,
                  child: Text(
                    _splitAtFirstSpace(categoryNames[index]),
                    maxLines: 2,
                    textAlign: .center,
                    overflow: TextOverflow.ellipsis,
                    style: isArabic
                        ? AppThemes.f12w400.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )
                        : AppThemes.f12w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
