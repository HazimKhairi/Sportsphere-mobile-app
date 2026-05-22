// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievements_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$achievementsRepositoryHash() =>
    r'118030d3d559085b45425b60f01f82bb9c4d9f68';

/// See also [achievementsRepository].
@ProviderFor(achievementsRepository)
final achievementsRepositoryProvider =
    Provider<AchievementsRepository>.internal(
      achievementsRepository,
      name: r'achievementsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$achievementsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AchievementsRepositoryRef = ProviderRef<AchievementsRepository>;
String _$myAchievementsHash() => r'f2ddb7b3e2f5aa2bf107656a0cb7c50ac1fefae6';

/// See also [myAchievements].
@ProviderFor(myAchievements)
final myAchievementsProvider =
    AutoDisposeStreamProvider<List<Achievement>>.internal(
      myAchievements,
      name: r'myAchievementsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myAchievementsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyAchievementsRef = AutoDisposeStreamProviderRef<List<Achievement>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
