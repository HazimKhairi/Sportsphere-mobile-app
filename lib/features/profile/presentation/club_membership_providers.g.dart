// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_membership_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clubMembershipRepositoryHash() =>
    r'0adbedb5b75a11c75854e2eb2c194f3ce358cca1';

/// See also [clubMembershipRepository].
@ProviderFor(clubMembershipRepository)
final clubMembershipRepositoryProvider =
    Provider<ClubMembershipRepository>.internal(
      clubMembershipRepository,
      name: r'clubMembershipRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clubMembershipRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClubMembershipRepositoryRef = ProviderRef<ClubMembershipRepository>;
String _$myClubMembershipsHash() => r'fb56fb9b113e38bf674fa0da898748b62b3182d8';

/// See also [myClubMemberships].
@ProviderFor(myClubMemberships)
final myClubMembershipsProvider =
    AutoDisposeFutureProvider<List<ClubMembership>>.internal(
      myClubMemberships,
      name: r'myClubMembershipsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myClubMembershipsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyClubMembershipsRef =
    AutoDisposeFutureProviderRef<List<ClubMembership>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
