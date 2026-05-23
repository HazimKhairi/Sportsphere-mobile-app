// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveryRepositoryHash() =>
    r'f66eb4e11ee97dddf7bb5216b2906c2423a52ae0';

/// See also [recoveryRepository].
@ProviderFor(recoveryRepository)
final recoveryRepositoryProvider =
    AutoDisposeProvider<RecoveryRepository>.internal(
      recoveryRepository,
      name: r'recoveryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recoveryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecoveryRepositoryRef = AutoDisposeProviderRef<RecoveryRepository>;
String _$todayRecoveryLogHash() => r'18d659f36f9cbbc0a213457a76479ffcb4b6014a';

/// See also [todayRecoveryLog].
@ProviderFor(todayRecoveryLog)
final todayRecoveryLogProvider =
    AutoDisposeStreamProvider<RecoveryLog?>.internal(
      todayRecoveryLog,
      name: r'todayRecoveryLogProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayRecoveryLogHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayRecoveryLogRef = AutoDisposeStreamProviderRef<RecoveryLog?>;
String _$recentRecoveryLogsHash() =>
    r'fb0d40c31e8fba1f46b06a8f60f53bced1b60724';

/// See also [recentRecoveryLogs].
@ProviderFor(recentRecoveryLogs)
final recentRecoveryLogsProvider =
    AutoDisposeStreamProvider<List<RecoveryLog>>.internal(
      recentRecoveryLogs,
      name: r'recentRecoveryLogsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentRecoveryLogsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentRecoveryLogsRef = AutoDisposeStreamProviderRef<List<RecoveryLog>>;
String _$recoveryContentHash() => r'bb6f025def90e57408f5a3baded9ca843134e25f';

/// See also [recoveryContent].
@ProviderFor(recoveryContent)
final recoveryContentProvider =
    AutoDisposeStreamProvider<List<RecoveryContent>>.internal(
      recoveryContent,
      name: r'recoveryContentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recoveryContentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecoveryContentRef =
    AutoDisposeStreamProviderRef<List<RecoveryContent>>;
String _$nutritionContentHash() => r'7289f9ed7ee70d69583326a74293d1901dbb884a';

/// See also [nutritionContent].
@ProviderFor(nutritionContent)
final nutritionContentProvider =
    AutoDisposeStreamProvider<List<RecoveryContent>>.internal(
      nutritionContent,
      name: r'nutritionContentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$nutritionContentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NutritionContentRef =
    AutoDisposeStreamProviderRef<List<RecoveryContent>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
