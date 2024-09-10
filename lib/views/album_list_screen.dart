import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/album_viewmodel.dart';

class AlbumListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final albumViewModel = Provider.of<AlbumViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Albums")),
      body: FutureBuilder(
        future: albumViewModel.fetchAlbums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: albumViewModel.albums.length,
            itemBuilder: (context, index) {
              final album = albumViewModel.albums[index];
              return ListTile(
                title: Text(album.title),
                subtitle: Text(album.artist),
                onTap: () {
                  Navigator.pushNamed(context, '/player', arguments: album.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
