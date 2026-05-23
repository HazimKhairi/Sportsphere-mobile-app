import 'package:flutter/material.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../../../app/theme/sphere_radius.dart';

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(color: context.sc.borderSubtle, height: 1),
        ));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(children: rows),
    );
  }
}
