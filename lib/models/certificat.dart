class Certificat {
  final String id;
  final String habitantId;
  final DateTime dateDemande;
  final String statut; // ex: "en_attente", "valide", "rejete"
  final String fichierPDF;
  final DateTime? dateValidation;

  Certificat({
    required this.id,
    required this.habitantId,
    required this.dateDemande,
    required this.statut,
    required this.fichierPDF,
    this.dateValidation,
  });

  factory Certificat.fromMap(Map<String, dynamic> map, String id) {
    return Certificat(
      id: id,
      habitantId: map['habitantId'],
      dateDemande: DateTime.parse(map['dateDemande']),
      statut: map['statut'] ?? 'en_attente',
      fichierPDF: map['fichierPDF'] ?? '',
      dateValidation: map['dateValidation'] != null
          ? DateTime.parse(map['dateValidation'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitantId': habitantId,
      'dateDemande': dateDemande.toIso8601String(),
      'statut': statut,
      'fichierPDF': fichierPDF,
      'dateValidation': dateValidation?.toIso8601String(),
    };
  }
}
