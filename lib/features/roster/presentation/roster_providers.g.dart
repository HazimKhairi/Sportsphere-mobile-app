// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roster_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rosterClubIdInterceptorHash() =>
    r'4d942f70d0cfab8b47d7ad0e7edf4f8521a7f48d';

/// See also [rosterClubIdInterceptor].
@ProviderFor(rosterClubIdInterceptor)
final rosterClubIdInterceptorProvider = Provider<ClubIdInterceptor>.internal(
  rosterClubIdInterceptor,
  name: r'rosterClubIdInterceptorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rosterClubIdInterceptorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RosterClubIdInterceptorRef = ProviderRef<ClubIdInterceptor>;
String _$rosterRepositoryHash() => r'a8da2460165ace1b24aaf22e272a46f81c640a07';

/// See also [rosterRepository].
@ProviderFor(rosterRepository)
final rosterRepositoryProvider = Provider<RosterRepository>.internal(
  rosterRepository,
  name: r'rosterRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rosterRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RosterRepositoryRef = ProviderRef<RosterRepository>;
String _$rosterSearchQueryHash() => r'4306c3b1a0ba7021969489bc3d753d6a06758a56';

/// See also [rosterSearchQuery].
@ProviderFor(rosterSearchQuery)
final rosterSearchQueryProvider = AutoDisposeProvider<String>.internal(
  rosterSearchQuery,
  name: r'rosterSearchQueryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rosterSearchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RosterSearchQueryRef = AutoDisposeProviderRef<String>;
String _$playerDetailHash() => r'88f0d15f27073c87e4f33b88e5a42d6ffc9b4e26';

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

/// See also [playerDetail].
@ProviderFor(playerDetail)
const playerDetailProvider = PlayerDetailFamily();

/// See also [playerDetail].
class PlayerDetailFamily extends Family<AsyncValue<PlayerDetail>> {
  /// See also [playerDetail].
  const PlayerDetailFamily();

  /// See also [playerDetail].
  PlayerDetailProvider call({required String playerId}) {
    return PlayerDetailProvider(playerId: playerId);
  }

  @override
  PlayerDetailProvider getProviderOverride(
    covariant PlayerDetailProvider provider,
  ) {
    return call(playerId: provider.playerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'playerDetailProvider';
}

/// See also [playerDetail].
class PlayerDetailProvider extends AutoDisposeFutureProvider<PlayerDetail> {
  /// See also [playerDetail].
  PlayerDetailProvider({required String playerId})
    : this._internal(
        (ref) => playerDetail(ref as PlayerDetailRef, playerId: playerId),
        from: playerDetailProvider,
        name: r'playerDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$playerDetailHash,
        dependencies: PlayerDetailFamily._dependencies,
        allTransitiveDependencies:
            PlayerDetailFamily._allTransitiveDependencies,
        playerId: playerId,
      );

  PlayerDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final String playerId;

  @override
  Override overrideWith(
    FutureOr<PlayerDetail> Function(PlayerDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlayerDetailProvider._internal(
        (ref) => create(ref as PlayerDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PlayerDetail> createElement() {
    return _PlayerDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerDetailProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlayerDetailRef on AutoDisposeFutureProviderRef<PlayerDetail> {
  /// The parameter `playerId` of this provider.
  String get playerId;
}

class _PlayerDetailProviderElement
    extends AutoDisposeFutureProviderElement<PlayerDetail>
    with PlayerDetailRef {
  _PlayerDetailProviderElement(super.provider);

  @override
  String get playerId => (origin as PlayerDetailProvider).playerId;
}

String _$rosterNotifierHash() => r'a9f8e3e52eb595a1227175bd94f42e2ee6608e35';

/// See also [RosterNotifier].
@ProviderFor(RosterNotifier)
final rosterNotifierProvider =
    AutoDisposeAsyncNotifierProvider<RosterNotifier, RosterState>.internal(
      RosterNotifier.new,
      name: r'rosterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rosterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RosterNotifier = AutoDisposeAsyncNotifier<RosterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
