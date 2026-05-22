import 'package:flutter/material.dart';

import 'theme/sphere_colors.dart';
import 'theme/sphere_theme.dart';

class SphereApp extends StatelessWidget {
  const SphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportSphere',
      debugShowCheckedModeBanner: false,
      theme: buildSphereTheme(),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SportSphere',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: SphereColors.primary,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
