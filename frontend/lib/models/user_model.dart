import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final String role;
  final String maisonId;
  final String quartierId;
  final String proprietaireId;
  final DateTime dateNaissance;
  final String? photoUrl; // ✅ Champ photo de profil

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.role = 'user',
    required this.maisonId,
    required this.quartierId,
    required this.proprietaireId,
    required this.dateNaissance,
    this.photoUrl, // ✅ Ajout dans le constructeur
  });

  /// ✅ Méthode copyWith
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    DateTime? createdAt,
    String? role,
    String? maisonId,
    String? quartierId,
    String? proprietaireId,
    DateTime? dateNaissance,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      maisonId: maisonId ?? this.maisonId,
      quartierId: quartierId ?? this.quartierId,
      proprietaireId: proprietaireId ?? this.proprietaireId,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isChef => role == 'chef';
  bool get isUser => role == 'user';

  /// ✅ Convertit l'objet en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
      'maisonId': maisonId,
      'quartierId': quartierId,
      'proprietaireId': proprietaireId,
      'dateNaissance': Timestamp.fromDate(dateNaissance),
      'photoUrl': photoUrl,
    };
  }

  /// ✅ Crée un UserModel à partir d'une Map Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      final createdAtRaw = map['createdAt'];
      final dateNaissanceRaw = map['dateNaissance'];

      return UserModel(
        uid: map['uid'],
        email: map['email'],
        name: map['name'],
        createdAt: createdAtRaw is Timestamp
            ? createdAtRaw.toDate()
            : DateTime.parse(createdAtRaw),
        role: map['role'] ?? 'user',
        maisonId: map['maisonId'] ?? '',
        quartierId: map['quartierId'] ?? '',
        proprietaireId: map['proprietaireId'] ?? '',
        dateNaissance: dateNaissanceRaw is Timestamp
            ? dateNaissanceRaw.toDate()
            : DateTime.parse(dateNaissanceRaw),
        photoUrl: map['photoUrl'],
      );
    } catch (e) {
      print("❌ Erreur dans UserModel.fromMap: $e");
      rethrow;
    }
  }

  /// ✅ Crée un UserModel à partir d'un utilisateur Firebase
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'Inconnu',
      createdAt: DateTime.now(),
      role: 'user',
      maisonId: '',
      quartierId: '',
      proprietaireId: '',
      dateNaissance: DateTime(2000, 1, 1),
      photoUrl: user.photoURL,
    );
  }

  /// ✅ Crée un chef de quartier
  factory UserModel.chef({
    required String uid,
    required String email,
    required String name,
    required String quartierId,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      createdAt: DateTime.now(),
      role: 'chef',
      maisonId: '',
      quartierId: quartierId,
      proprietaireId: '',
      dateNaissance: DateTime(1980, 1, 1),
      photoUrl: photoUrl,
    );
  }
}
