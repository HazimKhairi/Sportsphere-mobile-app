import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { image, video }

class SessionMediaItem {
  const SessionMediaItem({
    required this.id,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.uploadedByName,
    required this.storagePath,
  });

  final String id;
  final String url;
  final MediaType type;
  final DateTime uploadedAt;
  final String uploadedByName;
  final String storagePath;

  factory SessionMediaItem.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SessionMediaItem(
      id: doc.id,
      url: d['url'] as String,
      type: (d['type'] as String) == 'video' ? MediaType.video : MediaType.image,
      uploadedAt: (d['uploadedAt'] as Timestamp).toDate(),
      uploadedByName: d['uploadedByName'] as String,
      storagePath: d['storagePath'] as String,
    );
  }
}
