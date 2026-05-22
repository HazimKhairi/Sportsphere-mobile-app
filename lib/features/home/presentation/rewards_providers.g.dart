// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rewardsRepositoryHash() => r'8d3b5c5d7426a9af6b737ec23d0ead7ee098be1e';

/// See also [rewardsRepository].
@ProviderFor(rewardsRepository)
final rewardsRepositoryProvider = Provider<RewardsRepository>.internal(
  rewardsRepository,
  name: r'rewardsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rewardsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RewardsRepositoryRef = ProviderRef<RewardsRepository>;
String _$myRewardsCatalogHash() => r'a5cd72c734c59eae04e1cffe4c4c9472f69d7676';

/// See also [myRewardsCatalog].
@ProviderFor(myRewardsCatalog)
final myRewardsCatalogProvider =
    AutoDisposeStreamProvider<List<Reward>>.internal(
      myRewardsCatalog,
      name: r'myRewardsCatalogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myRewardsCatalogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyRewardsCatalogRef = AutoDisposeStreamProviderRef<List<Reward>>;
String _$myPointsBalanceHash() => r'62e84ab10abc4e7a6f8c80c25098eda401374504';

/// See also [myPointsBalance].
@ProviderFor(myPointsBalance)
final myPointsBalanceProvider = AutoDisposeStreamProvider<int>.internal(
  myPointsBalance,
  name: r'myPointsBalanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myPointsBalanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyPointsBalanceRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
