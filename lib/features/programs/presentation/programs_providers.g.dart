// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programsRepositoryHash() =>
    r'd6c3a4f2e007519c4e331497706b8d1a6465d35b';

/// See also [programsRepository].
@ProviderFor(programsRepository)
final programsRepositoryProvider = Provider<ProgramsRepository>.internal(
  programsRepository,
  name: r'programsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$programsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProgramsRepositoryRef = ProviderRef<ProgramsRepository>;
String _$publishedProgramsHash() => r'552db370602274852610e1442ddce0d8e2fdc531';

/// See also [publishedPrograms].
@ProviderFor(publishedPrograms)
final publishedProgramsProvider =
    AutoDisposeStreamProvider<List<Program>>.internal(
      publishedPrograms,
      name: r'publishedProgramsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$publishedProgramsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublishedProgramsRef = AutoDisposeStreamProviderRef<List<Program>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
