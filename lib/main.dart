import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/album_viewmodel.dart';
import 'viewmodels/song_viewmodel.dart';
import 'views/album_list_screen.dart';
import 'views/song_player_screen.dart';
import 'views/login_screen.dart'; // Importa la tua pagina di login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlbumViewModel()),
        ChangeNotifierProvider(create: (_) => SongViewModel()),
      ],
      child: MaterialApp(
        title: 'Music App',
        theme: ThemeData(
          primarySwatch:
              Colors.yellow, // Usa il colore giallo per il tema principale
        ),
        initialRoute: '/login', // Imposta la pagina di login come iniziale
        routes: {
          '/login': (context) =>
              LoginScreen(), // Aggiungi la route per la pagina di login
          '/': (context) => AlbumListScreen(),
          '/player': (context) => SongPlayerScreen(),
        },
      ),
    );
  }
}
