class Album {
  final String id;
  final String title;
  final String artist;

  Album({required this.id, required this.title, required this.artist});

  // Metodo per convertire i dati da Firebase in un oggetto Album
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
    );
  }
}
