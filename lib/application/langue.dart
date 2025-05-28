import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final List<Map<String, String>> languages = [
    {
      'name': 'Français',
      'native': 'Français',
    },
    {
      'name': 'English',
      'native': 'English',
    },
    {
      'name': 'Español',
      'native': 'Español',
    },
    {
      'name': 'Deutsch',
      'native': 'Deutsch',
    },
    {
      'name': 'Italiano',
      'native': 'Italiano',
    },
    {
      'name': 'Português',
      'native': 'Português',
    },
    {
      'name': '中文 (Chinese)',
      'native': '中文 (Chinese)',
    },
    {
      'name': '日本語 (Japanese)',
      'native': '日本語 (Japanese)',
    },
    {
      'name': '한국어 (Korean)',
      'native': '한국어 (Korean)',
    },
    {
      'name': 'Русский (Russian)',
      'native': 'Русский (Russian)',
    },
    {
      'name': 'العربية (Arabic)',
      'native': 'العربية (Arabic)',
    },

    // Ajoute toutes les autres langues ici...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All languages'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final lang = languages[index];
          return ListTile(
            title: Text(
              lang['name']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              lang['native']!,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            onTap: () {
              // Action quand on sélectionne une langue
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            //trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          );
        },
      ),
    );
  }
}
