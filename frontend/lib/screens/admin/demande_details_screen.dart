import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DemandeDetailsScreen extends StatelessWidget {
  final String raisonDemande;
  final String dateValidite;
  final String userName;
  final String userEmail;
  final String cinUrl;
  final String justificatifUrl;
  final String demandeId;

  const DemandeDetailsScreen({
    Key? key,
    required this.raisonDemande,
    required this.dateValidite,
    required this.userName,
    required this.userEmail,
    required this.cinUrl,
    required this.justificatifUrl,
    required this.demandeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Affichage ici...
    return Scaffold(
      appBar: AppBar(title: Text("Détails de la demande")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Raison : $raisonDemande"),
            Text("Validité : $dateValidite"),
            Text("Nom : $userName"),
            Text("Email : $userEmail"),
            SizedBox(height: 10),
            Text("CIN URL : $cinUrl"),
            Text("Justificatif URL : $justificatifUrl"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('demandes')
                    .doc(demandeId)
                    .update({'etat': 'validé'});
                Navigator.pop(context);
              },
              child: Text("Valider"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('demandes')
                    .doc(demandeId)
                    .update({'etat': 'refusé'});
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text("Refuser"),
            ),
          ],
        ),
      ),
    );
  }
}
