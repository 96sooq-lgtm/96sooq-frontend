import 'package:_96_sooq/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';

class AccountTypeCard extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String title;
  final List<String> advantages;
  final bool isSelected;
  final VoidCallback onTap;

  const AccountTypeCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.advantages,
    required this.isSelected,
    required this.onTap,
  });

  TextStyle _withArabicHeavierWeight(BuildContext context, TextStyle style) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (!isArabic) return style;
    final currentWeight = style.fontWeight?.value ?? FontWeight.w400.value;
    final bumpedWeight = (currentWeight + 100).clamp(100, 900);
    final matchedWeight = FontWeight.values.firstWhere(
      (weight) => weight.value == bumpedWeight,
      orElse: () => FontWeight.w900,
    );
    return style.copyWith(fontWeight: matchedWeight);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8F9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFF101010) : const Color(0xFFDCE0E5),
            width: isSelected ? 2 : 1.25,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: iconBg,
                  child: SvgPicture.asset(icon),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: _withArabicHeavierWeight(context, AppThemes.f12w600),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFBFC4CC)
                          : const Color(0xFFCAD2DC),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 14),
            Text(
              localizations.advantagesTitle,
              style: _withArabicHeavierWeight(context, AppThemes.f12w600),
            ),
            const SizedBox(height: 12),

            ...advantages.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(AppAssets.checkIc),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        text,
                        style: _withArabicHeavierWeight(
                          context,
                          AppThemes.f12w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
