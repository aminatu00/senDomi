// lib/screens/accueil.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AccueilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenue')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Se connecter'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Créer un compte'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
