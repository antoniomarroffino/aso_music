import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import necessario
import '../utilities/constants.dart';
import '../controllers/auth_controller.dart';
// Non è necessario importare 'home_view.dart' in questa versione

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Controller per gli input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthController _authController = AuthController();

  // Metodo per gestire la registrazione
  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      // Mostra un messaggio di errore se le password non coincidono
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le password non coincidono')),
      );
      return;
    }

    try {
      // Chiamata al metodo di registrazione
      User? user = await _authController.signUpWithEmail(email, password);

      if (user != null) {
        // Registrazione riuscita
        // Non è necessario navigare manualmente alla HomeView
        // Il StreamBuilder in main.dart si occuperà di cambiare la vista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registrazione effettuata con successo')),
        );
        Navigator.pop(context); // Torna alla schermata di login
      }
    } on FirebaseAuthException catch (e) {
      // Gestione degli errori specifici
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'L\'email è già in uso.';
          break;
        case 'invalid-email':
          errorMessage = 'L\'email non è valida.';
          break;
        case 'weak-password':
          errorMessage = 'La password è troppo debole.';
          break;
        default:
          errorMessage = 'Errore durante la registrazione.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Gestione di altri tipi di errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Errore sconosciuto durante la registrazione')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Evita l'AppBar per una schermata a schermo intero
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 80.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundColor, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nome dell'App
              Text(
                'ASO MUSIC',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 20.0),
              // Logo circolare dell'app
              CircleAvatar(
                radius: 60.0,
                backgroundImage: const AssetImage('assets/images/logo.png'),
              ),
              const SizedBox(height: 50.0),
              // Campo Email
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: primaryColor),
                  prefixIcon: const Icon(Icons.email, color: primaryColor),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: primaryColor),
                  prefixIcon: const Icon(Icons.lock, color: primaryColor),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // Conferma Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Conferma Password',
                  labelStyle: const TextStyle(color: primaryColor),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: primaryColor),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              // Bottone di Registrazione
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  foregroundColor: backgroundColor,
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child:
                    const Text('Registrati', style: TextStyle(fontSize: 18.0)),
              ),
              const SizedBox(height: 20.0),
              // Link per il Login
              TextButton(
                onPressed: () {
                  // Naviga alla schermata di login
                  Navigator.pop(context);
                },
                child: const Text(
                  'Hai già un account? Accedi',
                  style: TextStyle(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
