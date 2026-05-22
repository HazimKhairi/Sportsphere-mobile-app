// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drill_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$drillDetailHash() => r'bfc9f99a2421adcf411f91a2d9fe2663bf40c0df';

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

/// See also [drillDetail].
@ProviderFor(drillDetail)
const drillDetailProvider = DrillDetailFamily();

/// See also [drillDetail].
class DrillDetailFamily extends Family<AsyncValue<Drill?>> {
  /// See also [drillDetail].
  const DrillDetailFamily();

  /// See also [drillDetail].
  DrillDetailProvider call({required String drillId}) {
    return DrillDetailProvider(drillId: drillId);
  }

  @override
  DrillDetailProvider getProviderOverride(
    covariant DrillDetailProvider provider,
  ) {
    return call(drillId: provider.drillId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'drillDetailProvider';
}

/// See also [drillDetail].
class DrillDetailProvider extends AutoDisposeFutureProvider<Drill?> {
  /// See also [drillDetail].
  DrillDetailProvider({required String drillId})
    : this._internal(
        (ref) => drillDetail(ref as DrillDetailRef, drillId: drillId),
        from: drillDetailProvider,
        name: r'drillDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$drillDetailHash,
        dependencies: DrillDetailFamily._dependencies,
        allTransitiveDependencies: DrillDetailFamily._allTransitiveDependencies,
        drillId: drillId,
      );

  DrillDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.drillId,
  }) : super.internal();

  final String drillId;

  @override
  Override overrideWith(
    FutureOr<Drill?> Function(DrillDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DrillDetailProvider._internal(
        (ref) => create(ref as DrillDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        drillId: drillId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Drill?> createElement() {
    return _DrillDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DrillDetailProvider && other.drillId == drillId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, drillId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DrillDetailRef on AutoDisposeFutureProviderRef<Drill?> {
  /// The parameter `drillId` of this provider.
  String get drillId;
}

class _DrillDetailProviderElement
    extends AutoDisposeFutureProviderElement<Drill?>
    with DrillDetailRef {
  _DrillDetailProviderElement(super.provider);

  @override
  String get drillId => (origin as DrillDetailProvider).drillId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
