import 'package:flutter/material.dart';
import '../utilities/constants.dart';

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

  // Metodo per gestire la registrazione
  void _register() {
    // Implementa la logica di registrazione
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
              const SizedBox(height: 20.0),
              // Conferma Password
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Conferma Password',
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
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
                child: Text(
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
