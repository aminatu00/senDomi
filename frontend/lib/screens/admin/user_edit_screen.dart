import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../models/quartier.dart';
import '../../models/maison.dart';
import '../../models/proprietaire.dart';

class UserEditScreen extends StatefulWidget {
  final UserModel user;

  UserEditScreen({required this.user});

  @override
  _UserEditScreenState createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

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
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    selectedDateNaissance = widget.user.dateNaissance; // Initialiser la date de naissance

    // Charger les données
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    quartiers = await _firestoreService.getQuartiers();
    maisons = await _firestoreService.getMaisons();
    proprietaires = await _firestoreService.getProprietaires();

    setState(() {
      selectedQuartierId = widget.user.quartierId;
      selectedMaisonId = widget.user.maisonId;
      selectedProprietaireId = widget.user.proprietaireId;
    });
  }

  Future<void> _selectDateNaissance(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateNaissance ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDateNaissance = picked;
      });
    }
  }

  void _updateUser() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = UserModel(
        uid: widget.user.uid, // Utiliser l'UID existant
        name: _nameController.text,
        email: _emailController.text,
        createdAt: widget.user.createdAt,
        role: widget.user.role, // Conserver le rôle existant
        maisonId: selectedMaisonId!,
        quartierId: selectedQuartierId!,
        proprietaireId: selectedProprietaireId!,
        dateNaissance: selectedDateNaissance!, // Mettre à jour la date de naissance
      );

      await _firestoreService.updateUser(updatedUser);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier un Habitants")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ Nom
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
              // Champ Email
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

              // Liste déroulante Quartier
              // DropdownButtonFormField<String>(
              //   value: selectedQuartierId,
              //   decoration: InputDecoration(labelText: 'Quartier'),
              //   items: quartiers.map((q) {
              //     return DropdownMenuItem(
              //       value: q.id,
              //       child: Text(q.nom), // ou autre champ
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedQuartierId = value;
              //     });
              //   },
              //   validator: (value) =>
              //       value == null ? 'Veuillez sélectionner un quartier' : null,
              // ),
              // // Liste déroulante Maison
              DropdownButtonFormField<String>(
                value: selectedMaisonId,
                decoration: InputDecoration(labelText: 'Maison'),
                items: maisons.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(m.adresse), // ou autre champ
                  );
                }).toList(),
              onChanged: (value) {
  setState(() {
    selectedMaisonId = value;

    // Mettre à jour automatiquement quartierId et proprietaireId
    final maison = maisons.firstWhere((m) => m.id == value);
    selectedQuartierId = maison.quartierId;
    selectedProprietaireId = maison.proprietaireId;
  });
},
 validator: (value) =>
                    value == null ? 'Veuillez sélectionner une maison' : null,
              ),
              // Liste déroulante Propriétaire
              // DropdownButtonFormField<String>(
              //   value: selectedProprietaireId,
              //   decoration: InputDecoration(labelText: 'Propriétaire'),
              //   items: proprietaires.map((p) {
              //     return DropdownMenuItem(
              //       value: p.id,
              //       child: Text("${p.nom} ${p.prenom}"), // ou autre champ
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedProprietaireId = value;
              //     });
              //   },
              //   validator: (value) =>
              //       value == null ? 'Veuillez sélectionner un propriétaire' : null,
              // ),
              // SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text("Mettre à jour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
