import 'package:flutter/widgets.dart';

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.icon,
    this.actionPath,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final IconData icon;
  final String? actionPath;
}
