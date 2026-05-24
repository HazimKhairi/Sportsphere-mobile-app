// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$registrationRepositoryHash() =>
    r'7feec65ac59aa7fe09619d738dda7635b9fb7b1a';

/// See also [registrationRepository].
@ProviderFor(registrationRepository)
final registrationRepositoryProvider =
    Provider<RegistrationRepository>.internal(
      registrationRepository,
      name: r'registrationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$registrationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RegistrationRepositoryRef = ProviderRef<RegistrationRepository>;
String _$isRegisteredForHash() => r'2998d576cd1441084682c1074331f988ff6596f4';

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

/// See also [isRegisteredFor].
@ProviderFor(isRegisteredFor)
const isRegisteredForProvider = IsRegisteredForFamily();

/// See also [isRegisteredFor].
class IsRegisteredForFamily extends Family<AsyncValue<bool>> {
  /// See also [isRegisteredFor].
  const IsRegisteredForFamily();

  /// See also [isRegisteredFor].
  IsRegisteredForProvider call({required String programId}) {
    return IsRegisteredForProvider(programId: programId);
  }

  @override
  IsRegisteredForProvider getProviderOverride(
    covariant IsRegisteredForProvider provider,
  ) {
    return call(programId: provider.programId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isRegisteredForProvider';
}

/// See also [isRegisteredFor].
class IsRegisteredForProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [isRegisteredFor].
  IsRegisteredForProvider({required String programId})
    : this._internal(
        (ref) =>
            isRegisteredFor(ref as IsRegisteredForRef, programId: programId),
        from: isRegisteredForProvider,
        name: r'isRegisteredForProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isRegisteredForHash,
        dependencies: IsRegisteredForFamily._dependencies,
        allTransitiveDependencies:
            IsRegisteredForFamily._allTransitiveDependencies,
        programId: programId,
      );

  IsRegisteredForProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
  }) : super.internal();

  final String programId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsRegisteredForRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsRegisteredForProvider._internal(
        (ref) => create(ref as IsRegisteredForRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsRegisteredForProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsRegisteredForProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsRegisteredForRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _IsRegisteredForProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsRegisteredForRef {
  _IsRegisteredForProviderElement(super.provider);

  @override
  String get programId => (origin as IsRegisteredForProvider).programId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
