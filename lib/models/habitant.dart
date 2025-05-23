class HabitantModel {
  final String id;
  final String nom;
  final String prenom;
  final String maisonId; // Référence à la maison dans laquelle l'habitant réside
  final String quartierId; // Référence au quartier
  final String email;
  final String telephone;

  HabitantModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.maisonId,
    required this.quartierId,
    required this.email,
    required this.telephone,
  });

  // Convertir un document Firestore en HabitantModel
  factory HabitantModel.fromMap(Map<String, dynamic> data, String docId) {
    return HabitantModel(
      id: docId,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      maisonId: data['maisonId'] ?? '',
      quartierId: data['quartierId'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
    );
  }

  // Convertir HabitantModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'maisonId': maisonId,
      'quartierId': quartierId,
      'email': email,
      'telephone': telephone,
    };
  }
}
