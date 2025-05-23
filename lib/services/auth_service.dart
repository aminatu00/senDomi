import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inscription d'un utilisateur avec les données supplémentaires (maison, quartier, propriétaire)
  Future<String?> registerUserWithData(
    String email,
    String password,
    String name,
    String maisonId, // ID de la maison
    String quartierId, // ID du quartier
    String proprietaireId, // ID du propriétaire
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
      );

      // Enregistrer l'utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toMap());

      return null;
    } catch (e) {
      return e.toString(); // Retourner l'erreur s'il y en a une
    }
  }

  // Récupérer les informations de l'utilisateur
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Erreur Firestore : $e");
    }
    return null;
  }
}
