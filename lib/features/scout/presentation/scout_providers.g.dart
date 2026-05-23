// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scoutRepositoryHash() => r'3910703981011e44f0f158ed8ebe4c3f87046f59';

/// See also [scoutRepository].
@ProviderFor(scoutRepository)
final scoutRepositoryProvider = Provider<ScoutRepository>.internal(
  scoutRepository,
  name: r'scoutRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scoutRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScoutRepositoryRef = ProviderRef<ScoutRepository>;
String _$scoutProfileNotifierHash() =>
    r'8b76a0ce4821119fe1bd0a0818dcb53bd2bcbd33';

/// See also [ScoutProfileNotifier].
@ProviderFor(ScoutProfileNotifier)
final scoutProfileNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ScoutProfileNotifier,
      ScoutingProfile?
    >.internal(
      ScoutProfileNotifier.new,
      name: r'scoutProfileNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scoutProfileNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ScoutProfileNotifier = AutoDisposeAsyncNotifier<ScoutingProfile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
