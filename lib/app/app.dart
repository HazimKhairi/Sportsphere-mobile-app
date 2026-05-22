import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/role_pick/presentation/role_providers.dart';
import 'router.dart';
import 'theme/sphere_theme.dart';

class SphereApp extends ConsumerStatefulWidget {
  const SphereApp({super.key});

  @override
  ConsumerState<SphereApp> createState() => _SphereAppState();
}

class _SphereAppState extends ConsumerState<SphereApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(selectedRoleProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SportSphere',
      debugShowCheckedModeBanner: false,
      theme: buildSphereTheme(),
      routerConfig: router,
    );
  }
}
