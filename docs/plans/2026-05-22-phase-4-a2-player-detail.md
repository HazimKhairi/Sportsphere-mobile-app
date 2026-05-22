# Phase 4-A2: Player Detail Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Staff taps a player in the roster list and sees a full player profile with photo/initials, name, position, contact info, availability badge, and team.

**Architecture:** New `PlayerDetail` domain model + `getPlayer(id)` on existing `RosterRepository` + Riverpod `playerDetailProvider` + `PlayerDetailScreen` with Stack hero-gradient layout. Route `/staff/roster/:id` stub replaced with real screen.

**Tech Stack:** Flutter, Riverpod (riverpod_annotation), go_router, Dio, LucideIcons, SphereColors/SphereSpacing/SphereRadius, mocktail for tests.

---

### Task 1: Domain model — `PlayerDetail`

**Files:**
- Create: `lib/features/roster/domain/player_detail.dart`

**Step 1: Create the file**

```dart
class PlayerDetail {
  const PlayerDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.teamName,
    this.photoUrl,
    this.dateOfBirth,
    this.availability,
    this.jerseyNumber,
    this.parentName,
    this.parentPhone,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String position;
  final String teamName;
  final String? photoUrl;
  final String? dateOfBirth;
  final String? availability; // null | 'injured' | 'sick' | 'away'
  final int? jerseyNumber;
  final String? parentName;
  final String? parentPhone;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
```

**Step 2: No test needed for pure data class (getters covered by repository test)**

---

### Task 2: `getPlayer` in `RosterRepository` + imports/exports

**Files:**
- Modify: `lib/features/roster/data/roster_repository.dart`

**Step 1: Add import+export at top of roster_repository.dart (after existing import)**

```dart
import '../domain/player_detail.dart';
export '../domain/player_detail.dart';
```

**Step 2: Add `getPlayer` method inside `RosterRepository` class (after `listPlayers`)**

```dart
Future<PlayerDetail> getPlayer({required String id}) async {
  try {
    final res = await _dio.get<Map<String, dynamic>>('/api/players/$id');
    final data = res.data ?? const <String, dynamic>{};
    final p = (data['player'] as Map<String, dynamic>?) ?? data;
    return PlayerDetail(
      id: p['id'] as String? ?? id,
      firstName: p['firstName'] as String? ?? '',
      lastName: p['lastName'] as String? ?? '',
      email: p['email'] as String? ?? '',
      phone: p['phone'] as String? ?? '',
      position: p['position'] as String? ?? '',
      teamName: p['teamName'] as String? ?? '',
      photoUrl: p['photoUrl'] as String? ?? p['passportPhotoUrl'] as String?,
      dateOfBirth: p['dateOfBirth'] as String?,
      availability: p['availability'] as String?,
      jerseyNumber: (p['jerseyNumber'] as num?)?.toInt(),
      parentName: p['parentName'] as String?,
      parentPhone: p['parentPhone'] as String?,
    );
  } on DioException catch (e) {
    throw RosterException(
      e.response?.data is Map
          ? (e.response!.data as Map)['error']?.toString() ?? 'Player not found'
          : 'Player not found',
      statusCode: e.response?.statusCode,
    );
  }
}
```

---

### Task 3: Repository test for `getPlayer`

**Files:**
- Modify: `test/features/roster/roster_repository_test.dart`

**Step 1: Add the test inside `main()`, after existing tests**

```dart
test('getPlayer success', () async {
  when(() => dio.get<Map<String, dynamic>>(
        '/api/players/abc',
      )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/api/players/abc'),
            statusCode: 200,
            data: {
              'player': {
                'id': 'abc',
                'firstName': 'Ahmad',
                'lastName': 'Zulkifli',
                'email': 'ahmad@example.com',
                'phone': '+601123456789',
                'position': 'Midfielder',
                'teamName': 'U12 Team A',
                'photoUrl': null,
                'dateOfBirth': '2012-03-15',
                'availability': 'injured',
                'jerseyNumber': 10,
                'parentName': 'Zulkifli Hamid',
                'parentPhone': '+601198765432',
              }
            },
          ));

  final detail = await repo.getPlayer(id: 'abc');

  expect(detail.fullName, 'Ahmad Zulkifli');
  expect(detail.availability, 'injured');
  expect(detail.jerseyNumber, 10);
});
```

