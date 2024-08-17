import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BioArtistPage extends StatelessWidget {
  final String artistId;

  const BioArtistPage({super.key, required this.artistId});

  Future<Map<String, dynamic>?> _fetchArtistData() async {
    final firestore = FirebaseFirestore.instance;
    final artistDoc = await firestore.collection('artists').doc(artistId).get();
    return artistDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Bio'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchArtistData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Artist not found'));
          }

          final artistData = snapshot.data!;
          final artistName = artistData['name'] as String;

          return Center(
            child: Text(
              artistName,
              style: Theme.of(context).textTheme.headline4,
            ),
          );
        },
      ),
    );
  }
}
