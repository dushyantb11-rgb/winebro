import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Captures + uploads BroCard photos. Two slots per entry:
///   bottle — the bottle in context (table, hand, glass)
///   label  — close-up of the label (used for OCR seed in v1.1)
///
/// Storage layout:
///   users/{uid}/brocard/{entryId}/{slot}.jpg
enum PhotoSlot {
  bottle('bottle'),
  label('label');

  const PhotoSlot(this.code);
  final String code;
}

class BroCardPhotoService {
  BroCardPhotoService(this._storage, this._auth, this._picker);

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  final ImagePicker _picker;

  /// Open the camera or gallery picker, upload the file, return the
  /// download URL. Returns null if the user cancels.
  Future<String?> captureAndUpload({
    required String entryId,
    required PhotoSlot slot,
    required ImageSource source,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final ref = _storage
        .ref()
        .child('users')
        .child(uid)
        .child('brocard')
        .child(entryId)
        .child('${slot.code}.jpg');

    await ref.putFile(
      File(picked.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}

final broCardPhotoServiceProvider = Provider<BroCardPhotoService>(
  (_) => BroCardPhotoService(
    FirebaseStorage.instance,
    FirebaseAuth.instance,
    ImagePicker(),
  ),
);
