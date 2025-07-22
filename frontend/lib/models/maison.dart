class MaisonModel {
  final String id;
  final String adresse;
  final String quartierId;
  final String proprietaireId; // 👈 Ajoute ceci

  MaisonModel({
    required this.id,
    required this.adresse,
    required this.quartierId,
    required this.proprietaireId, // 👈 N'oublie pas ici
  });

  factory MaisonModel.fromMap(Map<String, dynamic> map, String docId) {
    return MaisonModel(
      id: docId,
      adresse: map['adresse'] ?? '',
      quartierId: map['quartierId'] ?? '',
      proprietaireId: map['proprietaireId'] ?? '', // 👈 Et ici
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adresse': adresse,
      'quartierId': quartierId,
      'proprietaireId': proprietaireId, // 👈 Et ici aussi
    };
  }
}
