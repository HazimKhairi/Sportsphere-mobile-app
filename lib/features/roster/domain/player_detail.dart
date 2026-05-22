class PlayerDetail {
  const PlayerDetail({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.position,
    required this.teamName,
    this.photoUrl,
    this.dateOfBirth,
    this.availability,
    this.jerseyNumber,
    this.parentName,
    this.parentPhone,
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
  final String? availability; // null | 'injured' | 'sick' | 'away'
  final int? jerseyNumber;
  final String? parentName;
  final String? parentPhone;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}
