import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DemandesAdresseAdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demandes de changement d'adresse")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('demandes_adresse')
            .where('statut', isEqualTo: 'en attente')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final demandes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: demandes.length,
            itemBuilder: (context, index) {
              final demande = demandes[index];
              return ListTile(
                title: Text(demande['nom']),
                subtitle: Text("Motif: ${demande['motif']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check, color: Colors.green),
                      onPressed: () => _accepterDemande(demande),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () => _refuserDemande(demande),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _accepterDemande(DocumentSnapshot demande) async {
    final userId = demande['userId'];
    final nouveauQuartierId = demande['nouveauQuartierId'];

    // Modifier le quartier de l'utilisateur
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'quartierId': nouveauQuartierId,
    });

    // Mettre à jour la demande comme "acceptée"
    await demande.reference.update({'statut': 'acceptée'});
  }

  Future<void> _refuserDemande(DocumentSnapshot demande) async {
    await demande.reference.update({'statut': 'refusée'});
  }
}
