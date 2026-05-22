// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approvals_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$approvalsRepositoryHash() =>
    r'd2e21626234126d64b6b6e7b81e0abaf92ee8986';

/// See also [approvalsRepository].
@ProviderFor(approvalsRepository)
final approvalsRepositoryProvider = Provider<ApprovalsRepository>.internal(
  approvalsRepository,
  name: r'approvalsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$approvalsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ApprovalsRepositoryRef = ProviderRef<ApprovalsRepository>;
String _$approvalsNotifierHash() => r'7ef696d65e7239061d0fee77477d244afde99a53';

/// See also [ApprovalsNotifier].
@ProviderFor(ApprovalsNotifier)
final approvalsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ApprovalsNotifier,
      List<PendingPayment>
    >.internal(
      ApprovalsNotifier.new,
      name: r'approvalsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$approvalsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ApprovalsNotifier = AutoDisposeAsyncNotifier<List<PendingPayment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
