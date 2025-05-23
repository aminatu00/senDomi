
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaisonListScreen extends StatefulWidget {
  @override
  State<MaisonListScreen> createState() => _MaisonListScreenState();
}

class _MaisonListScreenState extends State<MaisonListScreen> {
  final TextEditingController _adresseController = TextEditingController();
  String? _selectedQuartierId;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _quartiers = [];
   String? _selectedProprietaireId;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _proprietaires = [];
 


Future<void> _chargerProprietaires() async {
  final snapshot = await FirebaseFirestore.instance.collection('proprietaires').get();
  setState(() {
    _proprietaires = snapshot.docs;
  });
}


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


  Future<void> _modifierMaison(String id, String ancienneAdresse, String ancienQuartierId) async {
    _adresseController.text = ancienneAdresse;
    _selectedQuartierId = ancienQuartierId;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Modifier Maison"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: "Nouvelle adresse"),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedQuartierId,
                items: _quartiers.map((quartier) {
                  return DropdownMenuItem<String>(
                    value: quartier.id,
                    child: Text(quartier['nom']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedQuartierId = val;
                  });
                },
              ),
            ],
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
                if (nouvelleAdresse.isNotEmpty && _selectedQuartierId != null) {
                  await FirebaseFirestore.instance.collection('maisons').doc(id).update({
                    'adresse': nouvelleAdresse,
                    'quartierId': _selectedQuartierId,
                  });
                }
                Navigator.pop(ctx);
                _adresseController.clear();
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _supprimerMaison(String id) async {
    await FirebaseFirestore.instance.collection('maisons').doc(id).delete();
  }

  String _getNomQuartier(String id) {
    try {
      final q = _quartiers.firstWhere((e) => e.id == id);
      return q['nom'];
    } catch (e) {
      return 'Inconnu';
    }
  }

 void _showAjoutMaisonDialog(BuildContext context) {
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
                  return DropdownMenuItem<String>(
                    value: quartier.id,
                    child: Text(quartier['nom']),
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
                  return DropdownMenuItem<String>(
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

              return ListTile(
                title: Text(data['adresse']),
                subtitle: Text("Quartier : $quartierNom"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _modifierMaison(
                        maison.id,
                        data['adresse'],
                        data['quartierId'],
                      ),
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
        onPressed: () => _showAjoutMaisonDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}