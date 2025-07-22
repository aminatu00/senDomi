import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inscription d'un utilisateur avec les données supplémentaires
  Future<String?> registerUserWithData(
    String email,
    String password,
    String name,
    String maisonId, 
    String quartierId, 
    String proprietaireId, 
    DateTime dateNaissance, 
    BuildContext context, // Contexte pour la redirection
  ) async {
    try {
      // Création de l'utilisateur avec l'email et le mot de passe
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Créer un modèle d'utilisateur avec les données supplémentaires
      UserModel user = UserModel(
        uid: uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        role: 'user', // Par défaut 'user', mais vous pouvez ajuster cela si nécessaire
        maisonId: maisonId,
        quartierId: quartierId,
        proprietaireId: proprietaireId,
        dateNaissance: dateNaissance,
      );

      // Enregistrer l'utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toMap());

      // Appeler la redirection en fonction du rôle
      await redirectUserByRole(uid, context); // Appel de la redirection après l'inscription

      // Retourner null si tout s'est bien passé
      return null;
    } catch (e) {
      print("Erreur lors de l'inscription : $e");
      return e.toString();
    }
  }

  // Récupérer les informations de l'utilisateur
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("Aucun utilisateur trouvé avec cet UID : $uid");
      }
    } catch (e) {
      print("Erreur Firestore lors de la récupération des données utilisateur : $e");
    }
    return null;
  }

  // Fonction de redirection par rôle
  Future<void> redirectUserByRole(String uid, BuildContext context) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String role = userDoc['role'];
        
        // Redirection en fonction du rôle
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'chef') {
          Navigator.pushReplacementNamed(context, '/chefQuartier');
        } else {
          Navigator.pushReplacementNamed(context, '/user');
        }
      }
    } catch (e) {
      print("Erreur lors de la redirection par rôle : $e");
    }
  }
}
