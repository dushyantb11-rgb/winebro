import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';

/// Friendly "couldn't load" message with a Try again button. Records the
/// real error in Crashlytics so failures can be diagnosed from the field.
class LoadErrorView extends StatefulWidget {
  const LoadErrorView({
    required this.error,
    required this.onRetry,
    this.stackTrace,
    this.reason,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;
  final String? reason;
  final VoidCallback onRetry;

  @override
  State<LoadErrorView> createState() => _LoadErrorViewState();
}

class _LoadErrorViewState extends State<LoadErrorView> {
  @override
  void initState() {
    super.initState();
    try {
      FirebaseCrashlytics.instance
          .recordError(widget.error, widget.stackTrace, reason: widget.reason);
    } on Object catch (_) {
      // Crashlytics unavailable (e.g. tests); the message still shows.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: colors.textTertiary),
            const SizedBox(height: 12),
            Text(
              context.l10n.loadErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
