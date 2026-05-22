// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scheduleRepositoryHash() =>
    r'111197804084b31bf2a483619732f43440f87155';

/// See also [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = Provider<ScheduleRepository>.internal(
  scheduleRepository,
  name: r'scheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleRepositoryRef = ProviderRef<ScheduleRepository>;
String _$monthSessionsHash() => r'd5d9ad55bb8bcce4052405ee32c8485fcd590721';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Sessions for the visible calendar month (and a 1-month buffer either side
/// so paging is instant).
///
/// Copied from [monthSessions].
@ProviderFor(monthSessions)
const monthSessionsProvider = MonthSessionsFamily();

/// Sessions for the visible calendar month (and a 1-month buffer either side
/// so paging is instant).
///
/// Copied from [monthSessions].
class MonthSessionsFamily extends Family<AsyncValue<List<TrainingSession>>> {
  /// Sessions for the visible calendar month (and a 1-month buffer either side
  /// so paging is instant).
  ///
  /// Copied from [monthSessions].
  const MonthSessionsFamily();

  /// Sessions for the visible calendar month (and a 1-month buffer either side
  /// so paging is instant).
  ///
  /// Copied from [monthSessions].
  MonthSessionsProvider call({required DateTime focusedMonth}) {
    return MonthSessionsProvider(focusedMonth: focusedMonth);
  }

  @override
  MonthSessionsProvider getProviderOverride(
    covariant MonthSessionsProvider provider,
  ) {
    return call(focusedMonth: provider.focusedMonth);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthSessionsProvider';
}

/// Sessions for the visible calendar month (and a 1-month buffer either side
/// so paging is instant).
///
/// Copied from [monthSessions].
class MonthSessionsProvider
    extends AutoDisposeStreamProvider<List<TrainingSession>> {
  /// Sessions for the visible calendar month (and a 1-month buffer either side
  /// so paging is instant).
  ///
  /// Copied from [monthSessions].
  MonthSessionsProvider({required DateTime focusedMonth})
    : this._internal(
        (ref) =>
            monthSessions(ref as MonthSessionsRef, focusedMonth: focusedMonth),
        from: monthSessionsProvider,
        name: r'monthSessionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthSessionsHash,
        dependencies: MonthSessionsFamily._dependencies,
        allTransitiveDependencies:
            MonthSessionsFamily._allTransitiveDependencies,
        focusedMonth: focusedMonth,
      );

  MonthSessionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.focusedMonth,
  }) : super.internal();

  final DateTime focusedMonth;

  @override
  Override overrideWith(
    Stream<List<TrainingSession>> Function(MonthSessionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthSessionsProvider._internal(
        (ref) => create(ref as MonthSessionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        focusedMonth: focusedMonth,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TrainingSession>> createElement() {
    return _MonthSessionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthSessionsProvider && other.focusedMonth == focusedMonth;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, focusedMonth.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthSessionsRef on AutoDisposeStreamProviderRef<List<TrainingSession>> {
  /// The parameter `focusedMonth` of this provider.
  DateTime get focusedMonth;
}

class _MonthSessionsProviderElement
    extends AutoDisposeStreamProviderElement<List<TrainingSession>>
    with MonthSessionsRef {
  _MonthSessionsProviderElement(super.provider);

  @override
  DateTime get focusedMonth => (origin as MonthSessionsProvider).focusedMonth;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
