import 'package:flutter/material.dart';

class SphereCountUp extends StatefulWidget {
  const SphereCountUp({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 700),
  });
  final int value;
  final TextStyle style;
  final Duration duration;

  @override
  State<SphereCountUp> createState() => _SphereCountUpState();
}

class _SphereCountUpState extends State<SphereCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        final n = (widget.value * t).round();
        return Text('$n', style: widget.style);
      },
    );
  }
}
