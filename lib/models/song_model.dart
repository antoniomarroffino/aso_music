class Song {
  final String id;
  final String title;
  final String albumId;
  final String url;

  Song(
      {required this.id,
      required this.title,
      required this.albumId,
      required this.url});

  // Metodo per convertire i dati da Firebase in un oggetto Song
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      albumId: json['albumId'],
      url: json['url'],
    );
  }
}
