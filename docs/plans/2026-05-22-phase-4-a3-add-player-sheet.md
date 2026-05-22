# Phase 4-A3: Add Player Bottom Sheet Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Staff taps the FAB on the Roster screen to open an `AddPlayerSheet` bottom sheet, fills in player details, and submits to `POST /api/players/mobile` to create a new player in the club.

**Architecture:** TDD-first. Add `createPlayer` to the existing `RosterRepository`, write 3 tests first, then implement the method. Build `AddPlayerSheet` as a plain `StatefulWidget` that receives an `onSubmit` callback. Wire the FAB in `RosterScreen` to show the sheet and call `rosterRepository.createPlayer`, then invalidate the roster notifier on success.

**Tech Stack:** Flutter, Dio, Riverpod, Mocktail (tests), LucideIcons, SphereColors/SphereRadius/SphereSpacing

---

### Task 1: Add 3 failing tests for `createPlayer`

**Files:**
- Modify: `test/features/roster/roster_repository_test.dart`

**Step 1: Add 3 new test cases at the end of `main()` in the test file**

Append these tests inside the `main()` block (after the last existing `test(...)`):

```dart
  // ---------------------------------------------------------------------------
  // createPlayer
  // ---------------------------------------------------------------------------

  test('createPlayer success', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/players/mobile',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/api/players/mobile'),
              statusCode: 201,
              data: {
                'player': {
                  'id': 'new1',
                  'firstName': 'Ahmad',
                  'lastName': 'Zulkifli',
                  'email': 'ahmad@example.com',
                  'phone': '+601123456789',
                  'position': 'Midfielder',
                  'teamName': '',
                  'photoUrl': null,
                  'dateOfBirth': null,
                }
              },
            ));

    final result = await repo.createPlayer(
      clubId: 'club123',
      firstName: 'Ahmad',
      lastName: 'Zulkifli',
      email: 'ahmad@example.com',
    );

    expect(result.fullName, 'Ahmad Zulkifli');
    expect(result.id, 'new1');
  });

  test('createPlayer sends X-Club-Id header', () async {
    Options? capturedOptions;

    when(() => dio.post<Map<String, dynamic>>(
          '/api/players/mobile',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenAnswer((invocation) async {
      capturedOptions = invocation.namedArguments[#options] as Options;
      return Response(
        requestOptions: RequestOptions(path: '/api/players/mobile'),
        statusCode: 201,
        data: {
          'player': {
            'id': 'x',
            'firstName': 'A',
            'lastName': 'B',
            'email': '',
            'phone': '',
            'position': '',
            'teamName': '',
            'photoUrl': null,
            'dateOfBirth': null,
          }
        },
      );
    });

    await repo.createPlayer(
      clubId: 'club123',
      firstName: 'A',
      lastName: 'B',
    );

    expect(capturedOptions, isNotNull);
    expect(capturedOptions!.headers, isNotNull);
    expect(capturedOptions!.headers!['X-Club-Id'], 'club123');
  });

  test('createPlayer propagates RosterException on 400', () async {
    when(() => dio.post<Map<String, dynamic>>(
          '/api/players/mobile',
          data: any(named: 'data'),
          options: any(named: 'options'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/players/mobile'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/players/mobile'),
            statusCode: 400,
            data: {'error': 'Email already exists'},
          ),
          type: DioExceptionType.badResponse,
        ));

    expect(
      () => repo.createPlayer(
        clubId: 'club123',
        firstName: 'A',
        lastName: 'B',
        email: 'dup@example.com',
      ),
      throwsA(isA<RosterException>()),
    );
  });
```

