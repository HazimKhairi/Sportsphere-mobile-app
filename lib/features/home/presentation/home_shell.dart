import 'package:flutter/material.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(child: Text('Shell')),
          ),
        ],
      ),
    );
  }
}
