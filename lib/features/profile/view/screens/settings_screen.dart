import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/notifications/data/notification_registration_service.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _isUpdatingPush = false;
  final NotificationRegistrationService _notificationService =
      NotificationRegistrationService();

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    final enabled = await _notificationService.isNotificationsEnabled();
    if (!mounted) return;
    setState(() => _pushNotifications = enabled);
  }

  Future<void> _onPushToggleChanged(bool value) async {
    if (_isUpdatingPush) return;

    setState(() => _isUpdatingPush = true);
    try {
      await _notificationService.setNotificationsEnabled(value);
      if (value) {
        await _notificationService.registerTokenIfAllowedAtStartup();
      } else {
        await _notificationService.unregisterCurrentToken();
      }

      if (!mounted) return;
      setState(() => _pushNotifications = value);
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPush = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
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
                        localizations.settingsTitle,
                        style: AppThemes.f18w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),

              // ── Notifications heading ──
              Text(localizations.notificationTitle, style: AppThemes.f16w600),
              const SizedBox(height: 16),

              // ── Push Notifications toggle ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF2A2F3B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.pushNotifications,
                        style: AppThemes.f14w500.copyWith(
                          color: const Color(0xFF2A2F3B),
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _pushNotifications,
                      activeTrackColor: const Color(0xFF2A2F3B),
                      onChanged: _isUpdatingPush
                          ? null
                          : (value) => _onPushToggleChanged(value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
