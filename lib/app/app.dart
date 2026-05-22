import 'package:flutter/material.dart';

class SphereApp extends StatelessWidget {
  const SphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SportSphere',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: Text(
            'SportSphere',
            style: TextStyle(color: Color(0xFF39FF14), fontSize: 24),
          ),
        ),
      ),
    );
  }
}
