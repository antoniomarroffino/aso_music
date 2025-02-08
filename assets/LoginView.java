import 'package:flutter/material.dart';
import '../utilities/constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controller per gli input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Metodo per gestire il login
  void _login() {
    // Implementa la logica di autenticazione
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
                backgroundImage: AssetImage('assets/images/logo.png'),
              ),
              const SizedBox(height: 50.0),
              // Campo Email
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(Icons.email, color: primaryColor),
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
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              // Bottone di Login
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: backgroundColor,
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18.0)),
              ),
              const SizedBox(height: 20.0),
              // Link per la Registrazione
              TextButton(
                onPressed: () {
                  // Naviga alla schermata di registrazione
                },
                child: Text(
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