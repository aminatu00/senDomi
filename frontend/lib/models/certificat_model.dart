class Certificat {
  final String id;
  final String habitantId;
  final String demandeId;
  final DateTime dateDemande;
  final String statut; // "en_attente", "valide", "rejete"
  final String fichierPDF;
  final DateTime? dateValidation;
  final String? chefId; // Ajout du champ chefId
  final bool estDetruit; // Ajout du champ estDetruit

  Certificat({
    required this.id,
    required this.habitantId,
    required this.demandeId,
    required this.dateDemande,
    required this.statut,
    required this.fichierPDF,
    this.dateValidation,
    this.chefId,
    this.estDetruit = false, // Par défaut, le certificat n'est pas détruit
  });

  // Méthode pour créer un objet Certificat à partir des données de Firestore
  factory Certificat.fromMap(Map<String, dynamic> data, String docId) {
    return Certificat(
      id: docId,
      habitantId: data['habitantId'] ?? '',
      demandeId: data['demandeId'] ?? '',
      dateDemande: DateTime.tryParse(data['dateDemande'] ?? '') ?? DateTime.now(),
      statut: data['statut'] ?? 'en_attente',
      fichierPDF: data['fichierPDF'] ?? '',
      dateValidation: data['dateValidation'] != null
          ? DateTime.tryParse(data['dateValidation'])
          : null,
      chefId: data['chefId'],
      estDetruit: data['estDetruit'] ?? false, // Lecture du champ estDetruit
    );
  }

  // Méthode pour convertir un objet Certificat en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'habitantId': habitantId,
      'demandeId': demandeId,
      'dateDemande': dateDemande.toIso8601String(),
      'statut': statut,
      'fichierPDF': fichierPDF,
      'dateValidation': dateValidation?.toIso8601String(),
      'chefId': chefId,
      'estDetruit': estDetruit, // Écriture du champ estDetruit
    };
  }
}
