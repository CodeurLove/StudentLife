import 'package:flutter/material.dart';
import 'package:eduria/widget/connexionpage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  connexion())); // Redirige vers la page de connexion après 3 secondes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F1FF), // fond clair
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/UCAO.png', // Assurez-vous que le chemin de l'image est correct
              width: 200, // Ajustez la taille selon vos besoins
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
