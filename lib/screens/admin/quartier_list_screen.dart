import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuartierListScreen extends StatefulWidget {
  @override
  State<QuartierListScreen> createState() => _QuartierListScreenState();
}

class _QuartierListScreenState extends State<QuartierListScreen> {
  final TextEditingController _nomController = TextEditingController();

  Future<void> _ajouterQuartier() async {
    String nom = _nomController.text.trim();
    if (nom.isNotEmpty) {
      await FirebaseFirestore.instance.collection('quartiers').add({'nom': nom});
      _nomController.clear();
    }
  }

  Future<void> _modifierQuartier(String id, String ancienNom) async {
    _nomController.text = ancienNom;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Modifier Quartier"),
        content: TextField(controller: _nomController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('quartiers').doc(id).update({
                'nom': _nomController.text.trim(),
              });
              Navigator.pop(ctx);
              _nomController.clear();
            },
            child: Text("Modifier"),
          ),
        ],
      ),
    );
  }

  Future<void> _supprimerQuartier(String id) async {
    await FirebaseFirestore.instance.collection('quartiers').doc(id).delete();
  }

  void _showAjoutDialog(BuildContext context) {
    _nomController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Ajouter Quartier"),
        content: TextField(
          controller: _nomController,
          decoration: InputDecoration(labelText: "Nom du quartier"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _ajouterQuartier();
              Navigator.pop(ctx);
            },
            child: Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Quartiers")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('quartiers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final quartiers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: quartiers.length,
            itemBuilder: (context, index) {
              final doc = quartiers[index];
              return Card(
                child: ListTile(
                  title: Text(doc['nom']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _modifierQuartier(doc.id, doc['nom']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _supprimerQuartier(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAjoutDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
