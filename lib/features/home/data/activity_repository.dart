import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/activity_item.dart';

class ActivityRepository {
  ActivityRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<ActivityItem>> timelineStream({required String userId}) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  ActivityItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final ts = data['createdAt'];
    final createdAt = ts is Timestamp ? ts.toDate() : DateTime.now();
    return ActivityItem(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      createdAt: createdAt,
      icon: _iconForType((data['type'] as String?) ?? ''),
      actionPath: data['actionPath'] as String?,
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'attendance_check_in':
      case 'payment_success':
        return LucideIcons.check;
      case 'streak_milestone':
        return LucideIcons.flame;
      case 'match_scheduled':
      case 'session_scheduled':
        return LucideIcons.calendar;
      case 'badge_unlocked':
      case 'achievement_unlocked':
        return LucideIcons.award;
      case 'announcement':
        return LucideIcons.megaphone;
      default:
        return LucideIcons.bell;
    }
  }
}
