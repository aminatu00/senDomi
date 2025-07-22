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
  DateTime? selectedDateNaissance;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    quartiers = await _firestoreService.getQuartiers();
    maisons = await _firestoreService.getMaisons();
    proprietaires = await _firestoreService.getProprietaires();
    setState(() {});
  }

  Future<void> _selectDateNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateNaissance = picked;
      });
    }
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate() && selectedDateNaissance != null) {
      // Trouver la maison sélectionnée
final maison = maisons.firstWhere((m) => m.id == selectedMaisonId);

// Récupérer automatiquement les IDs liés
final quartierId = maison.quartierId;
final proprietaireId = maison.proprietaireId;

     final user = UserModel(
  uid: FirebaseFirestore.instance.collection('users').doc().id,
  name: _nameController.text.trim(),
  email: _emailController.text.trim(),
  createdAt: DateTime.now(),
  role: 'user',
  maisonId: selectedMaisonId ?? '',
  quartierId: quartierId,
  proprietaireId: proprietaireId,
  dateNaissance: selectedDateNaissance!,
);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(user.toMap())
          .then((value) => print("Utilisateur ajouté"))
          .catchError((error) => print("Erreur : $error"));

      Navigator.pop(context);
    } else if (selectedDateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez sélectionner la date de naissance")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un Habitant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Nom"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Veuillez entrer un nom" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Veuillez entrer un email" : null,
              ),
              SizedBox(height: 16),

              // Sélecteur de date de naissance
              ListTile(
                title: Text(
                  selectedDateNaissance == null
                      ? "Sélectionner la date de naissance"
                      : "Date de naissance : ${selectedDateNaissance!.day}/${selectedDateNaissance!.month}/${selectedDateNaissance!.year}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDateNaissance(context),
              ),
              SizedBox(height: 10),

              // Dropdown Quartier
              // DropdownButtonFormField<String>(
              //   value: selectedQuartierId,
              //   decoration: InputDecoration(labelText: 'Quartier'),
              //   items: quartiers.map((q) {
              //     return DropdownMenuItem(
              //       value: q.id,
              //       child: Text(q.nom),
              //     );
              //   }).toList(),
              //   onChanged: (value) => setState(() => selectedQuartierId = value),
              //   validator: (value) =>
              //       value == null ? 'Veuillez sélectionner un quartier' : null,
              // ),
              // SizedBox(height: 10),

              // Dropdown Maison
              DropdownButtonFormField<String>(
                value: selectedMaisonId,
                decoration: InputDecoration(labelText: 'Maison'),
                items: maisons.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(m.adresse),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedMaisonId = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner une maison' : null,
              ),
              SizedBox(height: 10),

              // Dropdown Propriétaire
              // DropdownButtonFormField<String>(
              //   value: selectedProprietaireId,
              //   decoration: InputDecoration(labelText: 'Propriétaire'),
              //   items: proprietaires.map((p) {
              //     return DropdownMenuItem(
              //       value: p.id,
              //       child: Text("${p.nom} ${p.prenom}"),
              //     );
              //   }).toList(),
              //   onChanged: (value) => setState(() => selectedProprietaireId = value),
              //   validator: (value) =>
              //       value == null ? 'Veuillez sélectionner un propriétaire' : null,
              // ),
              // SizedBox(height: 20),

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
