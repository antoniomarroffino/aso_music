class Artist {
  final String id;
  final String name;
  final String bio;
  final String profileURL;

  Artist({
    required this.id,
    required this.name,
    required this.bio,
    required this.profileURL,
  });

  factory Artist.fromMap(Map<String, dynamic> map, String id) {
    return Artist(
      id: id,
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      profileURL: map['profileURL'] ?? '',
    );
  }
}
