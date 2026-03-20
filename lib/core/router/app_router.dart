import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/auth/presentation/screens/login_screen.dart';
import 'package:winebro/features/auth/presentation/screens/name_screen.dart';
import 'package:winebro/features/auth/presentation/screens/otp_screen.dart';
import 'package:winebro/features/auth/presentation/screens/splash_screen.dart';
import 'package:winebro/features/aroma_wheel/presentation/screens/aroma_wheel_screen.dart';
import 'package:winebro/features/community/presentation/screens/community_screen.dart';
import 'package:winebro/features/home/presentation/screens/home_screen.dart';
import 'package:winebro/features/journal/presentation/screens/journal_screen.dart';
import 'package:winebro/features/onboarding/presentation/screens/quiz_screen.dart';
import 'package:winebro/features/pairing/presentation/screens/pair_screen.dart';
import 'package:winebro/features/profile/presentation/screens/profile_screen.dart';
import 'package:winebro/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:winebro/shared/widgets/shell_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;

  AuthState get currentState => _ref.read(authStateProvider);
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifierListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.currentState;
      final path = state.uri.path;

      if (path == '/splash') return null;

      return switch (authState) {
        Unauthenticated() =>
          path.startsWith('/login') ? null : '/login',
        OtpSent() =>
          path == '/otp' ? null : '/otp',
        NeedsProfile() =>
          path == '/name' ? null : '/name',
        NeedsOnboarding() =>
          path == '/quiz' ? null : '/quiz',
        AuthLoading() => null,
        AuthError() =>
          path.startsWith('/login') ? null : '/login',
        Authenticated() =>
          path.startsWith('/login') ||
                  path == '/otp' ||
                  path == '/name' ||
                  path == '/quiz' ||
                  path == '/splash'
              ? '/'
              : null,
      };
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, __) => const OtpScreen(),
      ),
      GoRoute(
        path: '/name',
        builder: (_, __) => const NameScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const QuizScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/pair', builder: (_, __) => const PairScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/scan', builder: (_, __) => const ScannerScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/journal', builder: (_, __) => const JournalScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/aroma',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AromaWheelScreen(),
      ),
    ],
  );
});

