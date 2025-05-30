import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> languages = const [
    {'name': 'Français', 'code': 'fr'},
    {'name': 'English', 'code': 'en'},
    {'name': 'Español', 'code': 'es'},
    {'name': 'Deutsch', 'code': 'de'},
    {'name': 'Italiano', 'code': 'it'},
    {'name': 'Português', 'code': 'pt'},
    {'name': '中文 (Chinese)', 'code': 'zh'},
    {'name': '日本語 (Japanese)', 'code': 'ja'},
    {'name': '한국어 (Korean)', 'code': 'ko'},
    {'name': 'Русский (Russian)', 'code': 'ru'},
    {'name': 'العربية (Arabic)', 'code': 'ar'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText('languages'),
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
            onTap: () async {
              await Locales.change(context, lang['code']!);
              Navigator.pop(context);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          );
        },
      ),
    );
  }
}
