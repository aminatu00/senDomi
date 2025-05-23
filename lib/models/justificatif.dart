class Justificatif {
  final String id;
  final String habitantId;
  final String type; // eau, loyer, bail, etc.
  final String fichierURL;
  final DateTime dateDepot;
  final DateTime valideJusquau;
  final String statut; // "en_attente", "valide", "rejete"
  final String? motifRejet;

  Justificatif({
    required this.id,
    required this.habitantId,
    required this.type,
    required this.fichierURL,
    required this.dateDepot,
    required this.valideJusquau,
    required this.statut,
    this.motifRejet,
  });

  factory Justificatif.fromMap(Map<String, dynamic> map, String id) {
    return Justificatif(
      id: id,
      habitantId: map['habitantId'],
      type: map['type'],
      fichierURL: map['fichierURL'],
      dateDepot: DateTime.parse(map['dateDepot']),
      valideJusquau: DateTime.parse(map['valideJusquau']),
      statut: map['statut'],
      motifRejet: map['motifRejet'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'habitantId': habitantId,
      'type': type,
      'fichierURL': fichierURL,
      'dateDepot': dateDepot.toIso8601String(),
      'valideJusquau': valideJusquau.toIso8601String(),
      'statut': statut,
      'motifRejet': motifRejet,
    };
  }
}
