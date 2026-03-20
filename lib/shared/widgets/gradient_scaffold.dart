import 'package:flutter/material.dart';
import 'package:winebro/core/theme/app_colors.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    required this.child,
    this.useSplashGradient = false,
    super.key,
  });

  final Widget child;
  final bool useSplashGradient;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: useSplashGradient
                ? [colors.charcoal, colors.charcoalDeep, colors.paprikaDark]
                : [colors.charcoal, colors.charcoalDeep],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

