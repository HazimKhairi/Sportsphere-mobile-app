// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plans_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainingPlansRepositoryHash() =>
    r'1bc75de5ef9a168c58c49ae915bc6fac445e63a6';

/// See also [trainingPlansRepository].
@ProviderFor(trainingPlansRepository)
final trainingPlansRepositoryProvider =
    AutoDisposeProvider<TrainingPlansRepository>.internal(
      trainingPlansRepository,
      name: r'trainingPlansRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainingPlansRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrainingPlansRepositoryRef =
    AutoDisposeProviderRef<TrainingPlansRepository>;
String _$assignedPlansHash() => r'982969459b562416117e67cc2ba6b9458082c865';

/// See also [assignedPlans].
@ProviderFor(assignedPlans)
final assignedPlansProvider =
    AutoDisposeStreamProvider<List<TrainingPlan>>.internal(
      assignedPlans,
      name: r'assignedPlansProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignedPlansHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignedPlansRef = AutoDisposeStreamProviderRef<List<TrainingPlan>>;
String _$planWeeksHash() => r'1f177ebbb115974f3241e70b07bac0ad6ce95fb6';

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

/// See also [planWeeks].
@ProviderFor(planWeeks)
const planWeeksProvider = PlanWeeksFamily();

/// See also [planWeeks].
class PlanWeeksFamily extends Family<AsyncValue<List<PlanWeek>>> {
  /// See also [planWeeks].
  const PlanWeeksFamily();

  /// See also [planWeeks].
  PlanWeeksProvider call(String planId) {
    return PlanWeeksProvider(planId);
  }

  @override
  PlanWeeksProvider getProviderOverride(covariant PlanWeeksProvider provider) {
    return call(provider.planId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'planWeeksProvider';
}

/// See also [planWeeks].
class PlanWeeksProvider extends AutoDisposeFutureProvider<List<PlanWeek>> {
  /// See also [planWeeks].
  PlanWeeksProvider(String planId)
    : this._internal(
        (ref) => planWeeks(ref as PlanWeeksRef, planId),
        from: planWeeksProvider,
        name: r'planWeeksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$planWeeksHash,
        dependencies: PlanWeeksFamily._dependencies,
        allTransitiveDependencies: PlanWeeksFamily._allTransitiveDependencies,
        planId: planId,
      );

  PlanWeeksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.planId,
  }) : super.internal();

  final String planId;

  @override
  Override overrideWith(
    FutureOr<List<PlanWeek>> Function(PlanWeeksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlanWeeksProvider._internal(
        (ref) => create(ref as PlanWeeksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        planId: planId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PlanWeek>> createElement() {
    return _PlanWeeksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlanWeeksProvider && other.planId == planId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, planId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlanWeeksRef on AutoDisposeFutureProviderRef<List<PlanWeek>> {
  /// The parameter `planId` of this provider.
  String get planId;
}

class _PlanWeeksProviderElement
    extends AutoDisposeFutureProviderElement<List<PlanWeek>>
    with PlanWeeksRef {
  _PlanWeeksProviderElement(super.provider);

  @override
  String get planId => (origin as PlanWeeksProvider).planId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
