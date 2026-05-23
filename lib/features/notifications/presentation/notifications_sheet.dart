import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle + header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.sc.borderSubtle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: context.sc.onSurface,
                                ),
                      ),
                      const Spacer(),
                      _MarkAllReadButton(),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: _NotificationList(scrollCtrl: scrollCtrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkAllReadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snap.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      },
      child: Text(
        'Mark all read',
        style: TextStyle(
          fontSize: 13,
          color: context.sc.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.scrollCtrl});
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return _EmptyState();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: context.sc.primary),
          );
        }

        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return _EmptyState();

        return ListView.builder(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data();
            return _NotificationTile(
              id: doc.id,
              uid: uid,
              title: data['title'] as String? ?? '',
              body: data['body'] as String? ?? '',
              type: data['type'] as String? ?? 'general',
              read: data['read'] as bool? ?? false,
              createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            );
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime? createdAt;

  (IconData, Color) _iconForType(BuildContext context) {
    return switch (type) {
      'payment' => (LucideIcons.banknote, const Color(0xFF3B82F6)),
      'session' => (LucideIcons.calendarDays, context.sc.primary),
      'announcement' => (LucideIcons.megaphone, const Color(0xFFA855F7)),
      'roster' => (LucideIcons.users, const Color(0xFFEAB308)),
      _ => (LucideIcons.bell, context.sc.onSurfaceMuted),
    };
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _markRead() {
    if (read) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(id)
        .update({'read': true});
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(context);

    return GestureDetector(
      onTap: _markRead,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: read
              ? context.sc.surface
              : context.sc.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: read
                ? context.sc.borderSubtle
                : context.sc.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: context.sc.onSurface,
                                fontWeight: read
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                        ),
                      ),
                      if (!read)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 8, top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.sc.primary,
                          ),
                        ),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.sc.onSurfaceMuted,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.bellOff,
              size: 44, color: context.sc.onSurfaceMuted),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.sc.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'re all caught up.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
