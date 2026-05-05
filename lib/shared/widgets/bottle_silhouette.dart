import 'package:flutter/material.dart';

/// Bottle silhouettes drawn as paths — one per category. Used as
/// the background shape on [BrandLabelCard]. Hand-authored: stroke
/// scales with [size], no asset dependency.
enum BottleShape {
  wine,
  spirits,
  beer,
  cocktail,
}

class BottleSilhouette extends StatelessWidget {
  const BottleSilhouette({
    required this.shape,
    required this.fill,
    this.size = 140,
    super.key,
  });

  final BottleShape shape;
  final Color fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.6,
      child: CustomPaint(
        painter: _BottlePainter(shape: shape, fill: fill),
      ),
    );
  }
}

class _BottlePainter extends CustomPainter {
  _BottlePainter({required this.shape, required this.fill});

  final BottleShape shape;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    final path = switch (shape) {
      BottleShape.wine => _wineBottle(size),
      BottleShape.spirits => _spiritsBottle(size),
      BottleShape.beer => _beerBottle(size),
      BottleShape.cocktail => _cocktailGlass(size),
    };
    canvas.drawPath(path, paint);
  }

  /// Classic Bordeaux bottle: tall body with sloped shoulder + neck.
  Path _wineBottle(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      // Neck top
      ..moveTo(w * 0.42, 0)
      ..lineTo(w * 0.58, 0)
      // Down the neck
      ..lineTo(w * 0.58, h * 0.28)
      // Shoulder curve
      ..quadraticBezierTo(w * 0.58, h * 0.34, w * 0.72, h * 0.38)
      ..quadraticBezierTo(w * 0.86, h * 0.42, w * 0.86, h * 0.5)
      // Body
      ..lineTo(w * 0.86, h * 0.94)
      // Bottom
      ..quadraticBezierTo(w * 0.86, h, w * 0.78, h)
      ..lineTo(w * 0.22, h)
      ..quadraticBezierTo(w * 0.14, h, w * 0.14, h * 0.94)
      ..lineTo(w * 0.14, h * 0.5)
      // Shoulder back up
      ..quadraticBezierTo(w * 0.14, h * 0.42, w * 0.28, h * 0.38)
      ..quadraticBezierTo(w * 0.42, h * 0.34, w * 0.42, h * 0.28)
      ..close();
  }

  /// Whisky/spirits bottle: square shoulders, wider body.
  Path _spiritsBottle(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.4, 0)
      ..lineTo(w * 0.6, 0)
      ..lineTo(w * 0.6, h * 0.2)
      // Sharp shoulder
      ..lineTo(w * 0.85, h * 0.28)
      ..quadraticBezierTo(w * 0.92, h * 0.32, w * 0.92, h * 0.42)
      ..lineTo(w * 0.92, h * 0.94)
      ..quadraticBezierTo(w * 0.92, h, w * 0.84, h)
      ..lineTo(w * 0.16, h)
      ..quadraticBezierTo(w * 0.08, h, w * 0.08, h * 0.94)
      ..lineTo(w * 0.08, h * 0.42)
      ..quadraticBezierTo(w * 0.08, h * 0.32, w * 0.15, h * 0.28)
      ..lineTo(w * 0.4, h * 0.2)
      ..close();
  }

  /// Beer bottle: shorter neck, classic longneck silhouette.
  Path _beerBottle(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.43, 0)
      ..lineTo(w * 0.57, 0)
      ..lineTo(w * 0.57, h * 0.18)
      ..quadraticBezierTo(w * 0.57, h * 0.28, w * 0.78, h * 0.34)
      ..quadraticBezierTo(w * 0.88, h * 0.36, w * 0.88, h * 0.46)
      ..lineTo(w * 0.88, h * 0.94)
      ..quadraticBezierTo(w * 0.88, h, w * 0.8, h)
      ..lineTo(w * 0.2, h)
      ..quadraticBezierTo(w * 0.12, h, w * 0.12, h * 0.94)
      ..lineTo(w * 0.12, h * 0.46)
      ..quadraticBezierTo(w * 0.12, h * 0.36, w * 0.22, h * 0.34)
      ..quadraticBezierTo(w * 0.43, h * 0.28, w * 0.43, h * 0.18)
      ..close();
  }

  /// Coupe glass — short stem, wide bowl. Used for "Cocktails" category.
  Path _cocktailGlass(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      // Bowl rim
      ..moveTo(w * 0.1, h * 0.18)
      ..lineTo(w * 0.9, h * 0.18)
      // Bowl walls
      ..quadraticBezierTo(w * 0.9, h * 0.42, w * 0.55, h * 0.5)
      // Stem
      ..lineTo(w * 0.55, h * 0.78)
      // Foot
      ..lineTo(w * 0.85, h * 0.94)
      ..quadraticBezierTo(w * 0.85, h, w * 0.78, h)
      ..lineTo(w * 0.22, h)
      ..quadraticBezierTo(w * 0.15, h, w * 0.15, h * 0.94)
      ..lineTo(w * 0.45, h * 0.78)
      ..lineTo(w * 0.45, h * 0.5)
      ..quadraticBezierTo(w * 0.1, h * 0.42, w * 0.1, h * 0.18)
      ..close();
  }

  @override
  bool shouldRepaint(_BottlePainter old) =>
      old.shape != shape || old.fill != fill;
}

/// Maps a product category string to the right [BottleShape].
BottleShape bottleShapeForCategory(String category) {
  switch (category) {
    case 'Spirits':
      return BottleShape.spirits;
    case 'Beer':
      return BottleShape.beer;
    case 'Cocktails':
      return BottleShape.cocktail;
    default:
      return BottleShape.wine;
  }
}
