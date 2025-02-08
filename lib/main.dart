import 'package:aso_music/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'views/login_view.dart';
import 'utilities/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize(); // Se utilizzi Firebase
  runApp(ASOMusicApp());
}

class ASOMusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASO MUSIC',
      theme: appTheme, // Definiamo il tema nell'area utilities
      home: LoginView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
