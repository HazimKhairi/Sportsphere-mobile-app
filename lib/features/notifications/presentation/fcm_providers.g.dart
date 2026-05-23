// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fcmRepositoryHash() => r'bbcaa9794ee61b44cc6d764f10c3958e5e378bca';

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
String _$fcmLogoutCleanupHash() => r'409a1611a2b9bcdd6dcda01226687e2d71da0952';

/// Best-effort: unregister FCM token on logout.
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
String _$fcmBootstrapHash() => r'93cce37b6524f94073b4fec24ebbe94842158e28';

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
