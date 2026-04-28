import 'package:flutter/material.dart';

void main() => runApp(const connexion());

class connexion extends StatelessWidget {
  const connexion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Couleurs personnalisées basées sur l'image
    const Color bgColor = Color(0xFFF9F3FF); // Fond lavande très clair
    const Color buttonColor = Color(0xFF8B2323); // Rouge bordeaux
    const Color inputBorderColor = Color(0xFFC5B4E3);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 70),
            // Logo (Remplacez par Image.asset('assets/logo.png'))
            Center(
              child: Image.asset(
                'assets/UCAO.png', // Assurez-vous que le chemin de l'image est correct
                width: 70,
                height: 70,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Se Connecter',
              style: TextStyle(
                fontFamily: 'jura',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B448F), // Bleu foncé
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            // Champ Email
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(
                    fontFamily: 'jura', color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: buttonColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Champ Mot de passe
            TextField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(
                  fontFamily: 'jura',
                  color: Color(0xFF9E9E9E),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  color: const Color(0xFF3B448F),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: inputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: buttonColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Bouton Se Connecter
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Se Connecter',
                  style: TextStyle(
                      fontFamily: 'jura',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Séparateur "Or"
            const Row(
              children: [
                Expanded(child: Divider(thickness: 1, color: inputBorderColor)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Or',
                      style: TextStyle(fontFamily: 'jura', color: Colors.grey)),
                ),
                Expanded(child: Divider(thickness: 1, color: inputBorderColor)),
              ],
            ),
            const SizedBox(height: 30),
            // Social Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Image.asset('assets/google.png', height: 40),
                ),
                const SizedBox(width: 40),
                IconButton(
                  onPressed: () {},
                  icon: Image.asset('assets/vector.png', height: 40),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Sign Up Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("You Don't Have An Account? ",
                    style: TextStyle(
                        color: Color(0xFF3B448F), fontFamily: 'jura')),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                        color: Color(0xFFB04C4C),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'jura'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
