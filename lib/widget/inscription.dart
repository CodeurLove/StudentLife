import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final _firstnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _obscureAdmin = true;
  bool _isAdmin = false;
  bool _isLoading = false;

  // Couleurs et Styles
  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);
  final Color borderColor = const Color.fromARGB(178, 45, 58, 141);
  final TextStyle juraBold =
      const TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold);

  @override
  void dispose() {
    _firstnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Vérifications de base
    if (_firstnameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError("Veuillez remplir tous les champs.");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Les mots de passe ne correspondent pas.");
      return;
    }

    // Vérification mot de passe admin
    if (_isAdmin) {
      final adminPass = _adminPasswordController.text.trim();
      if (adminPass.isEmpty) {
        _showError("Entrez le mot de passe administrateur.");
        return;
      }

      // Vérifier dans Firestore si le mot de passe admin est valide
      final snap = await FirebaseFirestore.instance
          .collection('adminpassword')
          .where('passwordHash', isEqualTo: adminPass)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _showError("Mot de passe administrateur incorrect.");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Créer le compte Firebase Auth
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // Sauvegarder dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstname': _firstnameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _isAdmin ? 'club_admin' : 'student',
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Compte créé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Une erreur est survenue.";
      if (e.code == 'email-already-in-use') {
        message = "Cet email est déjà utilisé.";
      } else if (e.code == 'weak-password') {
        message = "Mot de passe trop faible (min. 6 caractères).";
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
      backgroundColor: lavenderBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset('assets/UCAO.png', height: 40),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "S'enregistrer",
                style: juraBold.copyWith(fontSize: 32, color: darkBlue),
              ),
              const SizedBox(height: 40),

              // Champs
              _buildField(hint: "Firstname", controller: _firstnameController),
              const SizedBox(height: 15),
              _buildField(hint: "Email", controller: _emailController),
              const SizedBox(height: 15),
              _buildField(
                hint: "Password",
                controller: _passwordController,
                isPass: true,
                obscure: _obscurePass,
                onToggle: () => setState(() => _obscurePass = !_obscurePass),
              ),
              const SizedBox(height: 15),
              _buildField(
                hint: "Confirm Password",
                controller: _confirmPasswordController,
                isPass: true,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 15),

              // Choix Admin / Étudiant
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Je suis administrateur",
                        style: TextStyle(
                            fontFamily: 'Jura',
                            color: darkBlue.withOpacity(0.6))),
                    Switch(
                      value: _isAdmin,
                      activeColor: burgundy,
                      onChanged: (val) => setState(() => _isAdmin = val),
                    ),
                  ],
                ),
              ),

              // Champ mot de passe admin (visible seulement si _isAdmin)
              if (_isAdmin) ...[
                const SizedBox(height: 15),
                _buildField(
                  hint: "Mot de passe administrateur",
                  controller: _adminPasswordController,
                  isPass: true,
                  obscure: _obscureAdmin,
                  onToggle: () =>
                      setState(() => _obscureAdmin = !_obscureAdmin),
                ),
              ],

              const SizedBox(height: 40),

              // Bouton S'enregistrer
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: burgundy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("S'enregistrer",
                          style: juraBold.copyWith(
                              fontSize: 20, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 25),
              _buildDivider(),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/google.png', height: 35)),
                  const SizedBox(width: 30),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset('assets/vector.png', height: 40)),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Do You Have An Account? ",
                      style: juraBold.copyWith(
                          color: darkBlue,
                          fontWeight: FontWeight.normal,
                          fontSize: 13)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0)),
                    child: Text("Sign In",
                        style: juraBold.copyWith(
                            color: const Color(0xFFB04C4C), fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    bool isPass = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass ? obscure : false,
      style: juraBold.copyWith(fontWeight: FontWeight.normal, color: darkBlue),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: darkBlue.withOpacity(0.4), fontFamily: 'Jura'),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        suffixIcon: isPass
            ? IconButton(
                icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: borderColor),
                onPressed: onToggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: burgundy, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: borderColor.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("Or",
              style: TextStyle(color: borderColor, fontFamily: 'Jura')),
        ),
        Expanded(child: Divider(color: borderColor.withOpacity(0.5))),
      ],
    );
  }
}
