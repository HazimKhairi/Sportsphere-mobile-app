import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import '../domain/session_media_item.dart';

class SessionMediaRepository {
  SessionMediaRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _mediaCol(
          String clubId, String sessionId) =>
      _db
          .collection('clubs')
          .doc(clubId)
          .collection('training_sessions')
          .doc(sessionId)
          .collection('media');

  Stream<List<SessionMediaItem>> mediaStream({
    required String clubId,
    required String sessionId,
  }) {
    return _mediaCol(clubId, sessionId)
        .orderBy('uploadedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs
            .map((d) => SessionMediaItem.fromDoc(
                d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<void> uploadMedia({
    required String clubId,
    required String sessionId,
    required String localPath,
    required MediaType type,
    required String uploaderName,
    void Function(double progress)? onProgress,
  }) async {
    final ext = p.extension(localPath).replaceFirst('.', '');
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}_${type.name}.$ext';
    final storagePath = 'sessions/$clubId/$sessionId/$filename';

    final ref = _storage.ref(storagePath);
    final uploadTask = ref.putFile(File(localPath));

    uploadTask.snapshotEvents.listen((snapshot) {
      if (onProgress != null && snapshot.totalBytes > 0) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });

    await uploadTask;
    final url = await ref.getDownloadURL();

    await _mediaCol(clubId, sessionId).add({
      'url': url,
      'type': type.name,
      'uploadedAt': FieldValue.serverTimestamp(),
      'uploadedByName': uploaderName,
      'storagePath': storagePath,
    });
  }

  Future<void> deleteMedia({
    required String clubId,
    required String sessionId,
    required String itemId,
    required String storagePath,
  }) async {
    await _storage.ref(storagePath).delete();
    await _mediaCol(clubId, sessionId).doc(itemId).delete();
  }
}
