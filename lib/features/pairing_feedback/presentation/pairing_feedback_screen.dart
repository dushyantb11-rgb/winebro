import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing_feedback/presentation/pairing_feedback_sheet.dart';

/// Deep-link landing screen for the 24h pairing feedback push.
/// Pops the bottom sheet on first frame, then navigates back to
/// /journal once the user has responded (or dismissed).
class PairingFeedbackScreen extends StatefulWidget {
  const PairingFeedbackScreen({required this.entryId, super.key});

  final String entryId;

  @override
  State<PairingFeedbackScreen> createState() => _PairingFeedbackScreenState();
}

class _PairingFeedbackScreenState extends State<PairingFeedbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await PairingFeedbackSheet.show(context, widget.entryId);
      if (!mounted) return;
      context.go('/journal');
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.charcoal,
      body: const SizedBox.expand(),
    );
  }
}
