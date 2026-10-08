import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/config/config_repository.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/preview/preview_bridge.dart';
import 'package:winebro/core/preview/preview_overrides.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/home/presentation/screens/home_screen.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:winebro/features/pairing/presentation/screens/pair_screen.dart';
import 'package:winebro/shared/widgets/product_detail_sheet.dart';

/// Root of the console's mobile preview (web build, `WB_PREVIEW=true`).
///
/// The console embeds this in an iframe and sends the editor's unsaved
/// draft plus a context with `postMessage`:
///   { type: 'wb-preview', overrides: {products, dishes, config}, context:
///     { screen: 'product'|'dish'|'pair'|'home', id, mode, occasion,
///       archetype, state: 'new'|'returning', theme: 'light'|'dark' } }
/// The real screens render with the draft layered over live data; nothing
/// is written. For pairing contexts the preview replies with the ranking
/// computed by the app's own engine, with live rules and with the draft
/// rules, so the console can show what changes.
class PreviewApp extends ConsumerStatefulWidget {
  const PreviewApp({super.key});

  @override
  ConsumerState<PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends ConsumerState<PreviewApp> {
  late final GoRouter _router;
  ThemeMode _theme = ThemeMode.light;
  Map<String, dynamic> _context = const {};
  StreamSubscription<User?>? _authSub;
  User? _user;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/pair',
          builder: (_, state) => PairScreen(
            initialProductId: state.uri.queryParameters['product'],
            initialDishId: state.uri.queryParameters['dish'],
            initialQuery: state.uri.queryParameters['query'],
            initialMode: state.uri.queryParameters['mode'],
          ),
        ),
        GoRoute(path: '/product/:id', builder: (_, state) => _ProductPage(id: state.pathParameters['id']!)),
        GoRoute(path: '/scan', redirect: (_, __) => '/'),
        GoRoute(path: '/journal', redirect: (_, __) => '/'),
        GoRoute(path: '/profile', redirect: (_, __) => '/'),
        GoRoute(path: '/wishlist', redirect: (_, __) => '/'),
      ],
    );
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() => _user = u);
      if (u != null) postToParent({'type': 'wb-preview-ready', 'email': u.email});
    });
    listenForPreviewMessages(_onMessage);
    final q = initialQuery();
    if (q.isNotEmpty) _apply({'context': q});
    postToParent({'type': 'wb-preview-loaded'});
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  void _onMessage(Map<String, dynamic> m) {
    if (m['type'] == 'wb-preview') _apply(m);
  }

  void _apply(Map<String, dynamic> m) {
    final overrides = m['overrides'] is Map
        ? PreviewOverrides.fromMessage(Map<String, dynamic>.from(m['overrides'] as Map))
        : PreviewOverrides.none;
    ref.read(previewOverridesProvider.notifier).state = overrides;
    final ctx = m['context'] is Map ? Map<String, dynamic>.from(m['context'] as Map) : <String, dynamic>{};
    _context = ctx;
    setState(() => _theme = ctx['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light);
    ref.read(previewUserStateProvider.notifier).state = ctx['state'] == 'new' ? 'new' : 'returning';
    ref.read(previewPalateProvider.notifier).state = _palateFrom(ctx);

    final id = ctx['id'] as String?;
    switch (ctx['screen']) {
      case 'product':
        _router.go(id != null ? '/product/$id' : '/');
      case 'dish':
        _router.go(Uri(path: '/pair', queryParameters: {if (id != null) 'dish': id}).toString());
      case 'pair':
        _router.go(Uri(path: '/pair', queryParameters: {
          if (id != null) 'dish': id,
          if (ctx['mode'] is String) 'mode': ctx['mode'] as String,
        }).toString());
      default:
        _router.go('/');
    }
    if (ctx['screen'] == 'dish' || ctx['screen'] == 'pair') {
      // Give the catalogue streams a moment to deliver, then report rankings.
      Future<void>.delayed(const Duration(milliseconds: 900), () => _reportRanking(overrides, ctx));
    }
  }

  PalateProfile? _palateFrom(Map<String, dynamic> ctx) {
    final code = ctx['archetype'] as String?;
    if (code == null || code.isEmpty) return null;
    double axis(String k, double d) => (ctx[k] is num) ? (ctx[k] as num).toDouble() : d;
    return PalateProfile(
      fruit: axis('fruit', 5),
      acidity: axis('acidity', 5),
      body: axis('body', 5),
      tannin: axis('tannin', 5),
      freshness: axis('freshness', 5),
      complexity: axis('complexity', 5),
      archetype: PalateArchetype(code),
    );
  }

  /// Ranks drinks for the context's dish with the live rules and with the
  /// draft rules, using the app's own PairingEngine, and posts both.
  void _reportRanking(PreviewOverrides overrides, Map<String, dynamic> ctx) {
    final dishId = ctx['id'] as String?;
    if (dishId == null) return;
    final dishes = ref.read(allDishesProvider);
    final products = ref.read(allProductsProvider);
    final dish = dishes.where((d) => d.id == dishId).firstOrNull;
    if (dish == null) return;
    final profile = ref.read(previewPalateProvider) ??
        ref.read(userPalateProvider).valueOrNull ??
        PalateProfile(fruit: 5, acidity: 5, body: 5, tannin: 5, freshness: 5, complexity: 5, archetype: AppConfig.current.archetypes.fallback);
    final occasion = ctx['occasion'] is String && (ctx['occasion'] as String).isNotEmpty ? Occasion(ctx['occasion'] as String) : null;

    List<Map<String, Object?>> rank(PairingRulesConfig? rules) {
      final engine = PairingEngine(rules: rules);
      return [
        for (final r in engine.suggestDrinkForFood(userProfile: profile, dish: dish, products: products, occasion: occasion, topN: 10))
          {
            'id': r.product.id,
            'name': r.product.name,
            'score': r.matchPercent,
            'base': r.baseScore.round(),
            'archetypeBonus': r.archetypeBonus,
            'occasionBonus': r.occasionBonus,
            'feedbackBonus': r.feedbackBonus,
            'foodFit': engine.explainFoodFit(dish, r.product).total.round(),
            'strategy': engine.explainFoodFit(dish, r.product).strategy.name,
            'broTip': r.broTip,
          },
      ];
    }

    final liveRules = ref.read(appConfigProvider).valueOrNull?.pairingRules;
    final draftRulesRaw = overrides.config['pairingRules'];
    final draftRules = draftRulesRaw != null ? PairingRulesConfig.fromMap(draftRulesRaw) : null;
    postToParent({
      'type': 'wb-preview-ranking',
      'dish': dish.id,
      'live': rank(liveRules),
      'draft': rank(draftRules ?? liveRules),
      'rulesChanged': draftRules != null,
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appConfigProvider); // keep config (with overrides) streaming
    final overrides = ref.watch(previewOverridesProvider);
    return MaterialApp.router(
      title: 'WineBro preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _theme,
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        if (_user == null) return _SignInGate(onSignedIn: () => setState(() {}));
        return Column(
          children: [
            _PreviewBanner(label: overrides.label, state: _context['state'] as String?),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({this.label, this.state});
  final String? label;
  final String? state;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF252122),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: Color(0xFFE0668A)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'PREVIEW · ${label ?? 'live data'}${state == 'new' ? ' · new user' : ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInGate extends StatelessWidget {
  const _SignInGate({required this.onSignedIn});
  final VoidCallback onSignedIn;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sign in to load the catalogue for preview.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
                  onSignedIn();
                },
                child: const Text('Sign in with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-page rendering of the drink detail sheet.
class _ProductPage extends ConsumerWidget {
  const _ProductPage({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(allProductsProvider).where((p) => p.id == id).firstOrNull;
    if (product == null) {
      return Scaffold(body: Center(child: Text(context.l10n.catalogLoading)));
    }
    return Scaffold(body: SafeArea(child: ProductDetailSheet(product: product)));
  }
}
