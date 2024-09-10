import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/album_viewmodel.dart';
import 'viewmodels/song_viewmodel.dart';
import 'views/album_list_screen.dart';
import 'views/song_player_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AlbumListScreen(),
          '/player': (context) => SongPlayerScreen(),
        },
      ),
    );
  }
}
