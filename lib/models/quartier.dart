class Quartier {
  final String id;
  final String nom;

  Quartier({required this.id, required this.nom});

  factory Quartier.fromMap(Map<String, dynamic> map, String id) {
    return Quartier(
      id: id,
      nom: map['nom'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'nom': nom,
      };
}
