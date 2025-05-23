import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final maisonIdController = TextEditingController(); // Ajout de l'ID de la maison
  final quartierIdController = TextEditingController(); // Ajout de l'ID du quartier
  final proprietaireIdController = TextEditingController(); // Ajout de l'ID du propriétaire

  String message = "";

  Future<void> registerUser() async {
    String? error = await AuthService().registerUserWithData(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
      maisonIdController.text.trim(), // ID de la maison
      quartierIdController.text.trim(), // ID du quartier
      proprietaireIdController.text.trim(), // ID du propriétaire
    );

    if (error != null) {
      setState(() => message = error);
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Mot de passe"),
            ),
            TextField(
              controller: maisonIdController,
              decoration: InputDecoration(labelText: "ID de la maison"),
            ),
            TextField(
              controller: quartierIdController,
              decoration: InputDecoration(labelText: "ID du quartier"),
            ),
            TextField(
              controller: proprietaireIdController,
              decoration: InputDecoration(labelText: "ID du propriétaire"),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: Text("S'inscrire")),
            Text(
              message.isNotEmpty ? message : "",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
