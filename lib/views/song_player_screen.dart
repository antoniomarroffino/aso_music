import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/song_viewmodel.dart';

class SongPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final albumId = ModalRoute.of(context)!.settings.arguments as String;
    final songViewModel = Provider.of<SongViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Player")),
      body: FutureBuilder(
        future: songViewModel.fetchSongs(albumId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: songViewModel.songs.length,
            itemBuilder: (context, index) {
              final song = songViewModel.songs[index];
              return ListTile(
                title: Text(song.title),
                onTap: () async {
                  final songUrl = await songViewModel.getSongUrl(song.id);
                  // Logica per riprodurre la canzone, es. con un player esterno
                  print("Riproduzione canzone da URL: $songUrl");
                },
              );
            },
          );
        },
      ),
    );
  }
}
