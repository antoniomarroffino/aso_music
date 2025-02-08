import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'views/login_view.dart';
import 'views/home_view.dart';
import 'utilities/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inizializza Firebase
  runApp(const ASOMusicApp());
}

class ASOMusicApp extends StatelessWidget {
  const ASOMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASO MUSIC',
      theme: appTheme, // Definiamo il tema nell'area utilities
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Ascolta i cambiamenti nello stato di autenticazione
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostra un indicatore di caricamento mentre si attende la connessione
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // Gestisci eventuali errori
          return const Scaffold(
            body: Center(child: Text('Si è verificato un errore')),
          );
        } else if (snapshot.hasData) {
          // Se l'utente è autenticato, mostra la HomeView
          return const HomeView();
        } else {
          // Se l'utente non è autenticato, mostra la LoginView
          return const LoginView();
        }
      },
    );
  }
}