**Step 2: Run roster tests**

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile
flutter test test/features/roster/roster_repository_test.dart --reporter=compact
```

Expected: 5 tests PASS (4 existing + 1 new).

**Step 3: Commit**

```bash
git -C /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile \
  add lib/features/roster/domain/player_detail.dart \
      lib/features/roster/data/roster_repository.dart \
      test/features/roster/roster_repository_test.dart
git -C /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile \
  commit -m "feat(roster): add PlayerDetail domain model + getPlayer repository method"
```

---

### Task 4: `playerDetailProvider` in roster_providers.dart + build_runner

**Files:**
- Modify: `lib/features/roster/presentation/roster_providers.dart`
- Regenerate: `lib/features/roster/presentation/roster_providers.g.dart`

**Step 1: Add provider at bottom of roster_providers.dart (before the last closing brace)**

```dart
@riverpod
Future<PlayerDetail> playerDetail(PlayerDetailRef ref, {required String playerId}) {
  return ref.watch(rosterRepositoryProvider).getPlayer(id: playerId);
}
```

Note: `PlayerDetail` is already exported via `roster_repository.dart` → `player_detail.dart`, so no extra import needed since `roster_repository.dart` is already imported.

**Step 2: Run build_runner**

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile
dart run build_runner build --delete-conflicting-outputs
```

Expected: `roster_providers.g.dart` regenerated with `playerDetailProvider`.

---

### Task 5: `PlayerDetailScreen`

**Files:**
- Create: `lib/features/roster/presentation/player_detail_screen.dart`

**Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../data/roster_repository.dart';
import 'roster_providers.dart';

class PlayerDetailScreen extends ConsumerWidget {
  const PlayerDetailScreen({super.key, required this.playerId});

