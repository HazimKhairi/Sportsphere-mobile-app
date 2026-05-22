class ClubMembership {
  const ClubMembership({
    required this.clubId,
    required this.clubName,
    required this.role,
  });
  final String clubId;
  final String clubName;
  final String role; // OWNER, ADMIN, COACH, STAFF, MEMBER
}
