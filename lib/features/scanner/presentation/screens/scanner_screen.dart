import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/journal/presentation/widgets/quick_log_sheet.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/product.dart';

/// Redesigned 2026 Scan modal.
///
/// Full-bleed black canvas with gold corner brackets framing a 9:14
/// finder. The bottom sheet "magnetises" upward as detection progresses:
///   collapsed   "Tap finder to scan a label"
///   scanning    Indeterminate sweep + "Looking…"
///   matched     Bottle name + match% + actions (sheet at 60% height)
///
/// Top bar has only an X close + a flashlight placeholder. No tabs,
/// no bottom nav (it's a push route above the shell).
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

enum _ScanPhase { idle, scanning, matched, noMatch, error }

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final _imagePicker = ImagePicker();
  final _textRecognizer = TextRecognizer();
  late final AnimationController _sweepController;

  _ScanPhase _phase = _ScanPhase.idle;
  Product? _matched;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _scan() async {
    HapticFeedback.lightImpact();
    setState(() {
      _phase = _ScanPhase.scanning;
      _errorMessage = null;
      _matched = null;
    });
    _sweepController.repeat();

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image == null) {
        _sweepController.stop();
        setState(() => _phase = _ScanPhase.idle);
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final recognized = await _textRecognizer.processImage(inputImage);
      try {
        await File(image.path).delete();
      } on FileSystemException {
        // ignore
      }

      _sweepController.stop();

      if (recognized.text.isEmpty) {
        setState(() {
          _phase = _ScanPhase.noMatch;
          _errorMessage = context.l10n.scanNoText;
        });
        return;
      }

      final allText = recognized.blocks.map((b) => b.text).join(' ');
      final match = _matchProduct(allText);

      if (match != null) {
        HapticFeedback.heavyImpact();
        setState(() {
          _phase = _ScanPhase.matched;
          _matched = match;
        });
      } else {
        setState(() {
          _phase = _ScanPhase.noMatch;
          _errorMessage = context.l10n.scanNoMatch;
        });
      }
    } on Exception catch (e) {
      _sweepController.stop();
      setState(() {
        _phase = _ScanPhase.error;
        _errorMessage = e.toString();
      });
    }
  }

  Product? _matchProduct(String ocrText) {
    final normalized = ocrText.toLowerCase();
    Product? best;
    var bestScore = 0.0;

    for (final p in kSeedProducts) {
      final nameScore =
          StringSimilarity.compareTwoStrings(p.name.toLowerCase(), normalized);
      final containsName =
          normalized.contains(p.name.toLowerCase()) ? 0.8 : 0.0;
      final score = nameScore > containsName ? nameScore : containsName;
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    return bestScore >= 0.25 ? best : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          // ====== Camera canvas ======
          Positioned.fill(
            child: GestureDetector(
              onTap: _phase == _ScanPhase.scanning ? null : _scan,
              child: const _CameraCanvas(),
            ),
          ),

          // ====== Gold finder brackets ======
          const Positioned.fill(child: _GoldFinder()),

          // ====== Animated sweep ======
          if (_phase == _ScanPhase.scanning)
            Positioned.fill(child: _SweepLine(controller: _sweepController)),

          // ====== Top bar ======
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.flash_off, color: Colors.white70, size: 24),
                      tooltip: 'Flashlight',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(context.l10n.flashlightComingSoon)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ====== Magnetic bottom sheet ======
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: AnimatedSwitcher(
              duration: AppMotion.gentle,
              switchInCurve: AppMotion.spring,
              switchOutCurve: AppMotion.exit,
              child: _MagneticSheet(
                key: ValueKey(_phase),
                phase: _phase,
                matched: _matched,
                errorMessage: _errorMessage,
                onScan: _scan,
                onRetry: _scan,
                colors: colors,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Visual primitives
// ============================================================

class _CameraCanvas extends StatelessWidget {
  const _CameraCanvas();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.4,
          colors: [Color(0xFF1A0408), Color(0xFF050505)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.center_focus_weak,
          color: Color(0xFF1F1A1B),
          size: 220,
        ),
      ),
    );
  }
}

