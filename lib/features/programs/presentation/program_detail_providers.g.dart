// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programDetailHash() => r'9fbae7dd531d4799db8877f8b8186aafb4d26415';

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

/// See also [programDetail].
@ProviderFor(programDetail)
const programDetailProvider = ProgramDetailFamily();

/// See also [programDetail].
class ProgramDetailFamily extends Family<AsyncValue<Program?>> {
  /// See also [programDetail].
  const ProgramDetailFamily();

  /// See also [programDetail].
  ProgramDetailProvider call({required String programId}) {
    return ProgramDetailProvider(programId: programId);
  }

  @override
  ProgramDetailProvider getProviderOverride(
    covariant ProgramDetailProvider provider,
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
  String? get name => r'programDetailProvider';
}

/// See also [programDetail].
class ProgramDetailProvider extends AutoDisposeFutureProvider<Program?> {
  /// See also [programDetail].
  ProgramDetailProvider({required String programId})
    : this._internal(
        (ref) => programDetail(ref as ProgramDetailRef, programId: programId),
        from: programDetailProvider,
        name: r'programDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$programDetailHash,
        dependencies: ProgramDetailFamily._dependencies,
        allTransitiveDependencies:
            ProgramDetailFamily._allTransitiveDependencies,
        programId: programId,
      );

  ProgramDetailProvider._internal(
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
    FutureOr<Program?> Function(ProgramDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProgramDetailProvider._internal(
        (ref) => create(ref as ProgramDetailRef),
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
  AutoDisposeFutureProviderElement<Program?> createElement() {
    return _ProgramDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramDetailProvider && other.programId == programId;
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
mixin ProgramDetailRef on AutoDisposeFutureProviderRef<Program?> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramDetailProviderElement
    extends AutoDisposeFutureProviderElement<Program?>
    with ProgramDetailRef {
  _ProgramDetailProviderElement(super.provider);

  @override
  String get programId => (origin as ProgramDetailProvider).programId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
