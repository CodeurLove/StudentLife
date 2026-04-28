import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Couleurs et Styles
  final Color burgundy = const Color(0xFF8B2323);
  final Color darkBlue = const Color(0xFF3B448F);
  final Color lavenderBg = const Color(0xFFFFF3FE);
  final Color borderColor = const Color.fromARGB(178, 45, 58, 141);
  final TextStyle juraBold =
      const TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold);

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
              // Header : Bouton Retour + Logo à droite
              const SizedBox(height: 20),
              Text(
                "S'enregistrer",
                style: juraBold.copyWith(fontSize: 32, color: darkBlue),
              ),

              const SizedBox(height: 40),

              // Liste des champs
              _buildField(hint: "Firstname"),
              const SizedBox(height: 15),
              _buildField(hint: "Email"),
              const SizedBox(height: 15),
              _buildField(
                  hint: "Password",
                  isPass: true,
                  obscure: _obscurePass,
                  onToggle: () => setState(() => _obscurePass = !_obscurePass)),
              const SizedBox(height: 15),
              _buildField(
                  hint: "Confirm Password",
                  isPass: true,
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm)),
              const SizedBox(height: 15),
              _buildField(hint: ""), // Le champ vide du bas

              const SizedBox(height: 40),

              // Bouton S'enregistrer
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: burgundy,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("S'enregistrer",
                      style:
                          juraBold.copyWith(fontSize: 20, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 25),
              _buildDivider(),
              const SizedBox(height: 25),

              // Social Icons
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

              // Footer Sign In
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

  // Widget Helper pour les champs de saisie
  Widget _buildField(
      {required String hint,
      bool isPass = false,
      bool obscure = false,
      VoidCallback? onToggle}) {
    return TextField(
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
