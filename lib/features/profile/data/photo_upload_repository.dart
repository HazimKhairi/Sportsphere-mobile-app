import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_upload_repository.g.dart';

class PhotoUploadRepository {
  PhotoUploadRepository({
    ImagePicker? picker,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _picker = picker ?? ImagePicker(),
        _storageOverride = storage,
        _authOverride = auth;

  final ImagePicker _picker;
  final FirebaseStorage? _storageOverride;
  final FirebaseAuth? _authOverride;

  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  Future<XFile?> pickPhoto({required bool fromCamera}) async {
    return _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
  }

  /// Uploads [file] to `profile-photos/{uid}/photo.jpg`, updates Firebase Auth
  /// photoURL, returns the download URL.
  Future<String> uploadPhoto(XFile file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw PhotoUploadException('Not signed in');

    final ref = _storage.ref('profile-photos/$uid/photo.jpg');
    final bytes = await File(file.path).readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    await _auth.currentUser!.updatePhotoURL(url);
    return url;
  }
}

class PhotoUploadException implements Exception {
  PhotoUploadException(this.message);
  final String message;
  @override
  String toString() => 'PhotoUploadException: $message';
}

@Riverpod(keepAlive: true)
PhotoUploadRepository photoUploadRepository(Ref ref) =>
    PhotoUploadRepository();
