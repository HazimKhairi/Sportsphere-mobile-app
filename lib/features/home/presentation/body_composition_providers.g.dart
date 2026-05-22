// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_composition_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bodyCompositionRepositoryHash() =>
    r'1bd210001e9c8b225f232299e93f42440d8360d3';

/// See also [bodyCompositionRepository].
@ProviderFor(bodyCompositionRepository)
final bodyCompositionRepositoryProvider =
    Provider<BodyCompositionRepository>.internal(
      bodyCompositionRepository,
      name: r'bodyCompositionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bodyCompositionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BodyCompositionRepositoryRef = ProviderRef<BodyCompositionRepository>;
String _$myBodyCompositionHash() => r'5e7857fb95b3741f069dadf0bae204a46b83a700';

/// See also [myBodyComposition].
@ProviderFor(myBodyComposition)
final myBodyCompositionProvider =
    AutoDisposeStreamProvider<List<BodyCompositionEntry>>.internal(
      myBodyComposition,
      name: r'myBodyCompositionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myBodyCompositionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyBodyCompositionRef =
    AutoDisposeStreamProviderRef<List<BodyCompositionEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
