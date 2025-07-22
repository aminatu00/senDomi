import 'package:cloud_firestore/cloud_firestore.dart';

class HabitantModel {
  final String id;
  final String nom;
  final String prenom;
  final String maisonId;
  final String quartierId;
  final String email;
  final String telephone;
  final DateTime dateNaissance; // ✅ ajout

  HabitantModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.maisonId,
    required this.quartierId,
    required this.email,
    required this.telephone,
    required this.dateNaissance, // ✅ ajout
  });

  factory HabitantModel.fromMap(Map<String, dynamic> data, String docId) {
    return HabitantModel(
      id: docId,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      maisonId: data['maisonId'] ?? '',
      quartierId: data['quartierId'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      dateNaissance: (data['dateNaissance'] as Timestamp).toDate(), // ✅ conversion Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'maisonId': maisonId,
      'quartierId': quartierId,
      'email': email,
      'telephone': telephone,
      'dateNaissance': Timestamp.fromDate(dateNaissance), // ✅ conversion pour Firestore
    };
  }
}
