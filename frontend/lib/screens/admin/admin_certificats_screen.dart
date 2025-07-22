import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/certificat_model.dart';
import '../../models/user_model.dart';

class AdminCertificatsScreen extends StatelessWidget {
  const AdminCertificatsScreen({super.key});

  // 🔁 Fonction pour récupérer les infos de l'habitant via son ID
  Future<UserModel?> fetchHabitant(String habitantId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(habitantId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Certificats générés")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('certificats')
            .orderBy('dateDemande', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun certificat disponible."));
          }

          final certificatsDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: certificatsDocs.length,
            itemBuilder: (context, index) {
              final certifMap = certificatsDocs[index].data() as Map<String, dynamic>;
              final certif = Certificat.fromMap(certifMap, certificatsDocs[index].id);

              return FutureBuilder<UserModel?>(
                future: fetchHabitant(certif.habitantId),
                builder: (context, userSnapshot) {
                  final habitant = userSnapshot.data;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: const Icon(Icons.verified_user, color: Colors.blue),
                      title: habitant != null
                          ? Text("${habitant.name}")
                          : Text("Utilisateur inconnu (${certif.habitantId})"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date : ${DateFormat('dd/MM/yyyy').format(certif.dateDemande)}"),
                          Text("Statut : ${certif.statut}"),
                          if (certif.dateValidation != null)
                            Text("Validé le : ${DateFormat('dd/MM/yyyy').format(certif.dateValidation!)}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        onPressed: () async {
                          if (certif.fichierPDF.isNotEmpty) {
                            final uri = Uri.parse(certif.fichierPDF);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Impossible d’ouvrir le fichier PDF.")),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
