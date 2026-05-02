import 'package:flutter/material.dart';
import 'package:eduria/splash.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Locales.init(
    ['fr', 'en', 'es', 'de', 'it', 'pt', 'zh', 'ja', 'ko', 'ru', 'ar'],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        title: 'StudentLife',
        theme: ThemeData(
          fontFamily: 'jura',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF3FE),
        ),
        home: SplashScreen(),
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
      ),
    );
  }
}