**Step 2: Run tests — expect failures**

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile
flutter test test/features/roster/roster_repository_test.dart
```

Expected: 3 new tests FAIL (method `createPlayer` doesn't exist yet), existing 5 tests pass.

---

### Task 2: Implement `createPlayer` in `RosterRepository`

**Files:**
- Modify: `lib/features/roster/data/roster_repository.dart`

**Step 1: Add `createPlayer` method after `getPlayer`**

Insert before the `_fromJson` private method:

```dart
  Future<PlayerCard> createPlayer({
    required String clubId,
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? position,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/players/mobile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          if (position != null && position.isNotEmpty) 'position': position,
        },
        options: Options(headers: {'X-Club-Id': clubId}),
      );
      final data = res.data ?? const <String, dynamic>{};
      final p = (data['player'] as Map<String, dynamic>?) ?? data;
      return _fromJson(p);
    } on DioException catch (e) {
      throw RosterException(
        e.response?.data is Map
            ? (e.response!.data as Map)['error']?.toString() ??
                'Failed to create player'
            : 'Failed to create player',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

**Step 2: Run tests — all 8 should pass**

```bash
flutter test test/features/roster/roster_repository_test.dart
```

Expected: 8/8 pass.

**Step 3: Commit**

```bash
git add test/features/roster/roster_repository_test.dart lib/features/roster/data/roster_repository.dart
git commit -m "feat(roster): createPlayer TDD — 3 tests + implementation"
```

---

### Task 3: Create `AddPlayerSheet` widget

**Files:**
- Create: `lib/features/roster/presentation/add_player_sheet.dart`

**Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/sphere_colors.dart';
import '../../../app/theme/sphere_radius.dart';
import '../../../app/theme/sphere_spacing.dart';

class AddPlayerSheet extends StatefulWidget {
  const AddPlayerSheet({super.key, required this.onSubmit});

  final Future<void> Function({
    required String firstName,
    required String lastName,
    String? email,
    String? phone,
    String? position,
  }) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String firstName,
      required String lastName,
      String? email,
      String? phone,
      String? position,
    }) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SphereColors.surfaceElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddPlayerSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<AddPlayerSheet> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _position = TextEditingController();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _position.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSubmit(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        position: _position.text.trim().isEmpty ? null : _position.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _busy = false;
        _error = e
            .toString()
            .replaceAll('RosterException(400): ', '')
            .replaceAll('RosterException(null): ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: SphereSpacing.x24,
        right: SphereSpacing.x24,
        top: SphereSpacing.x24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SphereColors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add player',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Required: first and last name.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: SphereColors.onSurfaceMuted),
          ),
          const SizedBox(height: 20),

          // First + last name side by side
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('First name'),
                    const SizedBox(height: 6),
                    _Input(controller: _firstName, hint: 'First'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Last name'),
                    const SizedBox(height: 6),
                    _Input(controller: _lastName, hint: 'Last'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Email'),
          const SizedBox(height: 6),
          _Input(
            controller: _email,
            hint: 'player@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Phone'),
          const SizedBox(height: 6),
          _Input(
            controller: _phone,
            hint: '+601X-XXXXXXX',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          const _FieldLabel('Position'),
          const SizedBox(height: 6),
          _Input(
            controller: _position,
            hint: 'e.g. Midfielder',
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: SphereColors.danger,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Submit button
          ListenableBuilder(
            listenable: Listenable.merge([_firstName, _lastName]),
            builder: (context, _) {
              final canSubmit = !_busy &&
                  _firstName.text.trim().isNotEmpty &&
                  _lastName.text.trim().isNotEmpty;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SphereColors.primary,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: SphereRadius.pillRect,
                    ),
                    elevation: 0,
                    disabledBackgroundColor:
                        SphereColors.primary.withValues(alpha: 0.4),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : const Text(
                          'Add player',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private design primitives
// ---------------------------------------------------------------------------

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: SphereColors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SphereColors.surfaceElev2,
        borderRadius: SphereRadius.pillRect,
        border: Border.all(color: SphereColors.borderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: SphereColors.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: SphereColors.onSurfaceMuted),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
```

Note: The `LucideIcons` import is included even though it's not used in the sheet itself — remove it to keep the file clean. The submit button's enabled state is reactive via `ListenableBuilder` on the two required controllers so the button enables/disables as the user types without needing full `setState` on every keystroke.

---

### Task 4: Wire FAB in `RosterScreen`

**Files:**
- Modify: `lib/features/roster/presentation/roster_screen.dart`

**Step 1: Add import for `AddPlayerSheet` and `activeClubIdProvider` at top of file**

`activeClubIdProvider` is already imported via `roster_providers.dart` (which imports `staff_home_providers.dart`). Add only the `add_player_sheet.dart` import.

**Step 2: Replace the `floatingActionButton` property**

Replace:
```dart
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: SphereColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(LucideIcons.userPlus),
      ),
```

With:
```dart
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final clubId = ref.watch(activeClubIdProvider).valueOrNull;
          return FloatingActionButton(
            onPressed: clubId == null
                ? null
                : () {
                    AddPlayerSheet.show(
                      context,
                      onSubmit: ({
                        required firstName,
                        required lastName,
                        email,
                        phone,
                        position,
                      }) async {
                        await ref
                            .read(rosterRepositoryProvider)
                            .createPlayer(
                              clubId: clubId,
                              firstName: firstName,
                              lastName: lastName,
                              email: email,
                              phone: phone,
                              position: position,
                            );
                        ref.invalidate(rosterNotifierProvider);
                      },
                    );
                  },
            backgroundColor: SphereColors.primary,
            foregroundColor: Colors.black,
            child: const Icon(LucideIcons.userPlus),
          );
        },
      ),
```

**Step 3: Add the `add_player_sheet.dart` import** at the top of `roster_screen.dart`, after the existing imports.

---

### Task 5: Run analyze + full test suite

**Step 1: Run Flutter analyzer**

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/client_project/sportsphere-mobile
flutter analyze
```

Expected: No errors (warnings about unused imports are ok to fix).

**Step 2: Run full test suite**

```bash
flutter test
```

Expected: 135+ tests pass (132 baseline + 3 new).

**Step 3: Commit**

```bash
git add lib/features/roster/presentation/add_player_sheet.dart lib/features/roster/presentation/roster_screen.dart
git commit -m "feat(roster): add player sheet + FAB wire (Phase 4-A3)"
```

---

### Final verification

- `flutter test` outputs 135+ passing tests
- `flutter analyze` is clean
- Commit message: `feat(roster): add player sheet + createPlayer (TDD)`
