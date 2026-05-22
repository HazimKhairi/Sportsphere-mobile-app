// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rosterRepositoryHash() => r'cb1163681c6b3a4a1939c4aba2586b0970336515';

/// See also [rosterRepository].
@ProviderFor(rosterRepository)
final rosterRepositoryProvider = Provider<RosterRepository>.internal(
  rosterRepository,
  name: r'rosterRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rosterRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RosterRepositoryRef = ProviderRef<RosterRepository>;
String _$rosterSearchQueryHash() => r'4306c3b1a0ba7021969489bc3d753d6a06758a56';

/// See also [rosterSearchQuery].
@ProviderFor(rosterSearchQuery)
final rosterSearchQueryProvider = AutoDisposeProvider<String>.internal(
  rosterSearchQuery,
  name: r'rosterSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rosterSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RosterSearchQueryRef = AutoDisposeProviderRef<String>;
String _$rosterNotifierHash() => r'443f8742da814b7a17cdaa949ac7e7b58aad1a71';

/// See also [RosterNotifier].
@ProviderFor(RosterNotifier)
final rosterNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RosterNotifier, RosterState>.internal(
      RosterNotifier.new,
      name: r'rosterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rosterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RosterNotifier = AutoDisposeAsyncNotifier<RosterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
