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
String _$fcmBootstrapHash() => r'981b1fa9c3a3e555a70a03802ce485241dc12148';

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
