import 'package:flutter/material.dart';

class Sidemenu extends StatefulWidget {
  const Sidemenu({super.key});

  @override
  State<Sidemenu> createState() => _SidemenuState();
}

class _SidemenuState extends State<Sidemenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 250,
        height: double.infinity,
        color: const Color(0xFFF5F2FF),
        child: SafeArea(
            child: Column(
          children: [
            const SizedBox(height: 20), // Espace en haut du menu
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            const SizedBox(height: 20), // Espace entre l'avatar et le texte
            Text(
              'Eduria',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3F3A54),
              ),
            ),
            const SizedBox(height: 20), // Espace entre le texte et les boutons
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF3F3A54)),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context); // Ferme le menu
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF3F3A54)),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context); // Ferme le menu
              },
            ),
            ListTile(
              leading: const Icon(Icons.info,
                  color: Color(0xFF3F3A54)), // Icône d'information
              title: const Text('À propos'),
              onTap: () {
                Navigator.pop(context); // Ferme le menu
              },
            ),
          ],
        )), // Couleur de fond du menu
      ),
    );
  }
}
