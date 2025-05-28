import 'package:flutter/material.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:eduria/widget/confirmation.dart';

class Inscription extends StatefulWidget {
  const Inscription({Key? key}) : super(key: key);

  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1FF),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 60),
              TypeWriter.text(
                'Create your account',
                duration: Duration(milliseconds: 100),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3A54),
                ),
              ),
              const SizedBox(height: 70),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  icon: Icon(
                    Icons.person,
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Istok',
                    color: Colors.grey,
                  ),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(
                    Icons.email,
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'password',
                  icon: Icon(
                    Icons.lock,
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm the password',
                  icon: Icon(
                    Icons.lock,
                    color: Color(0xFFA079FF),
                  ),
                  labelStyle:
                      TextStyle(fontFamily: 'Istok', color: Colors.grey),
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConfirmationPage(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA079FF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'register',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF3F3A54), // couleur du texte
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // rediriger vers page de connexion
                },
                child: const Text(
                  'already have an account ? Log in',
                  style: TextStyle(color: Color(0xFFA079FF)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
