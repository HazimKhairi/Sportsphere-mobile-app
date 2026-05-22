// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fcmRepositoryHash() => r'5de69d026faf227a7fa170eaff8e29c2ed3b332e';

/// See also [fcmRepository].
@ProviderFor(fcmRepository)
final fcmRepositoryProvider = Provider<FcmRepository>.internal(
  fcmRepository,
  name: r'fcmRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmRepositoryRef = ProviderRef<FcmRepository>;
String _$fcmLogoutCleanupHash() => r'13cb697a2763a8d98029aec137a1efd940615ccf';

/// Best-effort: read the persisted deviceId, call unregisterDevice, clear pref.
/// Never throws — logout must always succeed locally.
///
/// Copied from [fcmLogoutCleanup].
@ProviderFor(fcmLogoutCleanup)
final fcmLogoutCleanupProvider =
    AutoDisposeProvider<Future<void> Function()>.internal(
      fcmLogoutCleanup,
      name: r'fcmLogoutCleanupProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fcmLogoutCleanupHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmLogoutCleanupRef = AutoDisposeProviderRef<Future<void> Function()>;
String _$fcmBootstrapHash() => r'165f5091ee7b3cd7b25211d9d5c502bc2ae488f6';

/// See also [FcmBootstrap].
@ProviderFor(FcmBootstrap)
final fcmBootstrapProvider = AsyncNotifierProvider<FcmBootstrap, void>.internal(
  FcmBootstrap.new,
  name: r'fcmBootstrapProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmBootstrapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FcmBootstrap = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
