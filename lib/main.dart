import 'package:aso_music/views/profile_screen.dart';
import 'package:aso_music/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/album_viewmodel.dart';
import 'viewmodels/song_viewmodel.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/album_list_screen.dart';
import 'views/song_player_screen.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlbumViewModel()),
        ChangeNotifierProvider(create: (_) => SongViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aso Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/albumlist': (context) => const AlbumListScreen(),
        '/player': (context) => SongPlayerScreen(),
        '/search': (context) =>
            SearchScreen(), // Aggiungi il percorso per la schermata di ricerca
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
