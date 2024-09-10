import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/album_viewmodel.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

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
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Imposta l'indice della tab attiva
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/albumlist');
              break;
            case 1:
              Navigator.pushNamed(
                  context, '/search'); // Aggiungi il percorso per la ricerca
              break;
            case 2:
              Navigator.pushNamed(
                  context, '/profile'); // Aggiungi il percorso per il profilo
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