  final String playerId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/staff/roster');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
      playerDetailProvider(playerId: playerId),
    );

    return detailAsync.when(
      loading: () => Scaffold(
        backgroundColor: SphereColors.surface,
        body: const Center(
          child: CircularProgressIndicator(
            color: SphereColors.primary,
          ),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: SphereColors.surface,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.userX,
                color: SphereColors.onSurfaceMuted,
                size: 48,
              ),
              const SizedBox(height: SphereSpacing.x16),
              const Text(
                'Player not found',
                style: TextStyle(
                  color: SphereColors.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SphereSpacing.x24),
              TextButton(
                onPressed: () => _back(context),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
      data: (player) => _PlayerDetailContent(
        player: player,
        onBack: () => _back(context),
      ),
    );
  }
}

class _PlayerDetailContent extends StatelessWidget {
  const _PlayerDetailContent({
    required this.player,
    required this.onBack,
  });

  final PlayerDetail player;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SphereColors.surface,
      body: Stack(
        children: [
          // Hero gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: _GradientHeader(),
          ),
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SphereSpacing.x16),
              child: _BackButton(onPressed: onBack),
            ),
          ),
          // Main scrollable content (below fold)
          Positioned(
            top: 140,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: SphereColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Space for avatar overlap
                    const SizedBox(height: 60),
                    // Name
                    Text(
                      player.fullName,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: SphereColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    // Jersey number
                    if (player.jerseyNumber != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '#${player.jerseyNumber}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: SphereColors.onSurfaceMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Availability badge
                    if (player.availability != null)
                      _AvailabilityBadge(status: player.availability!),
                    const SizedBox(height: 24),
                    // Position + team row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.crosshair,
                          size: 14,
                          color: SphereColors.onSurfaceMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          player.position.isEmpty
                              ? 'No position'
                              : player.position,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SphereColors.onSurfaceMuted,
                              ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          LucideIcons.shield,
                          size: 14,
                          color: SphereColors.onSurfaceMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          player.teamName.isEmpty ? 'No team' : player.teamName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SphereColors.onSurfaceMuted,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Contact card
                    _InfoCard(
                      title: 'CONTACT',
                      items: [
                        _InfoRow(
                          icon: LucideIcons.mail,
                          label: 'Email',
                          value: player.email.isEmpty ? '—' : player.email,
                        ),
                        _InfoRow(
                          icon: LucideIcons.phone,
                          label: 'Phone',
                          value: player.phone.isEmpty ? '—' : player.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Personal card
                    _InfoCard(
                      title: 'PERSONAL',
                      items: [
                        _InfoRow(
                          icon: LucideIcons.cake,
                          label: 'Date of birth',
                          value: player.dateOfBirth ?? '—',
                        ),
                      ],
                    ),
                    // Parent card (conditional)
                    if (player.parentName != null ||
                        player.parentPhone != null) ...[
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'PARENT / GUARDIAN',
                        items: [
                          if (player.parentName != null)
                            _InfoRow(
                              icon: LucideIcons.user,
                              label: 'Name',
                              value: player.parentName!,
                            ),
                          if (player.parentPhone != null)
                            _InfoRow(
                              icon: LucideIcons.phone,
                              label: 'Phone',
                              value: player.parentPhone!,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Avatar (centered, overlapping the fold at top=100)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: _Avatar(player: player),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SphereColors.primary.withValues(alpha: 0.1),
            SphereColors.surface.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: SphereColors.surfaceElev1,
          borderRadius: SphereRadius.pillRect,
          border: Border.all(color: SphereColors.borderSubtle),
        ),
        child: const Icon(
          LucideIcons.arrowLeft,
          size: 18,
          color: SphereColors.onSurface,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player});

  final PlayerDetail player;

  @override
  Widget build(BuildContext context) {
    final photoUrl = player.photoUrl;
    return CircleAvatar(
      radius: 72,
      backgroundColor: SphereColors.primary.withValues(alpha: 0.18),
      foregroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
      child: photoUrl == null
          ? Text(
              player.initials,
              style: const TextStyle(
                color: SphereColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            )
          : null,
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'injured' => ('Injured', const Color(0xFFEF4444)),
      'sick' => ('Sick', const Color(0xFFF59E0B)),
      'away' => ('Away', const Color(0xFF3B82F6)),
      _ => ('Unavailable', SphereColors.onSurfaceMuted),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.items});

  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SphereColors.onSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: SphereColors.onSurfaceMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SphereColors.onSurfaceMuted,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SphereColors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
```

---

### Task 6: Wire router — replace stub with `PlayerDetailScreen`

**Files:**
- Modify: `lib/app/router.dart`

**Step 1: Add import at top of router.dart (after existing roster_screen import)**

```dart
import '../features/roster/presentation/player_detail_screen.dart';
```

**Step 2: Replace the stub route body**

Find:
```dart
GoRoute(
  path: '/staff/roster/:id',
  builder: (_, state) {
    final id = state.pathParameters['id']!;
    return Scaffold(
      body: Center(child: Text('Player $id — Phase 4-A2')),
    );
  },
),
```

Replace with:
```dart
GoRoute(
  path: '/staff/roster/:id',
  builder: (_, state) {
    final id = state.pathParameters['id']!;
    return PlayerDetailScreen(playerId: id);
  },
),
```

---

### Task 7: Analyze + full test run

**Step 1: Run analyze**

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile
flutter analyze --no-fatal-infos
```

Expected: No errors.

**Step 2: Run all tests**

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile
flutter test --reporter=compact
```

Expected: 132+ tests PASS.

**Step 3: Final commit**

```bash
git -C /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile \
  add lib/features/roster/presentation/player_detail_screen.dart \
      lib/features/roster/presentation/roster_providers.dart \
      lib/features/roster/presentation/roster_providers.g.dart \
      lib/app/router.dart
git -C /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile \
  commit -m "feat(roster): player detail screen"
```
