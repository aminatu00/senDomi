import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/quartier.dart';
import '../../models/maison.dart';
import '../../models/proprietaire.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAddScreen extends StatefulWidget {
  @override
  _UserAddScreenState createState() => _UserAddScreenState();
}

class _UserAddScreenState extends State<UserAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  List<Quartier> quartiers = [];
  List<MaisonModel> maisons = [];
  List<ProprietaireModel> proprietaires = [];

  String? selectedQuartierId;
  String? selectedMaisonId;
  String? selectedProprietaireId;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    quartiers = await _firestoreService.getQuartiers();
    maisons = await _firestoreService.getMaisons();
    proprietaires = await _firestoreService.getProprietaires();
    setState(() {}); // Rafraîchir l’UI
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        uid: FirebaseFirestore.instance.collection('users').doc().id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        createdAt: DateTime.now(),
        role: 'user',
        maisonId: selectedMaisonId ?? '', // Utilisation de l'ID de la maison sélectionnée
        quartierId: selectedQuartierId ?? '', // Utilisation de l'ID du quartier sélectionné
        proprietaireId: selectedProprietaireId ?? '', // Utilisation de l'ID du propriétaire sélectionné
      );

      // Utilisation de la méthode set() pour ajouter le document avec un ID spécifique
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Utilisation de l'UID comme ID du document
          .set(user.toMap())
          .then((value) => print("Utilisateur ajouté"))
          .catchError((error) => print("Échec de l'ajout de l'utilisateur : $error"));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Habitants")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nom"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un nom";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Dropdown pour le quartier avec validation
              DropdownButtonFormField<String>(
                value: selectedQuartierId,
                decoration: InputDecoration(labelText: 'Quartier'),
                items: quartiers.map((q) {
                  return DropdownMenuItem(
                    value: q.id,
                    child: Text(q.nom), // Afficher le nom du quartier
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedQuartierId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un quartier' : null,
              ),
              SizedBox(height: 10),

              // Dropdown pour la maison avec validation
              DropdownButtonFormField<String>(
                value: selectedMaisonId,
                decoration: InputDecoration(labelText: 'Maison'),
                items: maisons.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(m.adresse), // Afficher le numéro de la villa
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMaisonId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une maison' : null,
              ),
              SizedBox(height: 10),

              // Dropdown pour le propriétaire avec validation
              DropdownButtonFormField<String>(
                value: selectedProprietaireId,
                decoration: InputDecoration(labelText: 'Propriétaire'),
                items: proprietaires.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text("${p.nom} ${p.prenom}"), // Afficher le nom et prénom du propriétaire
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProprietaireId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un propriétaire' : null,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveUser,
                child: Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
