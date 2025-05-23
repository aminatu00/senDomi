import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../login_screen.dart';

class UserHomeScreen extends StatelessWidget {
  final UserModel user;
  const UserHomeScreen({required this.user});

  // Fonction de déconnexion
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false, // Empêche de revenir en arrière
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Espace Habitant"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context), // Déconnexion
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Bienvenue ${user.name}",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
