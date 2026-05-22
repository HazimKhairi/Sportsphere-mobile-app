// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentHistoryRepositoryHash() =>
    r'ca2836b212850b52c0941f1f8aeb8c4cb98d7b7a';

/// See also [paymentHistoryRepository].
@ProviderFor(paymentHistoryRepository)
final paymentHistoryRepositoryProvider =
    Provider<PaymentHistoryRepository>.internal(
      paymentHistoryRepository,
      name: r'paymentHistoryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$paymentHistoryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentHistoryRepositoryRef = ProviderRef<PaymentHistoryRepository>;
String _$myPaymentHistoryHash() => r'7d87ce765876232dd1f0b100db897d6e4209732b';

/// See also [myPaymentHistory].
@ProviderFor(myPaymentHistory)
final myPaymentHistoryProvider =
    AutoDisposeStreamProvider<List<PaymentRecord>>.internal(
      myPaymentHistory,
      name: r'myPaymentHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myPaymentHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyPaymentHistoryRef = AutoDisposeStreamProviderRef<List<PaymentRecord>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
