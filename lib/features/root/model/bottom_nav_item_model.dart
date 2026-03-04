import 'package:_96_sooq/l10n/app_localizations.dart';

class BottomNavItem {
  final String activeIcon;
  final String inactiveIcon;
  final String Function(AppLocalizations l10n) title;

  const BottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.title,
  });
}
