import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:sportsphere_mobile/app/theme/sphere_theme_ext.dart';
import '../../app/theme/sphere_radius.dart';

class SphereSwipeToConfirm extends StatefulWidget {
  const SphereSwipeToConfirm({
    super.key,
    required this.label,
    required this.onConfirm,
    this.busy = false,
    this.thumbIcon = LucideIcons.chevronRight,
    this.confirmedLabel = 'Confirmed',
  });

  final String label;
  final Future<void> Function() onConfirm;
  final bool busy;
  final IconData thumbIcon;
  final String confirmedLabel;

  @override
  State<SphereSwipeToConfirm> createState() => _SphereSwipeToConfirmState();
}

class _SphereSwipeToConfirmState extends State<SphereSwipeToConfirm>
    with SingleTickerProviderStateMixin {
  static const double _thumbSize = 52;
  static const double _height = 60;

  double _position = 0;
  bool _confirmed = false;
  late final AnimationController _resetCtrl;
  Animation<double> _resetAnim = const AlwaysStoppedAnimation(0);

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    )..addListener(() {
        setState(() => _position = _resetAnim.value);
      });
  }

  @override
  void dispose() {
    _resetCtrl.dispose();
    super.dispose();
  }

  void _animateReset() {
    _resetAnim = Tween<double>(begin: _position, end: 0).animate(
      CurvedAnimation(parent: _resetCtrl, curve: Curves.easeOutCubic),
    );
    _resetCtrl
      ..reset()
      ..forward();
  }

  Future<void> _handleEnd(double maxX) async {
    final threshold = maxX * 0.85;
    if (_position >= threshold) {
      setState(() {
        _position = maxX;
        _confirmed = true;
      });
      try {
        await widget.onConfirm();
      } catch (_) {
        if (mounted) {
          setState(() {
            _confirmed = false;
          });
          _animateReset();
        }
      }
    } else {
      _animateReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxX = constraints.maxWidth - _thumbSize;
        final progress = maxX <= 0 ? 0.0 : (_position / maxX).clamp(0.0, 1.0);

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              // Track
              Container(
                height: _height,
                decoration: BoxDecoration(
                  color: context.sc.surfaceElev1,
                  borderRadius: SphereRadius.pillRect,
                  border: Border.all(color: context.sc.borderSubtle),
                ),
              ),
              // Filled progress
              ClipRRect(
                borderRadius: SphereRadius.pillRect,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: _position + _thumbSize / 2,
                    height: _height,
                    color: context.sc.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              // Label
              Center(
                child: Opacity(
                  opacity: 1 - progress,
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: context.sc.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Confirmed overlay
              if (_confirmed)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.busy)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(context.sc.primary),
                          ),
                        )
                      else
                        Icon(LucideIcons.check,
                            size: 18, color: context.sc.primary),
                      const SizedBox(width: 8),
                      Text(
                        widget.confirmedLabel,
                        style: TextStyle(
                          color: context.sc.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              // Thumb
              Positioned(
                left: _position,
                top: (_height - _thumbSize) / 2,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: _confirmed || widget.busy
                      ? null
                      : (details) {
                          setState(() {
                            _position = (_position + details.delta.dx)
                                .clamp(0.0, maxX);
                          });
                        },
                  onPanEnd: _confirmed || widget.busy
                      ? null
                      : (_) => _handleEnd(maxX),
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.sc.primary,
                    ),
                    child: Icon(
                      widget.thumbIcon,
                      color: context.sc.onPrimary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
