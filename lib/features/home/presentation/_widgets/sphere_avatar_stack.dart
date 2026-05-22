import 'package:flutter/material.dart';
import '../../../../app/theme/sphere_colors.dart';

class SphereAvatarStack extends StatelessWidget {
  const SphereAvatarStack({
    super.key,
    required this.total,
    this.visibleCount = 5,
    this.avatarSize = 32,
  });
  final int total;
  final int visibleCount;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final shown = visibleCount < total ? visibleCount : total;
    final remaining = total - shown;
    return SizedBox(
      height: avatarSize,
      child: Stack(
        children: [
          for (var i = 0; i < shown; i++)
            Positioned(
              left: i * (avatarSize - 10),
              child: _AvatarBubble(
                size: avatarSize,
                seed: i,
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: shown * (avatarSize - 10),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SphereColors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: SphereColors.surface,
                    width: 2,
                  ),
                ),
                child: Text(
                  '+$remaining',
                  style: const TextStyle(
                    color: SphereColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarBubble extends StatelessWidget {
  const _AvatarBubble({required this.size, required this.seed});
  final double size;
  final int seed;

  static const _palette = [
    Color(0xFF3F8CFF),
    Color(0xFFFF8A4C),
    Color(0xFFA855F7),
    Color(0xFFEAB308),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _palette[seed % _palette.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.8),
        border: Border.all(color: SphereColors.surface, width: 2),
      ),
      child: Center(
        child: Text(
          String.fromCharCode(65 + seed),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
