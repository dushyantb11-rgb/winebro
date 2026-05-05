import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_calibration.dart';

/// 3-aroma calibration mini-quiz. Each card asks:
///   1. "Have you smelled [aroma]?" — Familiar / Sometimes / Never
///   2. "What does it remind you of?" — optional free text
///
/// Saved at:
///   users/{uid}/aroma_calibration/{sessionId} {
///     startedAt, completedAt, responses: [...]
///   }
///
/// D3 "Indian-context aroma vocabulary" pipeline. The free-text
/// answers are the gold — they teach Bro what Indian users
/// actually associate scents with.
class AromaCalibrationSheet extends ConsumerStatefulWidget {
  const AromaCalibrationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AromaCalibrationSheet(),
    );
  }

  @override
  ConsumerState<AromaCalibrationSheet> createState() =>
      _AromaCalibrationSheetState();
}

class _AromaCalibrationSheetState
    extends ConsumerState<AromaCalibrationSheet> {
  late final List<({String aroma, String category})> _session;
  final _associationController = TextEditingController();
  final _responses = <AromaCalibrationResponse>[];
  int _index = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _session = AromaCalibrationBuilder.buildSession(
      seed: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  void dispose() {
    _associationController.dispose();
    super.dispose();
  }

  Future<void> _record(AromaFamiliarity familiarity) async {
    final entry = _session[_index];
    final association = _associationController.text.trim();
    HapticFeedback.lightImpact();

    _responses.add(AromaCalibrationResponse(
      aroma: entry.aroma,
      category: entry.category,
      familiarity: familiarity,
      userAssociation: association.isNotEmpty ? association : null,
    ));
    _associationController.clear();

    if (_index < _session.length - 1) {
      setState(() => _index += 1);
      return;
    }

    setState(() => _saving = true);
    await _persistSession();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.aromaCalibrationThanks)),
    );
  }

  Future<void> _persistSession() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('aroma_calibration')
          .doc(sessionId)
          .set({
        'sessionId': sessionId,
        'completedAt': FieldValue.serverTimestamp(),
        'responses': _responses.map((r) => r.toMap()).toList(),
      });
    } catch (_) {
      // Silent fail — calibration is best-effort, not blocking.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final entry = _session[_index];

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
            Row(
              children: List.generate(_session.length, (i) {
                final active = i <= _index;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: i == _session.length - 1 ? 0 : 6,
                    ),
                    height: 3,
                    decoration: BoxDecoration(
                      color: active
                          ? context.salemOnSurface
                          : colors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.aromaCalibrationEyebrow,
              style: context.eyebrow.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.aromaCalibrationPrompt(entry.aroma),
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.category,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _associationController,
              enabled: !_saving,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: context.l10n.aromaCalibrationAssociationHint,
                hintStyle: TextStyle(color: colors.textTertiary),
                filled: true,
                fillColor: colors.surface1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.paprika),
                ),
              ),
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            _ChoiceTile(
              colors: colors,
              label: context.l10n.aromaCalibrationFamiliar,
              accent: context.salemOnSurface,
              icon: Icons.check_circle_outline,
              enabled: !_saving,
              onTap: () => _record(AromaFamiliarity.familiar),
            ),
            const SizedBox(height: 10),
            _ChoiceTile(
              colors: colors,
              label: context.l10n.aromaCalibrationSometimes,
              accent: colors.textSecondary,
              icon: Icons.help_outline,
              enabled: !_saving,
              onTap: () => _record(AromaFamiliarity.sometimes),
            ),
            const SizedBox(height: 10),
            _ChoiceTile(
              colors: colors,
              label: context.l10n.aromaCalibrationNever,
              accent: context.paprikaOnSurface,
              icon: Icons.close,
              enabled: !_saving,
              onTap: () => _record(AromaFamiliarity.never),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.colors,
    required this.label,
    required this.accent,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final AppColors colors;
  final String label;
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
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: colors.textTertiary, size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
