import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import necessario
import '../utilities/constants.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
// Non è necessario importare 'home_view.dart' poiché la navigazione è gestita dal StreamBuilder

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controller per gli input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthController _authController = AuthController();

  bool _isLoading = false; // Indica se l'operazione di login è in corso

  // Metodo per gestire il login
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Per favore, inserisci email e password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authController.signInWithEmail(email, password);

      if (user != null) {
        // Login riuscito
        // Non è necessario navigare manualmente; il StreamBuilder nel main.dart gestirà la navigazione
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login effettuato con successo')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gestione degli errori specifici
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Nessun utente trovato con questa email.';
          break;
        case 'wrong-password':
          errorMessage = 'Password errata.';
          break;
        case 'invalid-email':
          errorMessage = 'L\'email non è valida.';
          break;
        default:
          errorMessage = 'Errore durante il login.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Gestione di altri tipi di errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore sconosciuto durante il login')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Pulisci i controller quando il widget viene smontato
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const SizedBox(height: 40.0),
              // Bottone di Login o Indicatore di Caricamento
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
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
                          const Text('Login', style: TextStyle(fontSize: 18.0)),
                    ),
              const SizedBox(height: 20.0),
              // Link per la Registrazione
              TextButton(
                onPressed: () {
                  // Naviga alla schermata di registrazione
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterView()),
                  );
                },
                child: const Text(
                  'Non hai un account? Registrati',
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
