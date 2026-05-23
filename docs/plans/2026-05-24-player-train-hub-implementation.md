# Player Train Hub — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign the player Train tab into a 2×2 glassmorphism Performance Hub with four new feature screens: Strength Training, Training Plans, and Recovery + Nutrition.

**Architecture:** Each feature follows the existing pattern — `domain/` models, `data/` repository, `presentation/` screen + Riverpod providers generated via `@riverpod` annotation. All features live under `lib/features/<name>/`. The existing Train screen (`train_screen.dart`) becomes the Skills sub-screen; a new `TrainHubScreen` wraps it in the 2×2 dashboard.

**Tech Stack:** Flutter, Riverpod (riverpod_annotation + build_runner), Firebase Firestore, GoRouter, Lucide icons, Google Fonts (Lexend/Geist), `fl_chart`, `stop_watch_timer`, `wakelock_plus`, `audioplayers`, `cached_network_image`.

---

## Codebase Conventions (read before starting)

- **Theme tokens:** `context.sc.primary`, `context.sc.surfaceElev1`, etc. via `SphereThemeX` extension in `lib/app/theme/sphere_theme_ext.dart`
- **Spacing:** `SphereSpacing.x8/x12/x16/x20/x24/x32` constants
- **Radius:** `SphereRadius.cardRect` (12px), `SphereRadius.pillRect` (999px)
- **Entrance animation:** `SphereEntrance(delayMs: N, child: widget)` in `lib/features/home/presentation/_widgets/sphere_entrance.dart`
- **Section labels:** `SphereSectionLabel('Title')` in `lib/features/home/presentation/_widgets/sphere_section_label.dart`
- **Providers:** Use `@riverpod` annotation, run `flutter pub run build_runner build --delete-conflicting-outputs` after adding any provider file. Generated file goes in same folder with `.g.dart` suffix.
- **Navigation:** `context.push('/route')` to push, `context.go('/route')` for tab switches
- **Firestore instance:** `FirebaseFirestore.instance` — no DI wrapper needed
- **Role check:** `ref.watch(selectedRoleProvider)` returns `AppRole.player` or `AppRole.staff`
- **Active club ID:** `ref.watch(activeClubIdProvider)` from `lib/features/home/data/active_club_repository.dart`

---

## Task 1: Add Required Packages

**Files:**
- Modify: `pubspec.yaml`

**Step 1: Add packages under `dependencies:`**

```yaml
  stop_watch_timer: ^3.1.1
  wakelock_plus: ^1.2.8
  audioplayers: ^6.1.0
  cached_network_image: ^3.4.1
  fl_chart: ^0.70.2
```

**Step 2: Run pub get**

```bash
flutter pub get
```

Expected: resolves without conflicts.

**Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add strength/recovery/chart packages"
```

---

## Task 2: SphereFeatureGridCard Widget

**Files:**
- Create: `lib/features/home/presentation/_widgets/sphere_feature_grid_card.dart`

**Step 1: Create the widget**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/sphere_radius.dart';
import '../../../../app/theme/sphere_spacing.dart';
import '../../../../app/theme/sphere_theme_ext.dart';

class SphereFeatureGridCard extends StatelessWidget {
  const SphereFeatureGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.metricWidget,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? metricWidget;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: ClipRRect(
        borderRadius: SphereRadius.cardRect,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: context.sc.surfaceElev1.withValues(alpha: 0.60),
              borderRadius: SphereRadius.cardRect,
              border: Border(
                top: BorderSide(color: accentColor.withValues(alpha: 0.40), width: 1),
                left: BorderSide(color: accentColor.withValues(alpha: 0.40), width: 1),
                right: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(SphereSpacing.x16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 24, color: accentColor),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.sc.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.geist(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.sc.onSurfaceMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (metricWidget != null) ...[
                  const SizedBox(height: SphereSpacing.x8),
                  metricWidget!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin animated progress bar for grid cards
class SphereGridProgressBar extends StatelessWidget {
  const SphereGridProgressBar({
    super.key,
    required this.value,
    required this.color,
  });

  final double value; // 0.0 – 1.0
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (_, v, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 4,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );
      },
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/home/presentation/_widgets/sphere_feature_grid_card.dart
git commit -m "feat(train): add SphereFeatureGridCard + SphereGridProgressBar widgets"
```

---

## Task 3: Train Hub Screen

**Files:**
- Create: `lib/features/home/presentation/train_hub_screen.dart`
- Modify: `lib/app/router.dart` (update `/train` route to `TrainHubScreen`)

**Step 1: Create TrainHubScreen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '_widgets/sphere_drill_of_day_card.dart';
import '_widgets/sphere_entrance.dart';
import '_widgets/sphere_feature_grid_card.dart';
import '_widgets/sphere_hero_gradient.dart';
import '_widgets/sphere_section_label.dart';
import 'train_providers.dart';

