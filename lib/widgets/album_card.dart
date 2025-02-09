import 'package:flutter/material.dart';
import '../models/album.dart';
import '../utilities/constants.dart';
import '../services/firebase_service.dart';
import '../views/album_detail_view.dart';

class AlbumCard extends StatelessWidget {
  final Album album;

  const AlbumCard({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailView(album: album),
          ),
        );
      },
      child: Card(
        color: Colors.black87,
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wrapper per mantenere l'immagine quadrata
            AspectRatio(
              aspectRatio: 1, // Forza un rapporto 1:1 (quadrato)
              child: FutureBuilder<String>(
                future: FirebaseService().getDownloadURL(album.coverURL),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    print('Error loading image: ${snapshot.error}');
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: primaryColor,
                        size: 32.0,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: primaryColor,
                        size: 32.0,
                      ),
                    );
                  }

                  return Image.network(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('Network image error: $error');
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: primaryColor,
                          size: 32.0,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                album.name,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
