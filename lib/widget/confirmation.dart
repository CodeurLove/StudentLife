import 'package:flutter/material.dart'; // Import du package Flutter pour l'UI
import 'package:pinput/pinput.dart'; // Import du package Pinput pour le champ PIN
import 'package:eduria/application/acceuil.dart'; // Import de la page d'accueil

// Déclaration de la page de confirmation
class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({Key? key}) : super(key: key); // Constructeur

  @override
  _ConfirmationPageState createState() =>
      _ConfirmationPageState(); // Création de l'état associé
}

// Classe d'état pour ConfirmationPage
class _ConfirmationPageState extends State<ConfirmationPage> {
  final TextEditingController _pinController =
      TextEditingController(); // Contrôleur pour le champ PIN
  final FocusNode _pinFocusNode =
      FocusNode(); // FocusNode pour gérer le focus du champ PIN

  @override
  void dispose() {
    _pinController.dispose(); // Libère les ressources du contrôleur PIN
    _pinFocusNode.dispose(); // Libère les ressources du focus node
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Définition du thème par défaut pour le champ PIN
    final defaultPinTheme = PinTheme(
      width: 56, // Largeur de chaque case du PIN
      height: 56, // Hauteur de chaque case du PIN
      textStyle: const TextStyle(
        fontSize: 22, // Taille du texte du PIN
        color: Color(0xFF3F3A54), // Couleur du texte
        fontWeight: FontWeight.w600, // Poids du texte
      ),
      decoration: BoxDecoration(
        color: Colors.white, // Couleur de fond de chaque case
        borderRadius: BorderRadius.circular(10), // Coins arrondis
        border: Border.all(color: const Color(0xFF3F3A54)), // Bordure
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF), // Couleur de fond de la page
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Marge intérieure
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centre verticalement
            children: [
              const Text(
                'Confirmation code', // Titre principal
                style: TextStyle(
                  fontSize: 24, // Taille du titre
                  fontWeight: FontWeight.bold, // Texte en gras
                  color: Color(0xFF3F3A54), // Couleur du texte
                ),
              ),
              const SizedBox(height: 50), // Espace vertical
              const Text(
                'Enter the 4-digit code sent to your email address.', // Sous-titre
                textAlign: TextAlign.center, // Centrage du texte
                style: TextStyle(color: Colors.black54), // Couleur du texte
              ),
              const SizedBox(height: 40), // Espace vertical
              Pinput(
                controller: _pinController, // Contrôleur du champ PIN
                focusNode: _pinFocusNode, // FocusNode du champ PIN
                length: 4, // Nombre de chiffres du code PIN
                showCursor: true, // Affiche le curseur
                defaultPinTheme: defaultPinTheme, // Thème défini plus haut
                onCompleted: (value) {
                  // Valider le code ici (à compléter selon la logique)
                },
              ),
              const SizedBox(height: 40), // Espace vertical
              SizedBox(
                width: double.infinity, // Le bouton prend toute la largeur
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        )); // Redirection vers la page d'accueil après validation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFA079FF), // Couleur du bouton
                    padding: const EdgeInsets.symmetric(
                        vertical: 15), // Padding vertical
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Coins arrondis
                    ),
                  ),
                  child: const Text(
                    'Valider', // Texte du bouton
                    style: TextStyle(
                        fontSize: 18, color: Colors.white), // Style du texte
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
