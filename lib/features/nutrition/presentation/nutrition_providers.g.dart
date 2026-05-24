// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nutritionRepositoryHash() =>
    r'770ce35c43f694bebaaca107d629e3e3f7d8938e';

/// See also [nutritionRepository].
@ProviderFor(nutritionRepository)
final nutritionRepositoryProvider =
    AutoDisposeProvider<NutritionRepository>.internal(
      nutritionRepository,
      name: r'nutritionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nutritionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NutritionRepositoryRef = AutoDisposeProviderRef<NutritionRepository>;
String _$todayNutritionLogsHash() =>
    r'6d7bf11fb1d53e9f453af26ef2de422507b3f9c1';

/// See also [todayNutritionLogs].
@ProviderFor(todayNutritionLogs)
final todayNutritionLogsProvider =
    AutoDisposeStreamProvider<List<NutritionLog>>.internal(
      todayNutritionLogs,
      name: r'todayNutritionLogsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayNutritionLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayNutritionLogsRef =
    AutoDisposeStreamProviderRef<List<NutritionLog>>;
String _$todayNutritionSummaryHash() =>
    r'ac1ba709f6557c770f768240c9f25f2a3a5b515b';

/// See also [todayNutritionSummary].
@ProviderFor(todayNutritionSummary)
final todayNutritionSummaryProvider =
    AutoDisposeProvider<DailySummary>.internal(
      todayNutritionSummary,
      name: r'todayNutritionSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayNutritionSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayNutritionSummaryRef = AutoDisposeProviderRef<DailySummary>;
String _$recentNutritionLogsHash() =>
    r'a7723671db98e156a570cbe11c0f1b0132959e2d';

/// See also [recentNutritionLogs].
@ProviderFor(recentNutritionLogs)
final recentNutritionLogsProvider =
    AutoDisposeStreamProvider<List<NutritionLog>>.internal(
      recentNutritionLogs,
      name: r'recentNutritionLogsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentNutritionLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentNutritionLogsRef =
    AutoDisposeStreamProviderRef<List<NutritionLog>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
