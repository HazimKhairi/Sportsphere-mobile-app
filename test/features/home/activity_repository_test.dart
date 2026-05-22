import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sportsphere_mobile/features/home/data/activity_repository.dart';
import 'package:sportsphere_mobile/features/home/domain/activity_item.dart';

void main() {
  test('timelineStream returns empty list when no notifications', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = ActivityRepository(firestore: firestore);
    final items = await repo.timelineStream(userId: 'uid_1').first;
    expect(items, isEmpty);
  });

  test('timelineStream filters by userId', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('notifications').add({
      'userId': 'uid_1',
      'type': 'attendance_check_in',
      'title': 'Checked in to Training 7pm',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    await firestore.collection('notifications').add({
      'userId': 'uid_2',
      'type': 'attendance_check_in',
      'title': 'Other user activity',
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });

    final repo = ActivityRepository(firestore: firestore);
    final items = await repo.timelineStream(userId: 'uid_1').first;

    expect(items, hasLength(1));
    expect(items.first.title, 'Checked in to Training 7pm');
  });

  test('timelineStream orders by createdAt desc + caps at 5', () async {
    final firestore = FakeFirebaseFirestore();
    final base = DateTime(2026, 5, 22, 12, 0);
    for (var i = 0; i < 7; i++) {
      await firestore.collection('notifications').add({
        'userId': 'uid_1',
        'type': 'attendance_check_in',
        'title': 'Event $i',
        'createdAt': Timestamp.fromDate(base.subtract(Duration(minutes: i))),
      });
    }

    final repo = ActivityRepository(firestore: firestore);
    final items = await repo.timelineStream(userId: 'uid_1').first;

    expect(items, hasLength(5));
    expect(items.first.title, 'Event 0'); // most recent
    expect(items.last.title, 'Event 4');
  });

  test('maps notification type to Lucide icon', () async {
    final firestore = FakeFirebaseFirestore();
    final now = Timestamp.fromDate(DateTime.now());
    await firestore.collection('notifications').add({
      'userId': 'uid_1',
      'type': 'attendance_check_in',
      'title': 'Checked in',
      'createdAt': now,
    });
    await firestore.collection('notifications').add({
      'userId': 'uid_1',
      'type': 'badge_unlocked',
      'title': 'New badge',
      'createdAt': now,
    });
    await firestore.collection('notifications').add({
      'userId': 'uid_1',
      'type': 'unknown_event',
      'title': 'Generic',
      'createdAt': now,
    });

    final repo = ActivityRepository(firestore: firestore);
    final List<ActivityItem> items =
        await repo.timelineStream(userId: 'uid_1').first;

    final byTitle = {for (final i in items) i.title: i.icon};
    expect(byTitle['Checked in'], LucideIcons.check);
    expect(byTitle['New badge'], LucideIcons.award);
    expect(byTitle['Generic'], LucideIcons.bell); // default fallback
  });
}
