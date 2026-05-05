import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/notifications/notification_handler.dart';
import 'package:winebro/core/providers/locale_provider.dart';
import 'package:winebro/core/providers/theme_provider.dart';
import 'package:winebro/core/router/app_router.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';

class WineBroApp extends ConsumerWidget {
  const WineBroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);

    // Bind router to the FCM handler so notification taps deep-link
    // correctly. Safe to call on every rebuild — bindRouter is idempotent.
    NotificationHandler.instance.bindRouter(router);

    // FCM permission + topic subscribe + token registration the moment
    // the user signs in. Listen here (single owner) instead of inside
    // the auth provider so the provider stays infrastructure-free.
    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next is Authenticated && prev is! Authenticated) {
        NotificationHandler.instance.registerForUser(next.user.id);
      }
    });

    return MaterialApp.router(
      title: 'WineBro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

