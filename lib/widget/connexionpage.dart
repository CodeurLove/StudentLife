import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:eduria/widget/inscription.dart';

class Connexion extends StatefulWidget {
  const Connexion({Key? key}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FF), // Couleur de fond douce
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TypeWriter.text(
                "Welcome to Eduria",
                duration: const Duration(milliseconds: 100),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3A54),
                  fontFamily: 'Istok',
                ),
              ),
              const SizedBox(height: 150),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.email,
                    color: Color(0xFFA079FF),
                  ),
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Istok',
                  ),
                  //filled: true,
                  //fillColor: Colors.white,
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.lock,
                    color: Color(0xFFA079FF),
                  ),
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Istok',
                  ),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // TODO: Intégrer la logique de connexion
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA079FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Se connecter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Inscription()),
                  );
                },
                child: const Text(
                  "Create an account",
                  style: TextStyle(color: Color(0xFFA079FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
