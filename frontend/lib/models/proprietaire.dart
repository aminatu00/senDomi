class ProprietaireModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String dateNaissance;
  final String lieuNaissance;

  ProprietaireModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.dateNaissance,
    required this.lieuNaissance,
  });

  // Convertir un document Firestore en ProprietaireModel
  factory ProprietaireModel.fromMap(Map<String, dynamic> data, String docId) {
    return ProprietaireModel(
      id: docId,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      email: data['email'] ?? '',
      telephone: data['telephone'] ?? '',
      dateNaissance: data['dateNaissance'] ?? '',
      lieuNaissance: data['lieuNaissance'] ?? '',
    );
  }

  // Convertir ProprietaireModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'dateNaissance': dateNaissance,
      'lieuNaissance': lieuNaissance,
    };
  }
}
