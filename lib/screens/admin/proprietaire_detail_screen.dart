import 'package:flutter/material.dart';
import '../../models/proprietaire.dart';

class ProprietaireDetailScreen extends StatelessWidget {
  final ProprietaireModel proprietaire;

  const ProprietaireDetailScreen({required this.proprietaire});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détails du Propriétaire")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${proprietaire.nom}", style: TextStyle(fontSize: 18)),
            Text("Prénom : ${proprietaire.prenom}", style: TextStyle(fontSize: 18)),
            Text("Téléphone : ${proprietaire.telephone}", style: TextStyle(fontSize: 18)),
            // Ajoute plus de champs si nécessaire
          ],
        ),
      ),
    );
  }
}