// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentDetailHash() => r'5c801e6f53fefbabae00b81dd69aa1707377402e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [paymentDetail].
@ProviderFor(paymentDetail)
const paymentDetailProvider = PaymentDetailFamily();

/// See also [paymentDetail].
class PaymentDetailFamily extends Family<AsyncValue<PaymentRecord?>> {
  /// See also [paymentDetail].
  const PaymentDetailFamily();

  /// See also [paymentDetail].
  PaymentDetailProvider call({required String paymentId}) {
    return PaymentDetailProvider(paymentId: paymentId);
  }

  @override
  PaymentDetailProvider getProviderOverride(
    covariant PaymentDetailProvider provider,
  ) {
    return call(paymentId: provider.paymentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paymentDetailProvider';
}

/// See also [paymentDetail].
class PaymentDetailProvider extends AutoDisposeFutureProvider<PaymentRecord?> {
  /// See also [paymentDetail].
  PaymentDetailProvider({required String paymentId})
    : this._internal(
        (ref) => paymentDetail(ref as PaymentDetailRef, paymentId: paymentId),
        from: paymentDetailProvider,
        name: r'paymentDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$paymentDetailHash,
        dependencies: PaymentDetailFamily._dependencies,
        allTransitiveDependencies:
            PaymentDetailFamily._allTransitiveDependencies,
        paymentId: paymentId,
      );

  PaymentDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.paymentId,
  }) : super.internal();

  final String paymentId;

  @override
  Override overrideWith(
    FutureOr<PaymentRecord?> Function(PaymentDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentDetailProvider._internal(
        (ref) => create(ref as PaymentDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        paymentId: paymentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PaymentRecord?> createElement() {
    return _PaymentDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentDetailProvider && other.paymentId == paymentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, paymentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaymentDetailRef on AutoDisposeFutureProviderRef<PaymentRecord?> {
  /// The parameter `paymentId` of this provider.
  String get paymentId;
}

class _PaymentDetailProviderElement
    extends AutoDisposeFutureProviderElement<PaymentRecord?>
    with PaymentDetailRef {
  _PaymentDetailProviderElement(super.provider);

  @override
  String get paymentId => (origin as PaymentDetailProvider).paymentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
