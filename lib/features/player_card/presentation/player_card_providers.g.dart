// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_card_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$playerCardRepositoryHash() =>
    r'b9eef4c331a3c358a8ae38ecfc022873403dd4a0';

/// See also [playerCardRepository].
@ProviderFor(playerCardRepository)
final playerCardRepositoryProvider = Provider<PlayerCardRepository>.internal(
  playerCardRepository,
  name: r'playerCardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$playerCardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerCardRepositoryRef = ProviderRef<PlayerCardRepository>;
String _$playerCardHash() => r'15d7c2b94f6e9770922f11e0aef236f554702fba';

/// See also [playerCard].
@ProviderFor(playerCard)
final playerCardProvider =
    AutoDisposeFutureProvider<
      ({PlayerCardData card, TrainingSummary? summary})
    >.internal(
      playerCard,
      name: r'playerCardProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$playerCardHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerCardRef =
    AutoDisposeFutureProviderRef<
      ({PlayerCardData card, TrainingSummary? summary})
    >;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
