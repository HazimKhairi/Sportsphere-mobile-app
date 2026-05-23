class ClubStorefront {
  const ClubStorefront({
    this.instagramUrl,
    this.facebookUrl,
    this.tiktokUrl,
    this.heroHeadline,
    this.heroSubheadline,
  });

  final String? instagramUrl;
  final String? facebookUrl;
  final String? tiktokUrl;
  final String? heroHeadline;
  final String? heroSubheadline;

  factory ClubStorefront.fromJson(Map<String, dynamic> json) {
    return ClubStorefront(
      instagramUrl: json['instagramUrl'] as String?,
      facebookUrl: json['facebookUrl'] as String?,
      tiktokUrl: json['tiktokUrl'] as String?,
      heroHeadline: json['heroHeadline'] as String?,
      heroSubheadline: json['heroSubheadline'] as String?,
    );
  }
}

class ClubInfo {
  const ClubInfo({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    this.sport,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.certifications = const [],
    this.enabledSports = const [],
    this.storefront,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final String? sport;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final List<String> certifications;
  final List<String> enabledSports;
  final ClubStorefront? storefront;

  factory ClubInfo.fromJson(Map<String, dynamic> json) {
    final rawCerts = json['certifications'] as List<dynamic>? ?? [];
    final rawSports = json['enabledSports'] as List<dynamic>? ?? [];
    final rawStorefront = json['storefront'] as Map<String, dynamic>?;

    return ClubInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      sport: json['sport'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      certifications: rawCerts.whereType<String>().toList(),
      enabledSports: rawSports.whereType<String>().toList(),
      storefront: rawStorefront != null
          ? ClubStorefront.fromJson(rawStorefront)
          : null,
    );
  }
}
