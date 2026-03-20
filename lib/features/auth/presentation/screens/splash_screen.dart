import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  bool _animationDone = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.03), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _animationDone = true;
        _tryNavigate();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tryNavigate() {
    if (_navigated || !_animationDone || !mounted) return;

    final auth = ref.read(authStateProvider);
    if (auth is AuthLoading) return;

    _navigated = true;
    switch (auth) {
      case Authenticated():
        context.go('/');
      case NeedsOnboarding():
        context.go('/quiz');
      case NeedsProfile():
        context.go('/name');
      case _:
        context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next is! AuthLoading) {
        _tryNavigate();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.charcoal,
              colors.charcoalDeep,
              colors.paprikaDark,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 280,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.textTertiary,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: colors.surface2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.paprika),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

