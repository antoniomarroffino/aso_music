class Album {
  final String id;
  final String name;
  final String coverURL;
  final String artist;
  final String description;
  final String releaseYear;

  Album({
    required this.id,
    required this.name,
    required this.coverURL,
    required this.artist,
    required this.description,
    required this.releaseYear,
  });

  factory Album.fromMap(Map<String, dynamic> map, String id) {
    return Album(
      id: id,
      name: map['name']?.toString() ?? '',
      coverURL: map['coverURL']?.toString() ?? '',
      artist: map['artist']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      releaseYear: map['releaseYear']?.toString() ??
          '', // Forziamo la conversione a String
    );
  }

  @override
  String toString() {
    return 'Album{id: $id, name: $name, coverURL: $coverURL, artist: $artist, description: $description, releaseYear: $releaseYear}';
  }
}
