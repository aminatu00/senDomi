import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/proprietaire.dart';
import '../../services/firestore_service.dart';

class AjouterProprietaireScreen extends StatefulWidget {
  final ProprietaireModel? proprietaire;

  const AjouterProprietaireScreen({this.proprietaire});

  @override
  State<AjouterProprietaireScreen> createState() => _AjouterProprietaireScreenState();
}

class _AjouterProprietaireScreenState extends State<AjouterProprietaireScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final telephoneController = TextEditingController();
  final lieuNaissanceController = TextEditingController();

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.proprietaire != null) {
      final p = widget.proprietaire!;
      nomController.text = p.nom;
      prenomController.text = p.prenom;
      emailController.text = p.email;
      telephoneController.text = p.telephone;
      lieuNaissanceController.text = p.lieuNaissance;
      selectedDate = DateFormat('yyyy-MM-dd').parse(p.dateNaissance);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void enregistrerProprietaire() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      final proprietaire = ProprietaireModel(
        id: widget.proprietaire?.id ?? '',
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        email: emailController.text.trim(),
        telephone: telephoneController.text.trim(),
        dateNaissance: DateFormat('yyyy-MM-dd').format(selectedDate!),
        lieuNaissance: lieuNaissanceController.text.trim(),
      );

      if (widget.proprietaire != null) {
        await FirestoreService().updateProprietaire(proprietaire);
      } else {
        await FirestoreService().addProprietaire(proprietaire);
      }

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    lieuNaissanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.proprietaire == null
            ? "Ajouter un Propriétaire"
            : "Modifier un Propriétaire"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: lieuNaissanceController,
                decoration: InputDecoration(labelText: 'Lieu de naissance'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  selectedDate == null
                      ? 'Sélectionner une date de naissance'
                      : 'Date de naissance : ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: enregistrerProprietaire,
                child: Text(widget.proprietaire == null ? "Ajouter" : "Modifier"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
