class PlayerCard {
  const PlayerCard({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.teamName,
    this.photoUrl,
    this.dateOfBirth,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String position;
  final String teamName;
  final String? photoUrl;
  final String? dateOfBirth;

  String get fullName => '$firstName $lastName'.trim();
}
