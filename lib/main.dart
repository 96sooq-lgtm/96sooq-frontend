import 'dart:io';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_event.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_state.dart';
import 'package:_96_sooq/core/bloc/location/bloc/location_bloc.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/auth/screens/language_selection_screen.dart';
import 'package:_96_sooq/features/categories/bloc/categories_bloc.dart';
import 'package:_96_sooq/features/categories/bloc/store_bloc/store_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/features/notifications/data/local_notification_service.dart';
import 'package:_96_sooq/features/notifications/bloc/notifications_bloc.dart';
import 'package:_96_sooq/features/notifications/data/notification_api_service.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/root/view/screens/root_view.dart';
import 'package:_96_sooq/features/offers/bloc/offers_bloc.dart';
import 'package:_96_sooq/features/offers/bloc/offers_event.dart';
import 'package:_96_sooq/features/offers/data/offers_api_service.dart';
import 'package:_96_sooq/features/deals/viewmodel/bloc/favorites_list_bloc/favorites_list_bloc.dart';
import 'package:_96_sooq/features/home/viewmodel/bloc/favorite_bloc/bloc/favorite_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/notifications/data/notification_deeplink_handler.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/app_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Keep background handler registered for FCM; background system notifications
  // should be handled by Firebase/OS tap flow.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pktrfsdsowpcxbiylrdj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBrdHJmc2Rzb3dwY3hiaXlscmRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0NzI3NTgsImV4cCI6MjA4MjA0ODc1OH0.bFUywICsEYswzj6V_GEVkGDGCm4AmpfMG01hskaV0zY',
  );
  await Firebase.initializeApp();
  await LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    // iOS foreground banners are handled via setForegroundNotificationPresentationOptions.
    // Android needs an explicit local notification to display while app is in foreground.
    if (!kIsWeb && Platform.isAndroid) {
      await LocalNotificationService.showFromRemoteMessage(message);
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (kDebugMode) {
      debugPrint(
        '[Notifications] Opened from background tap. data=${message.data}',
      );
    }
    NotificationDeepLinkHandler.handle(message.data);
  });

  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (kDebugMode && initialMessage != null) {
    debugPrint(
      '[Notifications] Opened from terminated tap. data=${initialMessage.data}',
    );
  }
  final pendingNotificationData = initialMessage?.data;

  runApp(
    // DevicePreview(
    //   enabled: kDebugMode,
    //   builder: (context) {
    //     return
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageBloc()..add(LoadSavedLanguage())),
        BlocProvider(create: (_) => FavoritesListBloc()),
        BlocProvider(
          create: (context) => FavoriteBloc(
            favoritesListBloc: context.read<FavoritesListBloc>(),
          ),
        ),
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProfileBloc()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => StoreProfileBloc()),
        BlocProvider(
          create: (_) => CategoriesBloc()..add(CategoriesRequested()),
        ),
        BlocProvider(create: (_) => StoreBloc()),
        BlocProvider(create: (_) => LocationBloc()),
        BlocProvider(
          create: (_) =>
              OffersBloc(apiService: const OffersApiService())
                ..add(const FetchOffers()),
        ),
        BlocProvider(create: (_) => RootBloc()),
        BlocProvider(
          create: (_) => NotificationsBloc(
            apiService: const NotificationApiService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
    //   },
    // ),
  );

  if (pendingNotificationData != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationDeepLinkHandler.handle(pendingNotificationData);
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          scaffoldMessengerKey: appScaffoldMessengerKey,
          locale: state.locale,
          debugShowCheckedModeBanner: false,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Colors.black,
              contentTextStyle: TextStyle(color: Colors.white),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),

          builder: (context, child) {
            final isArabic = Directionality.of(context) == TextDirection.rtl;
            final baseTheme = Theme.of(context);

            return Theme(
              data: ThemeData(
                colorScheme: baseTheme.colorScheme,
                useMaterial3: baseTheme.useMaterial3,
                snackBarTheme: baseTheme.snackBarTheme,
                fontFamily: isArabic ? 'Amiri' : 'Poppins',
              ),
              child: child!,
            );
          },

          home: const _StartupGate(),
        );
      },
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<bool> _hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_selected_language') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSelectedLanguage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        final hasSelected = snapshot.data ?? false;
        if (hasSelected) {
          return RootScreen();
        }
        return const LanguageSelectionScreen();
      },
    );
  }
}
