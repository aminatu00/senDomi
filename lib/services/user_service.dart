import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ajouter un utilisateur
  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      print("Utilisateur ajouté avec succès");
    } catch (e) {
      print("Erreur lors de l'ajout de l'utilisateur: $e");
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<UserModel>> getUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs: $e");
      return [];
    }
  }

  // Récupérer un utilisateur par son UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur: $e");
      return null;
    }
  }

  // Modifier un utilisateur
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      print("Utilisateur mis à jour avec succès");
    } catch (e) {
      print("Erreur lors de la mise à jour de l'utilisateur: $e");
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print("Utilisateur supprimé avec succès");
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur: $e");
    }
  }
}
