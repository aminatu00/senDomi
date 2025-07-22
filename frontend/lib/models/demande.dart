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
class DemandeModel {
  final String id;
  final String habitantId; // 🔗 Référence à Habitant
  final String raison;
  final String dateValidite;
  final String cinUrl;
  final String justificatifUrl;
  final String etat; // en cours, validée, annulée
  final String? motifAnnulation;

  DemandeModel({
    required this.id,
    required this.habitantId,
    required this.raison,
    required this.dateValidite,
    required this.cinUrl,
    required this.justificatifUrl,
    required this.etat,
    this.motifAnnulation,
  });

  factory DemandeModel.fromMap(Map<String, dynamic> data, String docId) {
    return DemandeModel(
      id: docId,
      habitantId: data['habitantId'] ?? '',
      raison: data['raison'] ?? '',
      dateValidite: data['date_validite'] ?? '',
      cinUrl: data['cin_url'] ?? '',
      justificatifUrl: data['justificatif_url'] ?? '',
      etat: data['etat'] ?? 'en cours',
      motifAnnulation: data['motif_annulation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitantId': habitantId,
      'raison': raison,
      'date_validite': dateValidite,
      'cin_url': cinUrl,
      'justificatif_url': justificatifUrl,
      'etat': etat,
      'motif_annulation': motifAnnulation,
    };
  }
}
