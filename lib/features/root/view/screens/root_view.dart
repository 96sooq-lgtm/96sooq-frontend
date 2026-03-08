import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/view/screens/addlist_screen.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/categories/view/screens/category_screen.dart';
import 'package:_96_sooq/features/deals/view/screens/deals_screen.dart';
import 'package:_96_sooq/features/home/view/screens/home_screen.dart';
import 'package:_96_sooq/features/notifications/data/notification_registration_service.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/view/screens/profile_screen.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:_96_sooq/features/root/bloc/root_state.dart';
import 'package:_96_sooq/features/root/model/bottom_nav_item_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with WidgetsBindingObserver {
  final AuthSessionRepository _authSessionRepository = AuthSessionRepository();
  final NotificationRegistrationService _notificationRegistrationService =
      NotificationRegistrationService();

  final List<BottomNavItem> _bottomNavItems = <BottomNavItem>[
    BottomNavItem(
      activeIcon: AppAssets.homeSelectedIc,
      inactiveIcon: AppAssets.homeUnselectedIc,
      title: (l10n) => l10n.homeTitle,
    ),
    BottomNavItem(
      activeIcon: AppAssets.categoriesSelectedIc,
      inactiveIcon: AppAssets.categoriesUnselectedIc,
      title: (l10n) => l10n.categoriesTitle,
    ),
    BottomNavItem(
      activeIcon: AppAssets.dealsSelectedIc,
      inactiveIcon: AppAssets.dealsUnselectedIc,
      title: (l10n) => l10n.dealsTitle,
    ),
    BottomNavItem(
      activeIcon: AppAssets.accountSelectedIc,
      inactiveIcon: AppAssets.accountUnselectedIc,
      title: (l10n) => l10n.accountTitle,
    ),
  ];

  final List<Widget> _pages = const <Widget>[
    HomeScreen(),
    CategoryScreen(),
    DealsScreen(),
    ProfileScreen(),
  ];

  bool _isLoggedInCached = false;
  bool _isCheckingAuth = false;
  bool _isLoginRouteOpen = false;
  bool _isRegisteringFcmToken = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshLoginStatus();
    _registerFcmTokenIfAllowed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLoginStatus();
    }
  }

  bool _isProtectedTab(int index) => index == 2;

  Future<void> _refreshLoginStatus() async {
    if (_isCheckingAuth) return;
    _isCheckingAuth = true;
    final loggedIn = await _authSessionRepository.isLoggedIn();
    _isCheckingAuth = false;

    if (!mounted) return;
    setState(() {
      _isLoggedInCached = loggedIn;
    });
  }

  Future<bool> _requireLogin(BuildContext context) async {
    final latestLoggedIn = await _authSessionRepository.isLoggedIn();
    if (!context.mounted) return false;

    if (mounted && latestLoggedIn != _isLoggedInCached) {
      setState(() {
        _isLoggedInCached = latestLoggedIn;
      });
    }

    if (latestLoggedIn) {
      return true;
    }

    if (_isLoginRouteOpen) {
      return false;
    }

    _isLoginRouteOpen = true;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    _isLoginRouteOpen = false;

    final refreshedLoggedIn = await _authSessionRepository.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedInCached = refreshedLoggedIn;
      });
    }

    return (result ?? false) && refreshedLoggedIn;
  }

  Future<void> _handleAuthStateChange(
    BuildContext context,
    AuthState authState,
  ) async {
    if (authState is AuthUnauthenticated) {
      await _refreshLoginStatus();
      if (!context.mounted) return;

      // Clear store profile when user logs out
      context.read<StoreProfileBloc>().add(const StoreProfileCleared());

      final currentIndex = context.read<RootBloc>().state.currentIndex;
      if (_isProtectedTab(currentIndex)) {
        context.read<RootBloc>().add(ChangeTabEvent(0));
      }
      return;
    }

    if (authState is AuthAuthenticated) {
      await _refreshLoginStatus();
      if (!context.mounted) return;
      // Re-check store every time the user's auth token becomes valid
      // (covers fresh login, token refresh, and app re-launch with saved token)
      context.read<StoreProfileBloc>().add(const StoreProfileCheckRequested());
      _registerFcmTokenIfAllowed();
    }
  }

  Future<void> _registerFcmTokenIfAllowed() async {
    if (_isRegisteringFcmToken) return;
    _isRegisteringFcmToken = true;
    try {
      await _notificationRegistrationService.registerTokenIfAllowedAtStartup();
    } finally {
      _isRegisteringFcmToken = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => RootBloc())],
      child: BlocBuilder<RootBloc, RootState>(
        builder: (context, state) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              _handleAuthStateChange(context, authState);
            },
            child: SafeArea(
              top: false,
              child: Scaffold(
                backgroundColor: AppColors.primaryColor,
                body: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).padding.top,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: state.currentIndex,
                        children: _pages,
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  elevation: 6,
                  onPressed: () async {
                    final canNavigate = await _requireLogin(context);
                    if (!canNavigate) return;

                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(
                          name: AddlistScreen.routeName,
                        ),
                        builder: (_) => const AddlistScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      AppAssets.logo,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                bottomNavigationBar: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedBottomNavigationBar.builder(
                      itemCount: _bottomNavItems.length,
                      height: 50,
                      backgroundColor: AppColors.primaryColor,
                      activeIndex: state.currentIndex,
                      gapLocation: GapLocation.center,
                      notchSmoothness: NotchSmoothness.defaultEdge,
                      splashColor: Colors.transparent,
                      splashSpeedInMilliseconds: 0,
                      splashRadius: 0,
                      scaleFactor: 0,
                      onTap: (index) async {
                        if (_isProtectedTab(index)) {
                          final isLoggedIn = await _requireLogin(context);

                          if (!isLoggedIn) {
                            if (context.mounted) {
                              context.read<RootBloc>().add(ChangeTabEvent(0));
                            }
                            return;
                          }
                        }

                        if (!context.mounted) return;
                        context.read<RootBloc>().add(ChangeTabEvent(index));
                      },
                      tabBuilder: (int index, bool isActive) {
                        final item = _bottomNavItems[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: SvgPicture.asset(
                                isActive ? item.activeIcon : item.inactiveIcon,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title(l10n),
                              style: isActive
                                  ? AppThemes.f12w600.copyWith(
                                      color: Colors.white,
                                    )
                                  : AppThemes.f12w400.copyWith(
                                      color: const Color(0xFF8F9BAD),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                    Positioned(
                      bottom: 2,
                      child: Text(
                        l10n.addListText,
                        textAlign: TextAlign.center,
                        style: AppThemes.f10w400.copyWith(
                          color: const Color(0xFF8F9BAD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
