import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/pairing_feedback/domain/pairing_feedback.dart';

/// "Did Bro get it right?" — collected 24h after a journal entry's
/// foodPaired field was set. CF-09 fires the push; this sheet
/// captures the response.
///
/// Schema written:
///   pairing_feedback/{userId}_{entryId} {
///     userId, entryId, productId, productName, foodPaired,
///     response: 'yes'|'maybe'|'no', respondedAt
///   }
///
/// Aggregate counter incremented (transactional) on:
///   pairing_aggregates/{productId}__{dishKey} {
///     productId, dishKey, yes, maybe, no, total, lastUpdatedAt
///   }
/// — this is the table that S2.3 engine v1.1 reads to reorder picks.
class PairingFeedbackSheet extends ConsumerStatefulWidget {
  const PairingFeedbackSheet({required this.entryId, super.key});

  final String entryId;

  static Future<void> show(BuildContext context, String entryId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PairingFeedbackSheet(entryId: entryId),
    );
  }

  @override
  ConsumerState<PairingFeedbackSheet> createState() =>
      _PairingFeedbackSheetState();
}

class _PairingFeedbackSheetState extends ConsumerState<PairingFeedbackSheet> {
  bool _saving = false;
  Map<String, dynamic>? _entry;
  bool _loaded = false;
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loaded = true;
        _missing = true;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('journal')
          .doc(widget.entryId)
          .get();
      if (!mounted) return;
      if (!doc.exists || doc.data()?['foodPaired'] == null) {
        setState(() {
          _loaded = true;
          _missing = true;
        });
        return;
      }
      setState(() {
        _entry = doc.data();
        _loaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _missing = true;
      });
    }
  }

  Future<void> _record(PairingResponse response) async {
    if (_saving || _entry == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final productId = _entry!['productId'] as String? ?? '';
    final productName = _entry!['productName'] as String? ?? '';
    final foodPaired = _entry!['foodPaired'] as String? ?? '';
    final dishKey = _normalizeDishKey(foodPaired);
    final feedback = PairingFeedback(
      id: '${uid}_${widget.entryId}',
      userId: uid,
      entryId: widget.entryId,
      productId: productId,
      productName: productName,
      foodPaired: foodPaired,
      response: response,
      respondedAt: DateTime.now(),
    );

    final firestore = FirebaseFirestore.instance;
    final feedbackRef =
        firestore.collection('pairing_feedback').doc(feedback.id);
    final aggregateRef = firestore
        .collection('pairing_aggregates')
        .doc('${productId}__$dishKey');

    try {
      await firestore.runTransaction((tx) async {
        // Idempotent: write feedback (set, not add) and increment
        // aggregate atomically. Re-tap of the same response is a
        // no-op write, but we use a sentinel field to avoid double
        // counting if the user changed their mind on a re-tap.
        final existing = await tx.get(feedbackRef);
        final prior = existing.exists
            ? PairingResponse.fromCode(existing.data()?['response'] as String?)
            : null;

        tx.set(feedbackRef, feedback.toMap());

        final aggregateDoc = await tx.get(aggregateRef);
        final aggregateData =
            aggregateDoc.data() ?? <String, dynamic>{};
        int yes = (aggregateData['yes'] as int?) ?? 0;
        int maybe = (aggregateData['maybe'] as int?) ?? 0;
        int no = (aggregateData['no'] as int?) ?? 0;

        if (prior != null) {
          // Reverse the previous tally before applying the new one.
          switch (prior) {
            case PairingResponse.yes:
              yes = yes > 0 ? yes - 1 : 0;
            case PairingResponse.maybe:
              maybe = maybe > 0 ? maybe - 1 : 0;
            case PairingResponse.no:
              no = no > 0 ? no - 1 : 0;
          }
        }
        switch (response) {
          case PairingResponse.yes:
            yes += 1;
          case PairingResponse.maybe:
            maybe += 1;
          case PairingResponse.no:
            no += 1;
        }

        tx.set(aggregateRef, {
          'productId': productId,
          'dishKey': dishKey,
          'yes': yes,
          'maybe': maybe,
          'no': no,
          'total': yes + maybe + no,
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.feedbackThanks)),
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _normalizeDishKey(String dish) {
    return dish
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.charcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (!_loaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_missing)
              _MissingState(colors: colors)
            else
              _Body(
                colors: colors,
                productName: _entry!['productName'] as String? ?? '',
                foodPaired: _entry!['foodPaired'] as String? ?? '',
                saving: _saving,
                onRespond: _record,
              ),
          ],
        ),
      ),
    );
  }
}

class _MissingState extends StatelessWidget {
  const _MissingState({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.search_off, color: colors.textTertiary, size: 48),
          const SizedBox(height: 12),
          Text(
            context.l10n.feedbackEntryNotFound,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.colors,
    required this.productName,
    required this.foodPaired,
    required this.saving,
    required this.onRespond,
  });

  final AppColors colors;
  final String productName;
  final String foodPaired;
  final bool saving;
  final void Function(PairingResponse) onRespond;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.feedbackSheetTitle,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: colors.textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.feedbackSheetSubtitle(productName, foodPaired),
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        _ResponseTile(
          colors: colors,
          label: context.l10n.feedbackResponseYes,
          helper: context.l10n.feedbackResponseHelperYes,
          accent: context.salemOnSurface,
          icon: Icons.check_circle_rounded,
          enabled: !saving,
          onTap: () => onRespond(PairingResponse.yes),
        ),
        const SizedBox(height: 12),
        _ResponseTile(
          colors: colors,
          label: context.l10n.feedbackResponseMaybe,
          helper: context.l10n.feedbackResponseHelperMaybe,
          accent: colors.textSecondary,
          icon: Icons.help_outline_rounded,
          enabled: !saving,
          onTap: () => onRespond(PairingResponse.maybe),
        ),
        const SizedBox(height: 12),
        _ResponseTile(
          colors: colors,
          label: context.l10n.feedbackResponseNo,
          helper: context.l10n.feedbackResponseHelperNo,
          accent: context.paprikaOnSurface,
          icon: Icons.cancel_outlined,
          enabled: !saving,
          onTap: () => onRespond(PairingResponse.no),
        ),
      ],
    );
  }
}

class _ResponseTile extends StatelessWidget {
  const _ResponseTile({
    required this.colors,
    required this.label,
    required this.helper,
    required this.accent,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final AppColors colors;
  final String label;
  final String helper;
  final Color accent;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        helper,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: colors.textTertiary, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
