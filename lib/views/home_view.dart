import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import '../controllers/album_controller.dart';
import '../models/album.dart';
import '../widgets/album_card.dart';
import '../utilities/constants.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController _authController = AuthController();
    final AlbumController _albumController = AlbumController();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text(
          'ASO MUSIC',
          style: TextStyle(color: primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: primaryColor),
            onPressed: () async {
              await _authController.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Album>>(
        stream: _albumController.getAlbums(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
            print('Stack trace: ${snapshot.stackTrace}');
            return Center(
              child: Text(
                'Errore: ${snapshot.error}',
                style: const TextStyle(color: primaryColor),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }

          final albums = snapshot.data ?? [];

          if (albums.isEmpty) {
            return const Center(
              child: Text(
                'Nessun album disponibile',
                style: TextStyle(color: primaryColor),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio:
                  0.8, // Modificato per dare spazio al testo sotto l'immagine quadrata
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              print('Building card for album: $album'); // Debug print
              return AlbumCard(album: album);
            },
          );
        },
      ),
    );
  }
}
