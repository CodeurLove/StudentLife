import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduria/widget/inscription.dart';
import 'package:eduria/application/HomePage_student.dart';
import 'package:eduria/application/admin_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const Color bgColor = Color(0xFFFFF3FE);
  static const Color buttonColor = Color(0xFF8B2323);
  static const Color darkBlue = Color(0xFF3B448F);
  static const Color inputBorderColor = Color.fromARGB(178, 45, 58, 141);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("Veuillez remplir tous les champs.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Connexion Firebase Auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // Récupérer le rôle dans Firestore
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      final role = userDoc.data()?['role'] ?? 'student';

      if (!mounted) return;

      // Redirection selon le rôle
      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomePage()),
        );
      } else if (role == 'club_admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Une erreur est survenue.";
      if (e.code == 'user-not-found') {
        message = "Aucun compte trouvé avec cet email.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "Mot de passe incorrect.";
      } else if (e.code == 'invalid-email') {
        message = "Adresse email invalide.";
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Center(
              child: Image.asset('assets/UCAO.png', width: 70, height: 70),
            ),
            const SizedBox(height: 30),
            const Text(
              'Connexion',
              style: TextStyle(
                fontFamily: 'jura',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B448F),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),

            // Champ Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(
                  fontFamily: 'jura',
                  color: Color.fromARGB(115, 45, 58, 141),
                ),
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
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(
                  fontFamily: 'jura',
                  color: Color.fromARGB(115, 45, 58, 141),
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
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
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
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("You Don't Have An Account? ",
                    style: TextStyle(
                        color: Color(0xFF3B448F), fontFamily: 'jura')),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontFamily: 'jura',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB04C4C),
                      fontSize: 14,
                    ),
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
