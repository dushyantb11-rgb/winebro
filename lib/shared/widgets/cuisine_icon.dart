import 'package:flutter/material.dart';

/// Hand-authored cuisine icons — drawn as custom paths, no asset
/// dependency. Replaces the `Icons.outdoor_grill` / `Icons.celebration`
/// generic-Material set with India-specific shapes.
enum Cuisine {
  northIndian,
  southIndian,
  coastal,
  tandoori,
  street,
  dessert,
}

class CuisineIcon extends StatelessWidget {
  const CuisineIcon({
    required this.cuisine,
    required this.color,
    this.size = 28,
    super.key,
  });

  final Cuisine cuisine;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CuisinePainter(cuisine, color)),
    );
  }
}

class _CuisinePainter extends CustomPainter {
  _CuisinePainter(this.cuisine, this.color);

  final Cuisine cuisine;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    switch (cuisine) {
      case Cuisine.northIndian:
        // Curry handi: round-bottomed pot with steam ribbons.
        final pot = Path()
          ..moveTo(w * 0.18, h * 0.55)
          ..quadraticBezierTo(w * 0.18, h * 0.92, w * 0.5, h * 0.92)
          ..quadraticBezierTo(w * 0.82, h * 0.92, w * 0.82, h * 0.55)
          ..lineTo(w * 0.82, h * 0.5)
          ..lineTo(w * 0.18, h * 0.5)
          ..close();
        canvas.drawPath(pot, fill);
        // Lid handle
        canvas.drawLine(
          Offset(w * 0.4, h * 0.46),
          Offset(w * 0.6, h * 0.46),
          stroke,
        );
        // Steam wiggles
        for (var i = 0; i < 3; i++) {
          final x = w * (0.32 + i * 0.18);
          final p = Path()
            ..moveTo(x, h * 0.36)
            ..quadraticBezierTo(x - w * 0.04, h * 0.28, x, h * 0.2)
            ..quadraticBezierTo(x + w * 0.04, h * 0.12, x, h * 0.04);
          canvas.drawPath(p, stroke);
        }
        break;

      case Cuisine.southIndian:
        // Folded dosa on a thali rim.
        final thali = Path()
          ..addOval(Rect.fromLTWH(
            w * 0.08, h * 0.6, w * 0.84, h * 0.3,
          ));
        canvas.drawPath(thali, stroke);
        // Dosa fold (cone shape)
        final dosa = Path()
          ..moveTo(w * 0.2, h * 0.7)
          ..lineTo(w * 0.5, h * 0.18)
          ..lineTo(w * 0.8, h * 0.7)
          ..close();
        canvas.drawPath(dosa, fill);
        break;

      case Cuisine.coastal:
        // Fish silhouette.
        final fish = Path()
          ..moveTo(w * 0.18, h * 0.5)
          ..quadraticBezierTo(w * 0.4, h * 0.18, w * 0.7, h * 0.32)
          ..quadraticBezierTo(w * 0.86, h * 0.4, w * 0.92, h * 0.5)
          ..quadraticBezierTo(w * 0.86, h * 0.6, w * 0.7, h * 0.68)
          ..quadraticBezierTo(w * 0.4, h * 0.82, w * 0.18, h * 0.5)
          ..close();
        canvas.drawPath(fish, fill);
        // Tail
        final tail = Path()
          ..moveTo(w * 0.18, h * 0.5)
          ..lineTo(w * 0.04, h * 0.32)
          ..lineTo(w * 0.04, h * 0.68)
          ..close();
        canvas.drawPath(tail, fill);
        // Eye
        canvas.drawCircle(
          Offset(w * 0.78, h * 0.45),
          w * 0.03,
          Paint()..color = const Color(0xFF000000).withValues(alpha: 0.0),
        );
        break;

      case Cuisine.tandoori:
        // Skewer with 3 pieces of meat.
        canvas.drawLine(
          Offset(w * 0.05, h * 0.25),
          Offset(w * 0.95, h * 0.75),
          stroke,
        );
        for (var i = 0; i < 3; i++) {
          final t = 0.25 + i * 0.25;
          final cx = w * (0.05 + 0.9 * t);
          final cy = h * (0.25 + 0.5 * t);
          canvas.drawCircle(Offset(cx, cy), w * 0.1, fill);
        }
        break;

      case Cuisine.street:
        // Pav bhaji bowl with bread roll alongside.
        final bowl = Path()
          ..moveTo(w * 0.08, h * 0.55)
          ..quadraticBezierTo(w * 0.08, h * 0.88, w * 0.42, h * 0.88)
          ..quadraticBezierTo(w * 0.62, h * 0.88, w * 0.62, h * 0.55)
          ..close();
        canvas.drawPath(bowl, fill);
        // Bread roll (rounded rectangle)
        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.66, h * 0.55, w * 0.28, h * 0.3),
          Radius.circular(w * 0.12),
        );
        canvas.drawRRect(rrect, stroke);
        // Steam
        final steam = Path()
          ..moveTo(w * 0.25, h * 0.4)
          ..quadraticBezierTo(w * 0.2, h * 0.32, w * 0.25, h * 0.22)
          ..quadraticBezierTo(w * 0.3, h * 0.12, w * 0.25, h * 0.02);
        canvas.drawPath(steam, stroke);
        break;

      case Cuisine.dessert:
        // Bowl of kheer / gulab jamun — pedestal bowl with two
        // spheres and a single steam ribbon.
        final bowl = Path()
          ..moveTo(w * 0.18, h * 0.5)
          ..quadraticBezierTo(w * 0.18, h * 0.78, w * 0.5, h * 0.78)
          ..quadraticBezierTo(w * 0.82, h * 0.78, w * 0.82, h * 0.5)
          ..close();
        canvas.drawPath(bowl, fill);
        // Pedestal
        canvas.drawLine(
          Offset(w * 0.5, h * 0.78),
          Offset(w * 0.5, h * 0.9),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.32, h * 0.92),
          Offset(w * 0.68, h * 0.92),
          stroke,
        );
        // Two gulab jamuns peeking
        canvas.drawCircle(Offset(w * 0.38, h * 0.5), w * 0.08, stroke);
        canvas.drawCircle(Offset(w * 0.6, h * 0.5), w * 0.08, stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(_CuisinePainter old) =>
      old.cuisine != cuisine || old.color != color;
}

/// Map a free-text food category to a [Cuisine].
Cuisine cuisineFor(String? category) {
  if (category == null) return Cuisine.northIndian;
  final c = category.toLowerCase();
  if (c.contains('south') || c.contains('dosa') || c.contains('idli')) {
    return Cuisine.southIndian;
  }
  if (c.contains('seafood') || c.contains('fish') || c.contains('coastal')) {
    return Cuisine.coastal;
  }
  if (c.contains('tandoor') || c.contains('grill') || c.contains('kabab')) {
    return Cuisine.tandoori;
  }
  if (c.contains('street') || c.contains('chaat')) {
    return Cuisine.street;
  }
  if (c.contains('dessert') || c.contains('sweet') || c.contains('kheer')) {
    return Cuisine.dessert;
  }
  return Cuisine.northIndian;
}
