import 'package:flutter/material.dart';
import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';

class SphereActivityTimelineItem extends StatelessWidget {
  const SphereActivityTimelineItem({
    super.key,
    required this.title,
    required this.timeAgo,
    required this.icon,
    this.isLast = false,
  });
  final String title;
  final String timeAgo;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.sc.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: context.sc.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, size: 14, color: context.sc.primary),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: context.sc.borderSubtle,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
