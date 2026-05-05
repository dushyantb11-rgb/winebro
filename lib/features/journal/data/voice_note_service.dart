import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Captures voice notes for a BroCard. Two parallel streams:
///   1. Audio file (m4a) — local temp recording, optionally uploaded
///      to Storage at users/{uid}/brocard/{entryId}/notes.m4a
///   2. Real-time transcript — on-device STT via speech_to_text
///
/// Both run from a single `start()` so the user gets immediate text
/// feedback while we also keep the raw audio for v1.2 STT training.
class VoiceNoteService {
  VoiceNoteService(this._storage, this._auth, this._recorder, this._stt);

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final AudioRecorder _recorder;
  final stt.SpeechToText _stt;

  String? _localPath;
  bool _sttReady = false;

  Future<bool> _ensureStt() async {
    if (_sttReady) return true;
    _sttReady = await _stt.initialize(onError: (_) {});
    return _sttReady;
  }

  /// Starts recording + STT. Streams partial transcript via [onText].
  /// Returns true on success, false if either microphone permission
  /// or STT init failed.
  Future<bool> start({
    required void Function(String text) onText,
    String localeId = 'en_IN',
  }) async {
    final hasMic = await _recorder.hasPermission();
    if (!hasMic) return false;

    final ok = await _ensureStt();
    if (!ok) return false;

    final dir = await getTemporaryDirectory();
    _localPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 96000,
        sampleRate: 44100,
      ),
      path: _localPath!,
    );

    await _stt.listen(
      onResult: (r) => onText(r.recognizedWords),
      localeId: localeId,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );

    return true;
  }

  /// Stop recording + STT. Returns the local audio path (caller can
  /// pass it to [uploadAudio] later if Storage is available).
  Future<String?> stop() async {
    await _stt.stop();
    final path = await _recorder.stop();
    return path ?? _localPath;
  }

  Future<void> cancel() async {
    await _stt.cancel();
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
  }

  /// Upload the captured audio to Storage. Returns the download URL,
  /// or null if Storage isn't initialized for the project (graceful
  /// fallback — text transcript still works without this).
  Future<String?> uploadAudio({
    required String entryId,
    required String localPath,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(uid)
          .child('brocard')
          .child(entryId)
          .child('notes.m4a');
      await ref.putFile(
        File(localPath),
        SettableMetadata(contentType: 'audio/mp4'),
      );
      return ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

final voiceNoteServiceProvider = Provider<VoiceNoteService>(
  (_) => VoiceNoteService(
    FirebaseStorage.instance,
    FirebaseAuth.instance,
    AudioRecorder(),
    stt.SpeechToText(),
  ),
);
