import 'package:flutter/material.dart'; // Import du package Flutter pour l'UI
import 'package:flutter_locales/flutter_locales.dart'; // Import pour la gestion des langues/locales

// Déclaration de la page de paramètres de langue
class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key); // Constructeur

  // Liste des langues disponibles avec leur nom et code
  final List<Map<String, String>> languages = const [
    {'name': 'Français', 'code': 'fr'}, // Français
    {'name': 'English', 'code': 'en'}, // Anglais
    {'name': 'Español', 'code': 'es'}, // Espagnol
    {'name': 'Deutsch', 'code': 'de'}, // Allemand
    {'name': 'Italiano', 'code': 'it'}, // Italien
    {'name': 'Português', 'code': 'pt'}, // Portugais
    {'name': '中文 (Chinese)', 'code': 'zh'}, // Chinois
    {'name': '日本語 (Japanese)', 'code': 'ja'}, // Japonais
    {'name': '한국어 (Korean)', 'code': 'ko'}, // Coréen
    {'name': 'Русский (Russian)', 'code': 'ru'}, // Russe
    {'name': 'العربية (Arabic)', 'code': 'ar'}, // Arabe
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText('languages'), // Titre localisé de l'appbar
        backgroundColor: Colors.white, // Couleur de fond de l'appbar
        elevation: 1, // Légère ombre sous l'appbar
        foregroundColor:
            Colors.black, // Couleur du texte et des icônes de l'appbar
      ),
      backgroundColor: const Color(0xFFF5F5F5), // Couleur de fond de la page
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12), // Marge verticale
        itemCount: languages.length, // Nombre d'éléments dans la liste
        separatorBuilder: (_, __) =>
            const Divider(height: 1), // Séparateur entre chaque langue
        itemBuilder: (context, index) {
          final lang = languages[index]; // Récupère la langue à cet index
          return ListTile(
            title: Text(
              lang['name']!, // Affiche le nom de la langue
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Texte en gras
                fontSize: 16, // Taille du texte
              ),
            ),
            onTap: () async {
              await Locales.change(
                  context, lang['code']!); // Change la langue de l'app
              Navigator.pop(context); // Ferme la page après sélection
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20), // Marge horizontale
          );
        },
      ),
    );
  }
}