class TrainHubScreen extends ConsumerWidget {
  const TrainHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayDrillProvider);
    final allAsync = ref.watch(allDrillsProvider);
    final drillCount = allAsync.valueOrNull?.length ?? 0;

    return Stack(
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: SphereHeroGradient()),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24,
              SphereSpacing.x16,
              SphereSpacing.x24,
              90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                SphereEntrance(
                  delayMs: 0,
                  child: Text('Train', style: Theme.of(context).textTheme.displayLarge),
                ),
                const SizedBox(height: SphereSpacing.x8),
                SphereEntrance(
                  delayMs: 40,
                  child: Text(
                    'Your performance hub.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
                const SizedBox(height: SphereSpacing.x24),

                // 2x2 Feature Grid
                SphereEntrance(
                  delayMs: 80,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Skills',
                            subtitle: '$drillCount drills available',
                            icon: LucideIcons.target,
                            accentColor: const Color(0xFF37F513),
                            metricWidget: SphereGridProgressBar(
                              value: drillCount > 0 ? 1.0 : 0.0,
                              color: const Color(0xFF37F513),
                            ),
                            onTap: () => context.push('/train/skills'),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Expanded(
                        child: SphereEntrance(
                          delayMs: 140,
                          child: SizedBox(
                            height: 156,
                            child: SphereFeatureGridCard(
                              title: 'Strength',
                              subtitle: 'Gym & conditioning',
                              icon: LucideIcons.dumbbell,
                              accentColor: const Color(0xFFF97316),
                              onTap: () => context.push('/train/strength'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SphereSpacing.x12),

                Row(
                  children: [
                    Expanded(
                      child: SphereEntrance(
                        delayMs: 200,
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Plans',
                            subtitle: 'Coach-assigned programs',
                            icon: LucideIcons.clipboardList,
                            accentColor: const Color(0xFF3B82F6),
                            onTap: () => context.push('/train/plans'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SphereSpacing.x12),
                    Expanded(
                      child: SphereEntrance(
                        delayMs: 260,
                        child: SizedBox(
                          height: 156,
                          child: SphereFeatureGridCard(
                            title: 'Recovery',
                            subtitle: 'Wellness & nutrition',
                            icon: LucideIcons.heartPulse,
                            accentColor: const Color(0xFF8B5CF6),
                            onTap: () => context.push('/train/recovery'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SphereSpacing.x32),

                // Today's Drill (existing)
                const SphereEntrance(
                  delayMs: 300,
                  child: SphereSectionLabel('Today\'s Drill'),
                ),
                const SizedBox(height: SphereSpacing.x16),
                SphereEntrance(
                  delayMs: 340,
                  child: todayAsync.when(
                    data: (drill) => SphereDrillOfDayCard(
                      drillName: drill?.name ?? 'No drill assigned',
                      drillSubtitle: drill == null
                          ? 'Come back tomorrow.'
                          : '5 min · level ${drill.difficulty} ball control',
                      onTap: drill == null
                          ? null
                          : () => context.push('/train/drill/${drill.id}'),
                    ),
                    loading: () => const SphereDrillOfDayCard(
                      drillName: '',
                      drillSubtitle: '',
                      loading: true,
                    ),
                    error: (_, __) => const SphereDrillOfDayCard(
                      drillName: 'Couldn\'t load drill',
                      drillSubtitle: 'Try again later.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

**Step 2: Update router — change `/train` route and add `/train/skills`**

In `lib/app/router.dart`, find:
```dart
import '../features/home/presentation/train_screen.dart';
```
Add below it:
```dart
import '../features/home/presentation/train_hub_screen.dart';
```

Find the route:
```dart
GoRoute(
  path: '/train',
  builder: (_, _) => const TrainScreen(),
),
```
Replace with:
```dart
GoRoute(
  path: '/train',
  builder: (_, _) => const TrainHubScreen(),
),
GoRoute(
  path: '/train/skills',
  builder: (_, _) => const TrainScreen(),
),
```

**Step 3: Commit**

```bash
git add lib/features/home/presentation/train_hub_screen.dart lib/app/router.dart
git commit -m "feat(train): replace TrainScreen with 2x2 TrainHubScreen dashboard"
```

---

## Task 4: Strength — Domain Models

**Files:**
- Create: `lib/features/strength/domain/exercise.dart`
- Create: `lib/features/strength/domain/workout_template.dart`
- Create: `lib/features/strength/domain/workout_log.dart`
- Create: `lib/features/strength/domain/personal_best.dart`

**Step 1: `exercise.dart`**

```dart
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroups,
    required this.equipment,
    this.demonstrationUrl,
    this.videoUrl,
    this.description = '',
    this.defaultSets = 3,
    this.defaultReps = 8,
  });

  final String id;
  final String name;
  final String category; // 'lower_body_power' | 'explosive' | 'injury_prevention' | 'core' | 'mobility'
  final List<String> muscleGroups;
  final String equipment; // 'barbell' | 'bodyweight' | 'dumbbell' | 'resistance_band'
  final String? demonstrationUrl;
  final String? videoUrl;
  final String description;
  final int defaultSets;
  final int defaultReps;

  factory Exercise.fromMap(String id, Map<String, dynamic> d) => Exercise(
        id: id,
        name: (d['name'] as String?) ?? 'Exercise',
        category: (d['category'] as String?) ?? '',
        muscleGroups: ((d['muscleGroups'] as List?)?.cast<String>()) ?? [],
        equipment: (d['equipment'] as String?) ?? 'bodyweight',
        demonstrationUrl: d['demonstrationUrl'] as String?,
        videoUrl: d['videoUrl'] as String?,
        description: (d['description'] as String?) ?? '',
        defaultSets: (d['defaultSets'] as int?) ?? 3,
        defaultReps: (d['defaultReps'] as int?) ?? 8,
      );
}
```

**Step 2: `workout_template.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateExercise {
  const TemplateExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    this.weightKg,
    this.restSeconds = 90,
    this.notes,
  });

  final String exerciseId;
  final int sets;
  final int reps;
  final double? weightKg;
  final int restSeconds;
  final String? notes;

  factory TemplateExercise.fromMap(Map<String, dynamic> d) => TemplateExercise(
        exerciseId: d['exerciseId'] as String,
        sets: (d['sets'] as int?) ?? 3,
        reps: (d['reps'] as int?) ?? 8,
        weightKg: (d['weightKg'] as num?)?.toDouble(),
        restSeconds: (d['restSeconds'] as int?) ?? 90,
        notes: d['notes'] as String?,
      );
}

class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.title,
    required this.estimatedMinutes,
    required this.exercises,
    this.dueDate,
    this.notes,
  });

  final String id;
  final String title;
  final int estimatedMinutes;
  final List<TemplateExercise> exercises;
  final DateTime? dueDate;
  final String? notes;

  factory WorkoutTemplate.fromDoc(String id, Map<String, dynamic> d) {
    final rawExercises = (d['exercises'] as List?) ?? [];
    return WorkoutTemplate(
      id: id,
      title: (d['title'] as String?) ?? 'Workout',
      estimatedMinutes: (d['estimatedMinutes'] as int?) ?? 45,
      exercises: rawExercises
          .cast<Map<String, dynamic>>()
          .map(TemplateExercise.fromMap)
          .toList(),
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      notes: d['notes'] as String?,
    );
  }
}
```

**Step 3: `workout_log.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedSet {
  const LoggedSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.rpe,
  });

  final int setNumber;
  final int reps;
  final double weightKg;
  final int? rpe;

  Map<String, dynamic> toMap() => {
        'setNumber': setNumber,
        'reps': reps,
        'weightKg': weightKg,
        if (rpe != null) 'rpe': rpe,
        'completedAt': FieldValue.serverTimestamp(),
      };
}

class LoggedExercise {
  const LoggedExercise({required this.exerciseId, required this.sets});
  final String exerciseId;
  final List<LoggedSet> sets;

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'sets': sets.map((s) => s.toMap()).toList(),
      };
}

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.templateId,
    required this.startedAt,
    required this.completedAt,
    required this.exercises,
    required this.totalVolumeKg,
  });

  final String id;
  final String? templateId;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<LoggedExercise> exercises;
  final double totalVolumeKg;
}
```

**Step 4: `personal_best.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalBest {
  const PersonalBest({
    required this.exerciseId,
    required this.bestWeightKg,
    required this.bestReps,
    required this.bestVolumeKg,
    required this.achievedAt,
  });

  final String exerciseId;
  final double bestWeightKg;
  final int bestReps;
  final double bestVolumeKg;
  final DateTime achievedAt;

  factory PersonalBest.fromDoc(String id, Map<String, dynamic> d) => PersonalBest(
        exerciseId: id,
        bestWeightKg: (d['bestWeightKg'] as num?)?.toDouble() ?? 0,
        bestReps: (d['bestReps'] as int?) ?? 0,
        bestVolumeKg: (d['bestVolumeKg'] as num?)?.toDouble() ?? 0,
        achievedAt: (d['achievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
```

**Step 5: Commit**

```bash
git add lib/features/strength/
git commit -m "feat(strength): add domain models (Exercise, WorkoutTemplate, WorkoutLog, PersonalBest)"
```

---

## Task 5: Strength — Repository

**Files:**
- Create: `lib/features/strength/data/strength_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/exercise.dart';
import '../domain/personal_best.dart';
import '../domain/workout_log.dart';
import '../domain/workout_template.dart';

class StrengthRepository {
  StrengthRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  // Returns assigned templates for this player in this club
  Stream<List<WorkoutTemplate>> assignedTemplatesStream({
    required String clubId,
    required String playerId,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('workoutTemplates')
        .where('assignedPlayerIds', arrayContains: playerId)
        .limit(20)
        .snapshots()
        .map((s) => s.docs
            .map((d) => WorkoutTemplate.fromDoc(d.id, d.data()))
            .toList());
  }

  Stream<List<Exercise>> exercisesStream() {
    return _db
        .collection('exercises')
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => Exercise.fromMap(d.id, d.data())).toList());
  }

  Future<Exercise?> exerciseById(String id) async {
    final doc = await _db.collection('exercises').doc(id).get();
    if (!doc.exists) return null;
    return Exercise.fromMap(doc.id, doc.data()!);
  }

  Future<String> saveWorkoutLog({
    required String userId,
    required String? templateId,
    required String clubId,
    required DateTime startedAt,
    required DateTime completedAt,
    required List<LoggedExercise> exercises,
  }) async {
    double totalVolume = 0;
    for (final ex in exercises) {
      for (final s in ex.sets) {
        totalVolume += s.sets * s.reps * s.weightKg;
      }
    }

    final ref = _db.collection('users').doc(userId).collection('workoutLogs').doc();
    await ref.set({
      'templateId': templateId,
      'clubId': clubId,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'totalVolumeKg': totalVolume,
      'exercises': exercises.map((e) => e.toMap()).toList(),
    });
    return ref.id;
  }

  Stream<PersonalBest?> personalBestStream({
    required String userId,
    required String exerciseId,
  }) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('personalBests')
        .doc(exerciseId)
        .snapshots()
        .map((d) => d.exists ? PersonalBest.fromDoc(d.id, d.data()!) : null);
  }
}
```

**Note:** The `totalVolume` computation loop has a bug — `s.sets` doesn't exist on `LoggedSet`. Fix: iterate `ex.sets` which are `LoggedSet` objects; volume per set = `s.reps * s.weightKg`. Replace the volume block with:

```dart
    for (final ex in exercises) {
      for (final s in ex.sets) {
        totalVolume += s.reps * s.weightKg;
      }
    }
```

**Commit:**

```bash
git add lib/features/strength/data/strength_repository.dart
git commit -m "feat(strength): add StrengthRepository"
```

---

## Task 6: Strength — Providers + Screen

**Files:**
- Create: `lib/features/strength/presentation/strength_providers.dart`
- Create: `lib/features/strength/presentation/strength_providers.g.dart` ← generated, don't create manually
- Create: `lib/features/strength/presentation/strength_screen.dart`

**Step 1: `strength_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../home/data/active_club_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/strength_repository.dart';
import '../domain/workout_template.dart';

part 'strength_providers.g.dart';

@riverpod
StrengthRepository strengthRepository(StrengthRepositoryRef ref) =>
    StrengthRepository();

@riverpod
Stream<List<WorkoutTemplate>> assignedWorkouts(AssignedWorkoutsRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (clubId == null || uid == null) return const Stream.empty();
  return ref
      .watch(strengthRepositoryProvider)
      .assignedTemplatesStream(clubId: clubId, playerId: uid);
}
```

**Step 2: `strength_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import 'strength_providers.dart';

class StrengthScreen extends ConsumerWidget {
  const StrengthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(assignedWorkoutsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Strength',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24, SphereSpacing.x8,
            SphereSpacing.x24, 90,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel('Assigned by Coach'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 80,
                child: workoutsAsync.when(
                  data: (templates) {
                    if (templates.isEmpty) {
                      return _EmptyState();
                    }
                    return Column(
                      children: [
                        for (final t in templates)
                          _WorkoutCard(template: t),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Text(
                    'Couldn\'t load workouts.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.template});
  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SphereSpacing.x12),
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${template.exercises.length} exercises · Est. ${template.estimatedMinutes} min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: SphereSpacing.x16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  context.push('/train/strength/workout/${template.id}'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: SphereRadius.pillRect,
                ),
              ),
              child: const Text('Start Workout'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x24),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.dumbbell, size: 32, color: context.sc.onSurfaceMuted),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            'No workouts assigned yet.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your coach will assign programs here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
```

**Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 4: Commit**

```bash
git add lib/features/strength/
git commit -m "feat(strength): add StrengthScreen with assigned workout list"
```

---

## Task 7: Active Workout Screen

**Files:**
- Create: `lib/features/strength/presentation/active_workout_screen.dart`
- Create: `lib/features/strength/presentation/active_workout_providers.dart`
- Modify: `lib/app/router.dart` — add `/train/strength/workout/:id` and `/train/strength`

**Step 1: `active_workout_providers.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ActiveWorkoutState {
  const ActiveWorkoutState({
    this.currentExerciseIndex = 0,
    this.sets = const [],
    this.isResting = false,
    this.restSecondsLeft = 0,
  });

  final int currentExerciseIndex;
  final List<Map<String, dynamic>> sets; // [{exerciseId, reps, weightKg}]
  final bool isResting;
  final int restSecondsLeft;

  ActiveWorkoutState copyWith({
    int? currentExerciseIndex,
    List<Map<String, dynamic>>? sets,
    bool? isResting,
    int? restSecondsLeft,
  }) =>
      ActiveWorkoutState(
        currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
        sets: sets ?? this.sets,
        isResting: isResting ?? this.isResting,
        restSecondsLeft: restSecondsLeft ?? this.restSecondsLeft,
      );
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  ActiveWorkoutNotifier() : super(const ActiveWorkoutState());

  void logSet({required String exerciseId, required int reps, required double weightKg}) {
    final newSet = {'exerciseId': exerciseId, 'reps': reps, 'weightKg': weightKg};
    state = state.copyWith(sets: [...state.sets, newSet]);
  }

  void nextExercise() {
    state = state.copyWith(
      currentExerciseIndex: state.currentExerciseIndex + 1,
    );
  }

  void startRest(int seconds) {
    state = state.copyWith(isResting: true, restSecondsLeft: seconds);
  }

  void endRest() {
    state = state.copyWith(isResting: false, restSecondsLeft: 0);
  }

  void tickRest() {
    if (state.restSecondsLeft > 0) {
      state = state.copyWith(restSecondsLeft: state.restSecondsLeft - 1);
    } else {
      endRest();
    }
  }
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>(
  (_) => ActiveWorkoutNotifier(),
);
```

**Step 2: `active_workout_screen.dart`**

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../domain/workout_template.dart';
import 'active_workout_providers.dart';
import 'strength_providers.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key, required this.templateId});
  final String templateId;

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  Timer? _restTimer;
  final _repsController = TextEditingController(text: '8');
  final _weightController = TextEditingController(text: '0');
  late final DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    WakelockPlus.disable();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    ref.read(activeWorkoutProvider.notifier).startRest(seconds);
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(activeWorkoutProvider);
      if (state.restSecondsLeft <= 1) {
        _restTimer?.cancel();
        ref.read(activeWorkoutProvider.notifier).endRest();
        HapticFeedback.heavyImpact();
      } else {
        ref.read(activeWorkoutProvider.notifier).tickRest();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // In a real implementation, fetch the template from Firestore via provider.
    // For now show a placeholder that can be wired up.
    final workoutState = ref.watch(activeWorkoutProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Active Workout',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rest timer overlay
              if (workoutState.isResting)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SphereSpacing.x20),
                  margin: const EdgeInsets.only(bottom: SphereSpacing.x24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.12),
                    borderRadius: SphereRadius.cardRect,
                    border: Border.all(
                      color: const Color(0xFFF97316).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Rest',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFFF97316),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${workoutState.restSecondsLeft}s',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: const Color(0xFFF97316),
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          _restTimer?.cancel();
                          ref.read(activeWorkoutProvider.notifier).endRest();
                        },
                        child: const Text('Skip rest'),
                      ),
                    ],
                  ),
                ),

              // Log a set
              Text(
                'Log Set',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: SphereSpacing.x16),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      label: 'Reps',
                      controller: _repsController,
                    ),
                  ),
                  const SizedBox(width: SphereSpacing.x12),
                  Expanded(
                    child: _NumberField(
                      label: 'Weight (kg)',
                      controller: _weightController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SphereSpacing.x16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final reps = int.tryParse(_repsController.text) ?? 0;
                    final weight = double.tryParse(_weightController.text) ?? 0;
                    ref.read(activeWorkoutProvider.notifier).logSet(
                          exerciseId: widget.templateId,
                          reps: reps,
                          weightKg: weight,
                        );
                    HapticFeedback.mediumImpact();
                    _startRestTimer(90);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    shape: RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Log Set + Start Rest'),
                ),
              ),
              const SizedBox(height: SphereSpacing.x24),

              // Logged sets
              if (workoutState.sets.isNotEmpty) ...[
                Text(
                  '${workoutState.sets.length} sets logged',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.sc.onSurfaceMuted,
              ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.sc.surfaceElev1,
            border: OutlineInputBorder(
              borderRadius: SphereRadius.cardRect,
              borderSide: BorderSide(color: context.sc.borderSubtle),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
```

**Step 3: Add routes to `lib/app/router.dart`**

Add these imports:
```dart
import '../features/strength/presentation/strength_screen.dart';
import '../features/strength/presentation/active_workout_screen.dart';
```

Add these routes inside the `ShellRoute` routes list (after `/train/skills`):
```dart
GoRoute(
  path: '/train/strength',
  builder: (_, _) => const StrengthScreen(),
),
GoRoute(
  path: '/train/strength/workout/:id',
  builder: (_, state) {
    final id = state.pathParameters['id']!;
    return ActiveWorkoutScreen(templateId: id);
  },
),
```

**Step 4: Commit**

```bash
git add lib/features/strength/ lib/app/router.dart
git commit -m "feat(strength): add ActiveWorkoutScreen with rest timer and set logger"
```

---

## Task 8: Training Plans — Domain Models + Repository

**Files:**
- Create: `lib/features/training_plans/domain/training_plan.dart`
- Create: `lib/features/training_plans/data/training_plans_repository.dart`

**Step 1: `training_plan.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum PlanFocus { technical, tactical, physical, rest }

extension PlanFocusX on PlanFocus {
  String get label {
    switch (this) {
      case PlanFocus.technical: return 'Technical';
      case PlanFocus.tactical:  return 'Tactical';
      case PlanFocus.physical:  return 'Physical';
      case PlanFocus.rest:      return 'Rest';
    }
  }

  // Matches design doc focus colors
  static const _colors = {
    PlanFocus.technical: 0xFF37F513,
    PlanFocus.tactical:  0xFF3B82F6,
    PlanFocus.physical:  0xFFF97316,
    PlanFocus.rest:      0xFF64748B,
  };
  int get colorValue => _colors[this]!;
}

class PlanSession {
  const PlanSession({
    required this.id,
    required this.title,
    required this.dayOfWeek,
    required this.durationMinutes,
    required this.focus,
    this.notes,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final int dayOfWeek; // 1=Mon … 7=Sun
  final int durationMinutes;
  final PlanFocus focus;
  final String? notes;
  final bool isCompleted;

  factory PlanSession.fromDoc(String id, Map<String, dynamic> d) {
    PlanFocus focus;
    switch (d['focus'] as String? ?? '') {
      case 'tactical':  focus = PlanFocus.tactical; break;
      case 'physical':  focus = PlanFocus.physical; break;
      case 'rest':      focus = PlanFocus.rest; break;
      default:          focus = PlanFocus.technical;
    }
    return PlanSession(
      id: id,
      title: (d['title'] as String?) ?? 'Session',
      dayOfWeek: (d['dayOfWeek'] as int?) ?? 1,
      durationMinutes: (d['durationMinutes'] as int?) ?? 60,
      focus: focus,
      notes: d['notes'] as String?,
    );
  }
}

class PlanWeek {
  const PlanWeek({
    required this.id,
    required this.weekNumber,
    required this.theme,
    required this.sessions,
  });

  final String id;
  final int weekNumber;
  final String theme;
  final List<PlanSession> sessions;
}

class TrainingPlan {
  const TrainingPlan({
    required this.id,
    required this.title,
    required this.totalWeeks,
    required this.currentWeek,
    required this.phase,
    this.description = '',
  });

  final String id;
  final String title;
  final int totalWeeks;
  final int currentWeek;
  final String phase; // 'preseason' | 'inseason' | 'offseason'
  final String description;

  factory TrainingPlan.fromDoc(String id, Map<String, dynamic> d) => TrainingPlan(
        id: id,
        title: (d['title'] as String?) ?? 'Training Plan',
        totalWeeks: (d['totalWeeks'] as int?) ?? 6,
        currentWeek: (d['currentWeek'] as int?) ?? 1,
        phase: (d['phase'] as String?) ?? 'inseason',
        description: (d['description'] as String?) ?? '',
      );
}
```

**Step 2: `training_plans_repository.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/training_plan.dart';

class TrainingPlansRepository {
  TrainingPlansRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<TrainingPlan>> assignedPlansStream({
    required String clubId,
    required String playerId,
  }) {
    return _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .where('assignedPlayerIds', arrayContains: playerId)
        .where('status', isEqualTo: 'active')
        .limit(10)
        .snapshots()
        .map((s) => s.docs
            .map((d) => TrainingPlan.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<List<PlanWeek>> weeksForPlan({
    required String clubId,
    required String planId,
  }) async {
    final snap = await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .collection('weeks')
        .orderBy('weekNumber')
        .get();

    final weeks = <PlanWeek>[];
    for (final weekDoc in snap.docs) {
      final sessionsSnap = await weekDoc.reference
          .collection('sessions')
          .orderBy('dayOfWeek')
          .get();
      final sessions = sessionsSnap.docs
          .map((d) => PlanSession.fromDoc(d.id, d.data()))
          .toList();
      final data = weekDoc.data();
      weeks.add(PlanWeek(
        id: weekDoc.id,
        weekNumber: (data['weekNumber'] as int?) ?? 1,
        theme: (data['theme'] as String?) ?? '',
        sessions: sessions,
      ));
    }
    return weeks;
  }

  Future<void> markSessionComplete({
    required String clubId,
    required String planId,
    required String weekId,
    required String sessionId,
    required String playerId,
    int selfRating = 3,
  }) async {
    await _db
        .collection('clubs')
        .doc(clubId)
        .collection('training_plans')
        .doc(planId)
        .collection('weeks')
        .doc(weekId)
        .collection('sessions')
        .doc(sessionId)
        .collection('completions')
        .doc(playerId)
        .set({
      'completedAt': FieldValue.serverTimestamp(),
      'selfRating': selfRating,
    });
  }
}
```

**Step 3: Commit**

```bash
git add lib/features/training_plans/
git commit -m "feat(plans): add TrainingPlan domain models and TrainingPlansRepository"
```

---

## Task 9: Training Plans — Providers + Screen

**Files:**
- Create: `lib/features/training_plans/presentation/training_plans_providers.dart`
- Create: `lib/features/training_plans/presentation/plans_screen.dart`
- Create: `lib/features/training_plans/presentation/plan_detail_screen.dart`
- Modify: `lib/app/router.dart`

**Step 1: `training_plans_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../home/data/active_club_repository.dart';
import '../data/training_plans_repository.dart';
import '../domain/training_plan.dart';

part 'training_plans_providers.g.dart';

@riverpod
TrainingPlansRepository trainingPlansRepository(TrainingPlansRepositoryRef ref) =>
    TrainingPlansRepository();

@riverpod
Stream<List<TrainingPlan>> assignedPlans(AssignedPlansRef ref) {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (clubId == null || uid == null) return const Stream.empty();
  return ref
      .watch(trainingPlansRepositoryProvider)
      .assignedPlansStream(clubId: clubId, playerId: uid);
}

@riverpod
Future<List<PlanWeek>> planWeeks(PlanWeeksRef ref, String planId) async {
  final clubId = ref.watch(activeClubIdProvider).valueOrNull;
  if (clubId == null) return [];
  return ref
      .watch(trainingPlansRepositoryProvider)
      .weeksForPlan(clubId: clubId, planId: planId);
}
```

**Step 2: `plans_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/training_plan.dart';
import 'training_plans_providers.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(assignedPlansProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Training Plans',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24, SphereSpacing.x8,
            SphereSpacing.x24, 90,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SphereEntrance(
                delayMs: 0,
                child: SphereSectionLabel('Active Plans'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 80,
                child: plansAsync.when(
                  data: (plans) {
                    if (plans.isEmpty) {
                      return _EmptyState();
                    }
                    return Column(
                      children: plans
                          .map((p) => _PlanCard(plan: p))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Text(
                    'Couldn\'t load plans.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});
  final TrainingPlan plan;

  @override
  Widget build(BuildContext context) {
    final progress = plan.currentWeek / plan.totalWeeks;

    return GestureDetector(
      onTap: () => context.push('/train/plans/${plan.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: SphereSpacing.x12),
        padding: const EdgeInsets.all(SphereSpacing.x20),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    plan.phase.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B82F6),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SphereSpacing.x8),
            // Week strip
            _WeekStrip(current: plan.currentWeek, total: plan.totalWeeks),
            const SizedBox(height: SphereSpacing.x12),
            Text(
              'Week ${plan.currentWeek} of ${plan.totalWeeks}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.sc.onSurfaceMuted,
                  ),
            ),
            const SizedBox(height: SphereSpacing.x8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  minHeight: 4,
                  backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(total, (i) {
          final weekNum = i + 1;
          final isDone = weekNum < current;
          final isCurrent = weekNum == current;
          return Container(
            margin: const EdgeInsets.only(right: 6),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? const Color(0xFF3B82F6)
                  : isCurrent
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                      : context.sc.surfaceElev2,
              border: isCurrent
                  ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                  : null,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '$weekNum',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? const Color(0xFF3B82F6)
                            : context.sc.onSurfaceMuted,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x24),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.clipboardList, size: 32, color: context.sc.onSurfaceMuted),
          const SizedBox(height: SphereSpacing.x12),
          Text(
            'No plans assigned yet.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your coach will assign training programs here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ],
      ),
    );
  }
}
```

**Step 3: `plan_detail_screen.dart`** (basic — weeks + sessions list)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../domain/training_plan.dart';
import 'training_plans_providers.dart';

class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeksAsync = ref.watch(planWeeksProvider(planId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Plan Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: weeksAsync.when(
          data: (weeks) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24, SphereSpacing.x8,
              SphereSpacing.x24, 90,
            ),
            itemCount: weeks.length,
            itemBuilder: (context, i) => _WeekSection(week: weeks[i]),
          ),
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (e, _) => Center(
            child: Text('Couldn\'t load plan.',
              style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ),
    );
  }
}

class _WeekSection extends StatelessWidget {
  const _WeekSection({required this.week});
  final PlanWeek week;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: SphereSpacing.x12),
          child: Text(
            'Week ${week.weekNumber}${week.theme.isNotEmpty ? ' · ${week.theme}' : ''}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.sc.onSurfaceMuted,
                ),
          ),
        ),
        for (final session in week.sessions) _SessionRow(session: session),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({required this.session});
  final PlanSession session;

  static const _days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final color = Color(session.focus.colorValue);
    return Container(
      margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
      padding: const EdgeInsets.all(SphereSpacing.x16),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: SphereSpacing.x12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${_days[session.dayOfWeek]} · ${session.focus.label} · ${session.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ],
            ),
          ),
          if (session.isCompleted)
            Icon(Icons.check_circle, color: const Color(0xFF37F513), size: 20)
          else
            Icon(LucideIcons.circle, color: context.sc.onSurfaceMuted, size: 20),
        ],
      ),
    );
  }
}
```

**Step 4: Add routes to router**

Add imports:
```dart
import '../features/training_plans/presentation/plans_screen.dart';
import '../features/training_plans/presentation/plan_detail_screen.dart';
```

Add routes inside ShellRoute:
```dart
GoRoute(
  path: '/train/plans',
  builder: (_, _) => const PlansScreen(),
),
GoRoute(
  path: '/train/plans/:planId',
  builder: (_, state) {
    final id = state.pathParameters['planId']!;
    return PlanDetailScreen(planId: id);
  },
),
```

**Step 5: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 6: Commit**

```bash
git add lib/features/training_plans/ lib/app/router.dart
git commit -m "feat(plans): add PlansScreen, PlanDetailScreen, providers and routes"
```

---

## Task 10: Recovery — Domain Models + Repository

**Files:**
- Create: `lib/features/recovery/domain/recovery_log.dart`
- Create: `lib/features/recovery/domain/recovery_content.dart`
- Create: `lib/features/recovery/data/recovery_repository.dart`

**Step 1: `recovery_log.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RecoveryLog {
  const RecoveryLog({
    required this.id,
    required this.date,
    required this.dateStr,
    required this.fatigue,
    required this.sleepQuality,
    required this.muscleSoreness,
    required this.stress,
    required this.mood,
    required this.wellnessScore,
    this.soreSites = const [],
    this.notes,
  });

  final String id;
  final DateTime date;
  final String dateStr; // 'YYYY-MM-DD'
  final int fatigue;       // 1–7 (Hooper Index)
  final int sleepQuality;  // 1–7
  final int muscleSoreness; // 1–7
  final int stress;        // 1–7
  final int mood;          // 1–7
  final int wellnessScore; // 0–100, computed: 100 - ((sum-5)/30*100)
  final List<String> soreSites;
  final String? notes;

  /// Hooper Index composite. Lower raw = better.
  static int computeScore(int fatigue, int sleep, int soreness, int stress, int mood) {
    final sum = fatigue + sleep + soreness + stress + mood;
    return (100 - ((sum - 5) / 30 * 100)).round().clamp(0, 100);
  }

  factory RecoveryLog.fromDoc(String id, Map<String, dynamic> d) => RecoveryLog(
        id: id,
        date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        dateStr: (d['dateStr'] as String?) ?? '',
        fatigue: (d['fatigue'] as int?) ?? 4,
        sleepQuality: (d['sleepQuality'] as int?) ?? 4,
        muscleSoreness: (d['muscleSoreness'] as int?) ?? 4,
        stress: (d['stress'] as int?) ?? 4,
        mood: (d['mood'] as int?) ?? 4,
        wellnessScore: (d['wellnessScore'] as int?) ?? 50,
        soreSites: ((d['soreSites'] as List?)?.cast<String>()) ?? [],
        notes: d['notes'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'date': Timestamp.fromDate(date),
        'dateStr': dateStr,
        'fatigue': fatigue,
        'sleepQuality': sleepQuality,
        'muscleSoreness': muscleSoreness,
        'stress': stress,
        'mood': mood,
        'wellnessScore': wellnessScore,
        'soreSites': soreSites,
        if (notes != null) 'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
```

**Step 2: `recovery_content.dart`**

```dart
class RecoveryContent {
  const RecoveryContent({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.steps,
    this.thumbnailUrl,
    this.youtubeUrl,
    this.evidenceLevel = 'moderate',
    this.sportContext = 'general',
  });

  final String id;
  final String title;
  final String category; // 'stretching' | 'foam_rolling' | 'cold_therapy' | 'nutrition' | 'sleep' | 'active_recovery'
  final int durationMinutes;
  final List<String> steps;
  final String? thumbnailUrl;
  final String? youtubeUrl;
  final String evidenceLevel; // 'strong' | 'moderate' | 'emerging'
  final String sportContext;  // 'futsal' | 'football' | 'general'

  factory RecoveryContent.fromDoc(String id, Map<String, dynamic> d) => RecoveryContent(
        id: id,
        title: (d['title'] as String?) ?? 'Recovery',
        category: (d['category'] as String?) ?? 'stretching',
        durationMinutes: (d['durationMinutes'] as int?) ?? 10,
        steps: ((d['steps'] as List?)?.cast<String>()) ?? [],
        thumbnailUrl: d['thumbnailUrl'] as String?,
        youtubeUrl: d['youtubeUrl'] as String?,
        evidenceLevel: (d['evidenceLevel'] as String?) ?? 'moderate',
        sportContext: (d['sportContext'] as String?) ?? 'general',
      );
}
```

**Step 3: `recovery_repository.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/recovery_content.dart';
import '../domain/recovery_log.dart';

class RecoveryRepository {
  RecoveryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<RecoveryLog?> todayLogStream(String userId) {
    final today = _todayStr();
    return _db
        .collection('users')
        .doc(userId)
        .collection('recovery_logs')
        .where('dateStr', isEqualTo: today)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty
            ? null
            : RecoveryLog.fromDoc(s.docs.first.id, s.docs.first.data()));
  }

  Stream<List<RecoveryLog>> recentLogsStream(String userId, {int days = 14}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _db
        .collection('users')
        .doc(userId)
        .collection('recovery_logs')
        .where('date', isGreaterThan: Timestamp.fromDate(cutoff))
        .orderBy('date', descending: true)
        .limit(days)
        .snapshots()
        .map((s) => s.docs
            .map((d) => RecoveryLog.fromDoc(d.id, d.data()))
            .toList());
  }

  Future<void> saveLog(String userId, RecoveryLog log) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('recovery_logs')
        .add(log.toMap());
  }

  Stream<List<RecoveryContent>> contentStream({String? category}) {
    Query<Map<String, dynamic>> q = _db
        .collection('recovery_content')
        .where('isActive', isEqualTo: true)
        .limit(50);
    if (category != null) q = q.where('category', isEqualTo: category);
    return q
        .orderBy('sortOrder')
        .snapshots()
        .map((s) => s.docs
            .map((d) => RecoveryContent.fromDoc(d.id, d.data()))
            .toList());
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
```

**Step 4: Commit**

```bash
git add lib/features/recovery/
git commit -m "feat(recovery): add domain models and RecoveryRepository"
```

---

## Task 11: Recovery — Providers + Screens

**Files:**
- Create: `lib/features/recovery/presentation/recovery_providers.dart`
- Create: `lib/features/recovery/presentation/recovery_screen.dart`
- Create: `lib/features/recovery/presentation/wellness_checkin_screen.dart`
- Create: `lib/features/recovery/presentation/recovery_content_detail_screen.dart`
- Modify: `lib/app/router.dart`

**Step 1: `recovery_providers.dart`**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/recovery_repository.dart';
import '../domain/recovery_content.dart';
import '../domain/recovery_log.dart';

part 'recovery_providers.g.dart';

@riverpod
RecoveryRepository recoveryRepository(RecoveryRepositoryRef ref) =>
    RecoveryRepository();

@riverpod
Stream<RecoveryLog?> todayRecoveryLog(TodayRecoveryLogRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(recoveryRepositoryProvider).todayLogStream(uid);
}

@riverpod
Stream<List<RecoveryLog>> recentRecoveryLogs(RecentRecoveryLogsRef ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(recoveryRepositoryProvider).recentLogsStream(uid);
}

@riverpod
Stream<List<RecoveryContent>> recoveryContent(RecoveryContentRef ref) {
  return ref.watch(recoveryRepositoryProvider).contentStream();
}

@riverpod
Stream<List<RecoveryContent>> nutritionContent(NutritionContentRef ref) {
  return ref
      .watch(recoveryRepositoryProvider)
      .contentStream(category: 'nutrition');
}
```

**Step 2: `recovery_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../home/presentation/_widgets/sphere_entrance.dart';
import '../../home/presentation/_widgets/sphere_section_label.dart';
import '../domain/recovery_content.dart';
import '../domain/recovery_log.dart';
import 'recovery_providers.dart';

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayRecoveryLogProvider);
    final contentAsync = ref.watch(recoveryContentProvider);
    final nutritionAsync = ref.watch(nutritionContentProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Recovery & Nutrition',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SphereSpacing.x24, SphereSpacing.x8,
            SphereSpacing.x24, 90,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PDPA disclaimer
              const _Disclaimer(),
              const SizedBox(height: SphereSpacing.x16),

              // Wellness card
              SphereEntrance(
                delayMs: 0,
                child: todayLog.when(
                  data: (log) => _WellnessCard(log: log),
                  loading: () => const _WellnessCard(log: null, loading: true),
                  error: (_, __) => const _WellnessCard(log: null),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),

              // Recovery content
              const SphereEntrance(
                delayMs: 80,
                child: SphereSectionLabel('Recovery'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 120,
                child: contentAsync.when(
                  data: (items) => _ContentList(items: items),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),

              // Nutrition content
              const SphereEntrance(
                delayMs: 160,
                child: SphereSectionLabel('Nutrition'),
              ),
              const SizedBox(height: SphereSpacing.x16),
              SphereEntrance(
                delayMs: 200,
                child: nutritionAsync.when(
                  data: (items) => _ContentList(items: items),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WellnessCard extends StatelessWidget {
  const _WellnessCard({this.log, this.loading = false});
  final RecoveryLog? log;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.all(SphereSpacing.x20),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : log == null
              ? _LogCta(context: context)
              : _ScoreDisplay(log: log!, accent: accent),
    );
  }
}

class _LogCta extends StatelessWidget {
  const _LogCta({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        const Icon(LucideIcons.heartPulse, color: Color(0xFF8B5CF6), size: 24),
        const SizedBox(width: SphereSpacing.x12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you feeling today?',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                'Log your daily wellness',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: ctx.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => ctx.push('/train/recovery/check-in'),
          child: const Text('Log', style: TextStyle(color: Color(0xFF8B5CF6))),
        ),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({required this.log, required this.accent});
  final RecoveryLog log;
  final Color accent;

  Color _scoreColor() {
    if (log.wellnessScore >= 70) return const Color(0xFF37F513);
    if (log.wellnessScore >= 50) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${log.wellnessScore}%',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: _scoreColor(),
              ),
        ),
        const SizedBox(width: SphereSpacing.x16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wellness score',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Logged today',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentList extends StatelessWidget {
  const _ContentList({required this.items});
  final List<RecoveryContent> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'Content coming soon.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.sc.onSurfaceMuted,
            ),
      );
    }
    return Column(
      children: items.map((item) => _ContentRow(item: item)).toList(),
    );
  }
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.item});
  final RecoveryContent item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/train/recovery/content/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: SphereSpacing.x8),
        padding: const EdgeInsets.all(SphereSpacing.x16),
        decoration: BoxDecoration(
          color: context.sc.surfaceElev1,
          borderRadius: SphereRadius.cardRect,
          border: Border.all(color: context.sc.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${item.durationMinutes} min · ${item.evidenceLevel} evidence',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.sc.onSurfaceMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: context.sc.onSurfaceMuted),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SphereSpacing.x12,
        vertical: SphereSpacing.x8,
      ),
      decoration: BoxDecoration(
        color: context.sc.surfaceElev1,
        borderRadius: SphereRadius.cardRect,
        border: Border.all(color: context.sc.borderSubtle),
      ),
      child: Text(
        'For general sporting guidance only. Not a substitute for advice from a qualified sports dietitian or medical professional.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.sc.onSurfaceMuted,
              fontSize: 10,
            ),
      ),
    );
  }
}
```

**Step 3: `wellness_checkin_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../../auth/presentation/auth_providers.dart';
import '../data/recovery_repository.dart';
import '../domain/recovery_log.dart';
import 'recovery_providers.dart';

class WellnessCheckInScreen extends ConsumerStatefulWidget {
  const WellnessCheckInScreen({super.key});

  @override
  ConsumerState<WellnessCheckInScreen> createState() =>
      _WellnessCheckInScreenState();
}

class _WellnessCheckInScreenState
    extends ConsumerState<WellnessCheckInScreen> {
  // Hooper Index — 1=best, 7=worst for all five
  double _fatigue = 4;
  double _sleep = 4;
  double _soreness = 4;
  double _stress = 4;
  double _mood = 4;
  bool _saving = false;

  int get _score => RecoveryLog.computeScore(
        _fatigue.round(),
        _sleep.round(),
        _soreness.round(),
        _stress.round(),
        _mood.round(),
      );

  Color get _scoreColor {
    if (_score >= 70) return const Color(0xFF37F513);
    if (_score >= 50) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final log = RecoveryLog(
      id: '',
      date: now,
      dateStr: dateStr,
      fatigue: _fatigue.round(),
      sleepQuality: _sleep.round(),
      muscleSoreness: _soreness.round(),
      stress: _stress.round(),
      mood: _mood.round(),
      wellnessScore: _score,
    );

    await ref.read(recoveryRepositoryProvider).saveLog(uid, log);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Daily Wellness',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SphereSpacing.x24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live score preview
              Center(
                child: Text(
                  '$_score%',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _scoreColor,
                      ),
                ),
              ),
              Center(
                child: Text(
                  'Wellness score',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
              ),
              const SizedBox(height: SphereSpacing.x32),

              // Sliders
              _HooperSlider(
                label: 'Sleep Quality',
                description: '1 = very restful · 7 = insomnia',
                value: _sleep,
                onChanged: (v) => setState(() => _sleep = v),
              ),
              _HooperSlider(
                label: 'Fatigue',
                description: '1 = very fresh · 7 = very tired',
                value: _fatigue,
                onChanged: (v) => setState(() => _fatigue = v),
              ),
              _HooperSlider(
                label: 'Muscle Soreness',
                description: '1 = no soreness · 7 = very sore',
                value: _soreness,
                onChanged: (v) => setState(() => _soreness = v),
              ),
              _HooperSlider(
                label: 'Stress',
                description: '1 = very relaxed · 7 = highly stressed',
                value: _stress,
                onChanged: (v) => setState(() => _stress = v),
              ),
              _HooperSlider(
                label: 'Mood',
                description: '1 = very positive · 7 = highly irritable',
                value: _mood,
                onChanged: (v) => setState(() => _mood = v),
              ),

              const SizedBox(height: SphereSpacing.x24),

              // Disclaimer
              Text(
                'Based on the Hooper Index (Hooper & Mackinnon, 1995). For general guidance only — not a medical assessment.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.sc.onSurfaceMuted,
                      fontSize: 10,
                    ),
              ),

              const SizedBox(height: SphereSpacing.x32),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Check-In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HooperSlider extends StatelessWidget {
  const _HooperSlider({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SphereSpacing.x20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${value.round()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.sc.onSurfaceMuted,
                  fontSize: 10,
                ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF8B5CF6),
              thumbColor: const Color(0xFF8B5CF6),
              inactiveTrackColor:
                  const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 7,
              divisions: 6,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 4: `recovery_content_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';
import '../../../app/theme/sphere_theme_ext.dart';
import '../domain/recovery_content.dart';
import '../data/recovery_repository.dart';

class RecoveryContentDetailScreen extends StatelessWidget {
  const RecoveryContentDetailScreen({super.key, required this.contentId});
  final String contentId;

  @override
  Widget build(BuildContext context) {
    // Ideally driven by a provider; use FutureBuilder here for simplicity
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.sc.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<RecoveryContent?>(
        future: RecoveryRepository()
            .contentStream()
            .first
            .then((list) => list.where((c) => c.id == contentId).firstOrNull),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          final content = snap.data;
          if (content == null) {
            return const Center(child: Text('Content not found.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              SphereSpacing.x24, SphereSpacing.x8,
              SphereSpacing.x24, 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(content.evidenceLevel),
                    const SizedBox(width: 8),
                    _Badge(content.sportContext),
                  ],
                ),
                const SizedBox(height: SphereSpacing.x16),
                Text(
                  content.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${content.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.sc.onSurfaceMuted,
                      ),
                ),
                const SizedBox(height: SphereSpacing.x24),
                for (var i = 0; i < content.steps.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SphereSpacing.x12),
                      Expanded(
                        child: Text(
                          content.steps[i],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SphereSpacing.x12),
                ],
                if (content.youtubeUrl != null) ...[
                  const SizedBox(height: SphereSpacing.x16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(content.youtubeUrl!);
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      icon: const Icon(LucideIcons.play, size: 16),
                      label: const Text('Watch Video Guide'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: SphereRadius.pillRect,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: SphereSpacing.x24),
                Text(
                  'For general sporting guidance only. Not a substitute for professional advice.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.sc.onSurfaceMuted,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase().replaceAll('_', ' '),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Color(0xFF8B5CF6),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
```

**Step 5: Add routes to router**

Imports:
```dart
import '../features/recovery/presentation/recovery_screen.dart';
import '../features/recovery/presentation/wellness_checkin_screen.dart';
import '../features/recovery/presentation/recovery_content_detail_screen.dart';
```

Routes inside ShellRoute:
```dart
GoRoute(
  path: '/train/recovery',
  builder: (_, _) => const RecoveryScreen(),
),
GoRoute(
  path: '/train/recovery/check-in',
  builder: (_, _) => const WellnessCheckInScreen(),
),
GoRoute(
  path: '/train/recovery/content/:id',
  builder: (_, state) {
    final id = state.pathParameters['id']!;
    return RecoveryContentDetailScreen(contentId: id);
  },
),
```

**Step 6: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Step 7: Commit**

```bash
git add lib/features/recovery/ lib/app/router.dart
git commit -m "feat(recovery): add RecoveryScreen, WellnessCheckInScreen, content detail and routes"
```

---

## Task 12: Wire Live Metrics Into Train Hub Cards

The Train Hub cards currently show static subtitles. Wire them to real providers.

**Files:**
- Modify: `lib/features/home/presentation/train_hub_screen.dart`

**Step 1: Import new providers**

Add to imports in `train_hub_screen.dart`:
```dart
import '../../training_plans/presentation/training_plans_providers.dart';
import '../../recovery/presentation/recovery_providers.dart';
import '../../strength/presentation/strength_providers.dart';
```

**Step 2: Replace static grid section with live data**

Replace the 2×2 grid section in `TrainHubScreen.build` with:

```dart
// Gather live metrics
final plansAsync = ref.watch(assignedPlansProvider);
final workoutsAsync = ref.watch(assignedWorkoutsProvider);
final todayLog = ref.watch(todayRecoveryLogProvider);

final activePlan = plansAsync.valueOrNull?.isNotEmpty == true
    ? plansAsync.valueOrNull!.first
    : null;
final workoutCount = workoutsAsync.valueOrNull?.length ?? 0;
final wellnessScore = todayLog.valueOrNull?.wellnessScore;
```

Update Strength card subtitle: `subtitle: workoutCount > 0 ? '$workoutCount workout${workoutCount == 1 ? '' : 's'} assigned' : 'No workouts yet'`

Update Plans card subtitle: `subtitle: activePlan != null ? 'Week ${activePlan.currentWeek} of ${activePlan.totalWeeks}' : 'No active plan'`

Update Recovery card subtitle: `subtitle: wellnessScore != null ? 'Score: $wellnessScore%' : 'Tap to log wellness'`

**Step 3: Commit**

```bash
git add lib/features/home/presentation/train_hub_screen.dart
git commit -m "feat(train): wire live metrics into hub grid cards"
```

---

## Task 13: Final Build + Verify

**Step 1: Run build_runner one final time**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: exits 0, no errors.

**Step 2: Analyze**

```bash
flutter analyze lib/
```

Fix any errors before proceeding. Common issues:
- Missing imports — add the relevant `import` statement
- `WorkoutTemplate` not imported in `active_workout_screen.dart` — add `import '../domain/workout_template.dart';`
- `firstOrNull` requires `package:collection` — either add `collection: any` to pubspec or replace with: `list.isEmpty ? null : list.first`

**Step 3: Final commit**

```bash
git add .
git commit -m "feat(train-hub): complete player Performance Hub — Strength, Plans, Recovery+Nutrition"
```

---

## Summary

| Task | Feature | Files Created |
|---|---|---|
| 1 | Packages | pubspec.yaml |
| 2 | Widget | SphereFeatureGridCard |
| 3 | Train Hub | TrainHubScreen, router update |
| 4 | Strength | domain models (4 files) |
| 5 | Strength | StrengthRepository |
| 6 | Strength | StrengthScreen + providers |
| 7 | Strength | ActiveWorkoutScreen |
| 8 | Plans | domain models + repository |
| 9 | Plans | PlansScreen + PlanDetailScreen + providers + routes |
| 10 | Recovery | domain models + repository |
| 11 | Recovery | RecoveryScreen + WellnessCheckInScreen + detail + routes |
| 12 | Hub | Wire live metrics |
| 13 | QA | build_runner + analyze |

**New feature folders created:**
- `lib/features/strength/`
- `lib/features/training_plans/`
- `lib/features/recovery/`
