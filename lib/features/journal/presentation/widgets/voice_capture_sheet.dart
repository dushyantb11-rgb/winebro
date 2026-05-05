import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/journal/data/voice_note_service.dart';

/// Returned to the caller when the user accepts a voice note.
/// `audioPath` is a local file path; the caller decides whether to
/// upload it (depends on `entryId` lifecycle).
class VoiceCaptureResult {
  const VoiceCaptureResult({required this.transcript, this.audioPath});

  final String transcript;
  final String? audioPath;
}

/// Hold-to-record sheet that runs STT + audio capture together.
/// Returns a VoiceCaptureResult on accept, or null on cancel.
class VoiceCaptureSheet extends ConsumerStatefulWidget {
  const VoiceCaptureSheet({super.key});

  static Future<VoiceCaptureResult?> show(BuildContext context) {
    return showModalBottomSheet<VoiceCaptureResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => const VoiceCaptureSheet(),
    );
  }

  @override
  ConsumerState<VoiceCaptureSheet> createState() => _VoiceCaptureSheetState();
}

class _VoiceCaptureSheetState extends ConsumerState<VoiceCaptureSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  String _transcript = '';
  bool _recording = false;
  bool _starting = false;
  String? _localPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_starting) return;
    final svc = ref.read(voiceNoteServiceProvider);

    if (_recording) {
      final path = await svc.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _localPath = path;
      });
      return;
    }

    setState(() {
      _starting = true;
      _errorMessage = null;
    });
    HapticFeedback.mediumImpact();

    final ok = await svc.start(onText: (t) {
      if (!mounted) return;
      setState(() => _transcript = t);
    });
    if (!mounted) return;
    setState(() {
      _starting = false;
      _recording = ok;
      if (!ok) {
        _errorMessage = context.l10n.voiceCapturePermissionError;
      }
    });
  }

  Future<void> _accept() async {
    if (_transcript.trim().isEmpty) return;
    if (_recording) {
      final path = await ref.read(voiceNoteServiceProvider).stop();
      _localPath = path;
    }
    if (!mounted) return;
    Navigator.pop(
      context,
      VoiceCaptureResult(
        transcript: _transcript.trim(),
        audioPath: _localPath,
      ),
    );
  }

  Future<void> _cancel() async {
    await ref.read(voiceNoteServiceProvider).cancel();
    if (!mounted) return;
    Navigator.pop(context, null);
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
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.voiceCaptureTitle,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: _cancel,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _recording
                  ? context.l10n.voiceCaptureListening
                  : (_transcript.isEmpty
                      ? context.l10n.voiceCaptureHint
                      : context.l10n.voiceCaptureReview),
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(minHeight: 100, maxHeight: 220),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _transcript.isEmpty
                      ? context.l10n.voiceCapturePlaceholder
                      : _transcript,
                  style: TextStyle(
                    color: _transcript.isEmpty
                        ? colors.textTertiary
                        : colors.textPrimary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: context.paprikaOnSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) {
                    final scale = _recording ? 1 + 0.08 * _pulse.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _recording ? colors.paprika : colors.surface2,
                          border: Border.all(
                            color: colors.paprika,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _recording ? Icons.stop : Icons.mic,
                          color: _recording ? colors.inkOnHero : colors.paprika,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.borderDefault),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      context.l10n.voiceCaptureCancel,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _transcript.trim().isNotEmpty ? _accept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.paprika,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      context.l10n.voiceCaptureUseTranscript,
                      style: TextStyle(
                        color: colors.inkOnHero,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
