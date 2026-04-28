import 'package:flutter/material.dart';
import 'package:eduria/splash.dart';
import 'package:flutter_locales/flutter_locales.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Locales.init(
    ['fr', 'en', 'es', 'de', 'it', 'pt', 'zh', 'ja', 'ko', 'ru', 'ar'],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        title: 'StudentLife',
        theme: ThemeData(
          fontFamily: 'jura',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
              //color: Color(0xFF3F3A54), // Couleur de texte sombre
              fontSize: 30,
            ),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF3FE), // fond clair
        ),
        home: SplashScreen(),
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
      ),
    );
  }
}
