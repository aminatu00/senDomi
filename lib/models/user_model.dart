class UserModel {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final String role; // Le rôle de l'utilisateur (ex: 'admin', 'user', etc.)
  final String maisonId; // L'ID de la maison associée à l'utilisateur
  final String quartierId; // L'ID du quartier associé à la maison
  final String proprietaireId; // L'ID du propriétaire de la maison

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.role = 'user',
    required this.maisonId,
    required this.quartierId,
    required this.proprietaireId,
  });

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
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
      role: map['role'] ?? 'user',
      maisonId: map['maisonId'],
      quartierId: map['quartierId'],
      proprietaireId: map['proprietaireId'],
    );
  }
}
