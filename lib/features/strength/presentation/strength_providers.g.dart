// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strength_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strengthRepositoryHash() =>
    r'51d45cf05b8e5faeb1e3a7b35d56b11b4eb1b397';

/// See also [strengthRepository].
@ProviderFor(strengthRepository)
final strengthRepositoryProvider =
    AutoDisposeProvider<StrengthRepository>.internal(
      strengthRepository,
      name: r'strengthRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strengthRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StrengthRepositoryRef = AutoDisposeProviderRef<StrengthRepository>;
String _$assignedWorkoutsHash() => r'ffef4b708a5dedab1ac59a361fee7417d9af3dba';

/// See also [assignedWorkouts].
@ProviderFor(assignedWorkouts)
final assignedWorkoutsProvider =
    AutoDisposeStreamProvider<List<WorkoutTemplate>>.internal(
      assignedWorkouts,
      name: r'assignedWorkoutsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignedWorkoutsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignedWorkoutsRef =
    AutoDisposeStreamProviderRef<List<WorkoutTemplate>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
