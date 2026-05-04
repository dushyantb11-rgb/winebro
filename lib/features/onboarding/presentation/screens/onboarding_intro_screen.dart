import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/theme/app_theme.dart';

/// First-launch cinematic intro. Three swipeable cards that sell the
/// promise before the user spends time on the palate quiz.
///
/// Each card is a full-bleed paprika gradient with brand-true imagery
/// (icon-only fallback until photography pipeline lands), Playfair
/// hero copy, and a serif-italic byline.
///
/// Final CTA "Begin the quiz" pushes /quiz. "Skip" available top-right.
class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(
      eyebrow: 'PALATE QUIZ',
      headline: 'Find your\ntaste DNA',
      byline:
          'Six axes of flavour learn whether you lean sweet or dry, fruity or smoky, light or full-bodied.',
      icon: Icons.fingerprint,
    ),
    _Slide(
      eyebrow: 'LABEL SCANNER',
      headline: 'Scan any\nbottle',
      byline:
          'Point your camera at a label. WineBro reads, identifies, and suggests what to eat with it.',
      icon: Icons.qr_code_scanner,
    ),
    _Slide(
      eyebrow: 'BROCARD JOURNAL',
      headline: 'Every sip,\nremembered',
      byline:
          'A beautiful tasting card for every bottle. Watch your palate evolve over time.',
      icon: Icons.book_outlined,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_index < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.gentle,
        curve: AppMotion.standard,
      );
    } else {
      context.go('/quiz');
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    context.go('/quiz');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) =>
                _SlideView(slide: _slides[i], colors: colors),
          ),

          // Skip
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: TextButton(
                onPressed: _skip,
                style: TextButton.styleFrom(
                  foregroundColor: colors.inkOnHero.withValues(alpha: 0.7),
                ),
                child: const Text('Skip'),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: AppMotion.fast,
                          width: active ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active
                                ? colors.goldWarm
                                : colors.inkOnHero.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.goldWarm,
                          foregroundColor: colors.thunder,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          isLast ? 'Begin the quiz' : 'Next',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.eyebrow,
    required this.headline,
    required this.byline,
    required this.icon,
  });

  final String eyebrow;
  final String headline;
  final String byline;
  final IconData icon;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.colors});
  final _Slide slide;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.thunder,
            colors.paprikaDeep,
            colors.paprika,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Decorative oversized icon
          Positioned(
            top: -40,
            right: -60,
            child: Icon(
              slide.icon,
              size: 320,
              color: colors.inkOnHero.withValues(alpha: 0.06),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 80, 28, 180),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.goldWarm.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.goldWarm.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(slide.icon, color: colors.goldWarm, size: 40),
                ),
                const SizedBox(height: 32),
                Text(
                  slide.eyebrow,
                  style: context.eyebrow.copyWith(color: colors.goldWarm),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.headline,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    color: colors.inkOnHero,
                    height: 1,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slide.byline,
                  style: context.serifQuote.copyWith(
                    color: colors.inkOnHero.withValues(alpha: 0.85),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