class _GoldFinder extends StatelessWidget {
  const _GoldFinder();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SizedBox(
        width: 280,
        height: 380,
        child: CustomPaint(
          painter: _CornerBracketPainter(color: colors.goldWarm),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  _CornerBracketPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 36.0;

    // Top-left
    canvas.drawLine(const Offset(0, 0), const Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - len), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - len),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - len, size.height),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SweepLine extends StatelessWidget {
  const _SweepLine({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SizedBox(
        width: 280,
        height: 380,
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = controller.value;
            return CustomPaint(
              painter: _SweepPainter(progress: t, color: colors.goldWarm),
            );
          },
        ),
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  _SweepPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.transparent, color, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, y - 10, size.width, 20))
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_SweepPainter old) => old.progress != progress;
}

// ============================================================
// Magnetic bottom sheet (changes by phase)
// ============================================================

class _MagneticSheet extends StatelessWidget {
  const _MagneticSheet({
    super.key,
    required this.phase,
    required this.matched,
    required this.errorMessage,
    required this.onScan,
    required this.onRetry,
    required this.colors,
  });

  final _ScanPhase phase;
  final Product? matched;
  final String? errorMessage;
  final VoidCallback onScan;
  final VoidCallback onRetry;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.vertical(top: Radius.circular(28));

    Widget child;
    switch (phase) {
      case _ScanPhase.idle:
      case _ScanPhase.error:
      case _ScanPhase.noMatch:
        child = _IdleOrErrorSheet(
          phase: phase,
          message: errorMessage,
          onScan: onScan,
          colors: colors,
        );
      case _ScanPhase.scanning:
        child = _ScanningSheet(colors: colors);
      case _ScanPhase.matched:
        child = _MatchedSheet(product: matched!, colors: colors);
    }

    return ClipRRect(
      borderRadius: shape,
      child: BackdropContainer(child: child),
    );
  }
}

class BackdropContainer extends StatelessWidget {
  const BackdropContainer({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.charcoal,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: child,
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colors.borderStrong,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _IdleOrErrorSheet extends StatelessWidget {
  const _IdleOrErrorSheet({
    required this.phase,
    required this.message,
    required this.onScan,
    required this.colors,
  });

  final _ScanPhase phase;
  final String? message;
  final VoidCallback onScan;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isError = phase == _ScanPhase.error || phase == _ScanPhase.noMatch;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DragHandle(colors: colors),
        if (isError && message != null) ...[
          Row(
            children: [
              Icon(Icons.info_outline, color: colors.warning, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message!,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    color: colors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ] else ...[
          Text(
            context.l10n.scanIdleHeadline,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.scanIdleSubtitle,
            style: context.serifQuote.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 18),
        ],
        ElevatedButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.camera_alt, size: 20),
          label: Text(isError ? context.l10n.scanTryAgain : context.l10n.scanOpenCamera),
        ),
      ],
    );
  }
}

class _ScanningSheet extends StatelessWidget {
  const _ScanningSheet({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DragHandle(colors: colors),
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.goldWarm,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.scanLooking,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.scanLookingSubtitle,
          style: context.serifQuote.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _MatchedSheet extends StatelessWidget {
  const _MatchedSheet({required this.product, required this.colors});
  final Product product;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(colors: colors),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.salem.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 14, color: context.salemOnSurface),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.scanMatched,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: context.salemOnSurface,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          product.name,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: colors.textPrimary,
            letterSpacing: -0.5,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${product.subcategory} · ${product.region}',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          product.tastingNotes,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: context.serifQuote.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  QuickLogSheet.show(
                    context,
                    prefillName: product.name,
                    prefillCategory: product.category.group,
                    prefillRegion: product.region,
                    prefillProductId: product.id,
                  );
                },
                icon: const Icon(Icons.book_outlined, size: 18),
                label: Text(context.l10n.actionAddToJournal),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/pair');
                },
                icon: const Icon(Icons.restaurant_menu_outlined, size: 18),
                label: Text(context.l10n.actionPair),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
