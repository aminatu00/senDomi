import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'admin/admin_home_screen.dart';
import 'chefQuartier/chef_home_screen.dart';
import 'habitant/user_home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final UserModel user;

  const WelcomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? error;

  @override
  void initState() {
    super.initState();
    _redirectBasedOnRole();
  }

  void _redirectBasedOnRole() async {
    await Future.delayed(Duration(seconds: 2)); // petit délai pour montrer le loader

    if (widget.user.isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminHomeScreen(user: widget.user)),
      );
    } else if (widget.user.isChef) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChefQuartierHomeScreen(user: widget.user)),
      );
    } else if (widget.user.isUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserHomeScreen(user: widget.user)),
      );
    } else {
      // Rôle inconnu
      setState(() {
        error = "Rôle utilisateur inconnu : '${widget.user.role}'";
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Se déconnecter",
          ),
        ],
      ),
      body: Center(
        child: error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    child: Text("Retour à la page de connexion"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Connexion en cours pour ${widget.user.name}...",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
