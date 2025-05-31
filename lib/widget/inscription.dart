import 'package:flutter/material.dart'; // Import du package Flutter pour l'UI
import 'package:typewritertext/typewritertext.dart'; // Import pour l'effet machine à écrire
import 'package:eduria/widget/confirmation.dart'; // Import de la page de confirmation

// Déclaration du widget d'inscription (formulaire)
class Inscription extends StatefulWidget {
  const Inscription({Key? key}) : super(key: key); // Constructeur

  @override
  _InscriptionState createState() =>
      _InscriptionState(); // Création de l'état associé
}

// Classe d'état pour Inscription
class _InscriptionState extends State<Inscription> {
  final _formKey =
      GlobalKey<FormState>(); // Clé pour gérer l'état du formulaire

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF), // Couleur de fond de la page
      body: Padding(
        padding:
            const EdgeInsets.all(30.0), // Marge intérieure autour du formulaire
        child: Form(
          key: _formKey, // Clé du formulaire pour la validation
          child: ListView(
            children: [
              const SizedBox(height: 40), // Espace en haut
              TypeWriter.text(
                'Create your account', // Titre avec effet machine à écrire
                duration: Duration(milliseconds: 100), // Vitesse de l'effet
                style: TextStyle(
                  fontSize: 28, // Taille du texte
                  fontWeight: FontWeight.bold, // Texte en gras
                  color: Color(0xFF3F3A54), // Couleur du texte
                ),
              ),
              const SizedBox(height: 70), // Espace sous le titre
              const TextField(
                // Champ pour le nom d'utilisateur
                decoration: InputDecoration(
                  labelText: 'Username', // Label du champ
                  icon: Icon(
                    Icons.person, // Icône utilisateur
                    color: Color(0xFFA079FF), // Couleur de l'icône
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Istok', // Police du label
                    color: Colors.grey, // Couleur du label
                  ),
                  border: UnderlineInputBorder(), // Bordure du champ
                ),
              ),
              const SizedBox(height: 20), // Espace entre les champs
              const TextField(
                // Champ pour l'email
                decoration: InputDecoration(
                  labelText: 'Email', // Label du champ
                  icon: Icon(
                    Icons.email, // Icône email
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true, // Cache le texte (mot de passe)
                decoration: InputDecoration(
                  labelText: 'password', // Label du champ
                  icon: Icon(
                    Icons.lock, // Icône cadenas
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true, // Cache le texte (confirmation mot de passe)
                decoration: InputDecoration(
                  labelText: 'Confirm the password', // Label du champ
                  icon: Icon(
                    Icons.lock, // Icône cadenas
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                // Champ pour l'âge
                decoration: InputDecoration(
                  labelText: 'old', // Label du champ
                  icon: Icon(
                    Icons.calendar_today, // Icône calendrier
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                // Champ pour le pays
                decoration: InputDecoration(
                  labelText: 'country', // Label du champ
                  icon: Icon(
                    Icons.location_on, // Icône localisation
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30), // Espace avant le bouton
              SizedBox(
                width: double.infinity, // Le bouton prend toute la largeur
                child: ElevatedButton(
                  onPressed: () {
                    // Action lors du clic sur le bouton
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ConfirmationPage(), // Redirige vers la page de confirmation
                        ));
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
                    'register', // Texte du bouton
                    style: TextStyle(
                      fontSize: 18, // Taille du texte
                      color: Color(0xFF3F3A54), // couleur du texte
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Espace sous le bouton
              TextButton(
                onPressed: () {
                  // rediriger vers page de connexion (à compléter)
                },
                child: const Text(
                  'already have an account ? Log in', // Texte du lien
                  style:
                      TextStyle(color: Color(0xFFA079FF)), // Couleur du texte
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
