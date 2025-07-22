import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaisonListScreen extends StatefulWidget {
  @override
  State<MaisonListScreen> createState() => _MaisonListScreenState();
}

class _MaisonListScreenState extends State<MaisonListScreen> {
  final TextEditingController _adresseController = TextEditingController();
  String? _selectedQuartierId;
  String? _selectedProprietaireId;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _quartiers = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _proprietaires = [];

  @override
  void initState() {
    super.initState();
    _chargerQuartiers();
    _chargerProprietaires();
  }

  Future<void> _chargerQuartiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('quartiers').get();
    setState(() {
      _quartiers = snapshot.docs;
    });
  }

  Future<void> _chargerProprietaires() async {
    final snapshot = await FirebaseFirestore.instance.collection('proprietaires').get();
    setState(() {
      _proprietaires = snapshot.docs;
    });
  }

  Future<void> _ajouterMaison() async {
    final adresse = _adresseController.text.trim();
    if (adresse.isNotEmpty && _selectedQuartierId != null && _selectedProprietaireId != null) {
      await FirebaseFirestore.instance.collection('maisons').add({
        'adresse': adresse,
        'quartierId': _selectedQuartierId,
        'proprietaireId': _selectedProprietaireId,
      });
      _adresseController.clear();
    }
  }

  Future<void> _modifierMaison(String id, Map<String, dynamic> data) async {
    _adresseController.text = data['adresse'] ?? '';
    _selectedQuartierId = data['quartierId'] ?? '';  // Assurez-vous que ce champ n'est pas null
    _selectedProprietaireId = data['proprietaireId'] ?? '';  // Idem ici

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Modifier Maison"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: "Adresse"),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedQuartierId,
                  items: _quartiers.map((quartier) {
                    return DropdownMenuItem(
                      value: quartier.id,
                      child: Text(quartier['nom'] ?? 'Inconnu'),  // Ajouter 'Inconnu' si 'nom' est null
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedQuartierId = val;
                    });
                  },
                  decoration: InputDecoration(labelText: "Quartier"),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedProprietaireId,
                  items: _proprietaires.map((prop) {
                    return DropdownMenuItem(
                      value: prop.id,
                      child: Text("${prop['nom']} ${prop['prenom']}"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProprietaireId = val;
                    });
                  },
                  decoration: InputDecoration(labelText: "Propriétaire"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _adresseController.clear();
              },
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final nouvelleAdresse = _adresseController.text.trim();
                if (nouvelleAdresse.isNotEmpty && _selectedQuartierId != null && _selectedProprietaireId != null) {
                  await FirebaseFirestore.instance.collection('maisons').doc(id).update({
                    'adresse': nouvelleAdresse,
                    'quartierId': _selectedQuartierId,
                    'proprietaireId': _selectedProprietaireId,
                  });
                  Navigator.pop(ctx);
                  _adresseController.clear();
                }
              },
              child: Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _supprimerMaison(String id) async {
    await FirebaseFirestore.instance.collection('maisons').doc(id).delete();
  }

  String _getNomQuartier(String? id) {
    try {
      final q = _quartiers.firstWhere((e) => e.id == id);
      return q['nom'] ?? 'Inconnu';  // Retourne 'Inconnu' si 'nom' est null
    } catch (_) {
      return 'Inconnu';
    }
  }

  String _getNomProprietaire(String? id) {
    try {
      final p = _proprietaires.firstWhere((e) => e.id == id);
      return "${p['nom']} ${p['prenom']}";
    } catch (_) {
      return 'Inconnu';
    }
  }

  void _showAjoutMaisonDialog() {
    _adresseController.clear();
    _selectedQuartierId = null;
    _selectedProprietaireId = null;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Ajouter une Maison"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: "Adresse"),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedQuartierId,
                  items: _quartiers.map((quartier) {
                    return DropdownMenuItem(
                      value: quartier.id,
                      child: Text(quartier['nom'] ?? 'Inconnu'),  // Ajouter 'Inconnu' si 'nom' est null
                    );
                  }).toList(),
                  hint: Text("Sélectionner un quartier"),
                  onChanged: (val) {
                    setState(() {
                      _selectedQuartierId = val;
                    });
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedProprietaireId,
                  items: _proprietaires.map((prop) {
                    return DropdownMenuItem(
                      value: prop.id,
                      child: Text("${prop['nom']} ${prop['prenom']}"),
                    );
                  }).toList(),
                  hint: Text("Sélectionner un propriétaire"),
                  onChanged: (val) {
                    setState(() {
                      _selectedProprietaireId = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _ajouterMaison();
                Navigator.pop(ctx);
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Maisons")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('maisons').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final maisons = snapshot.data!.docs;

          if (maisons.isEmpty) return Center(child: Text("Aucune maison enregistrée."));

          return ListView.builder(
            itemCount: maisons.length,
            itemBuilder: (context, index) {
              final maison = maisons[index];
              final data = maison.data();
              final quartierNom = _getNomQuartier(data['quartierId']);
              final proprietaireNom = _getNomProprietaire(data['proprietaireId']);

              return ListTile(
                title: Text(data['adresse']),
                subtitle: Text("Quartier : $quartierNom\nPropriétaire : $proprietaireNom"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _modifierMaison(maison.id, data),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _supprimerMaison(maison.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAjoutMaisonDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
