import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminJustificatifsScreen extends StatelessWidget {
  const AdminJustificatifsScreen({Key? key}) : super(key: key);

  Future<void> _validerDemande(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('demandes').doc(docId).update({
      'etat': 'validée',
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Demande validée.")),
    );
  }

  Future<void> _annulerDemande(BuildContext context, String docId) async {
    TextEditingController motifController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("❌ Motif d'annulation"),
        content: TextField(
          controller: motifController,
          decoration: InputDecoration(hintText: "Entrez le motif"),
        ),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Confirmer"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('demandes')
                  .doc(docId)
                  .update({
                'etat': 'annulée',
                'motif_annulation': motifController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Demande annulée.")),
              );
            },
          ),
        ],
      ),
    );
  }

  void _afficherDetailsDemande(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("📄 Détails de la demande"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📌 Raison : ${data['raison']}"),
              Text("📅 Validité : ${data['date_validite']}"),
              Text("📍 État : ${data['etat']}"),
              SizedBox(height: 20),

              Text("🆔 CIN :", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildFileWidget(data['cin_url']),

              SizedBox(height: 20),

              Text("📎 Justificatif :", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildFileWidget(data['justificatif_url']),

              if (data['motif_annulation'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "❗ Motif d'annulation : ${data['motif_annulation']}",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("Fermer"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

Widget _buildFileWidget(String? url) {
  if (url == null || url.isEmpty) {
    return Text("⚠️ Aucun fichier disponible.");
  }

  final isImage = url.endsWith(".png") || url.endsWith(".jpg") || url.endsWith(".jpeg");

  if (isImage) {
    return SizedBox(
      height: 200,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text("❌ Erreur lors du chargement de l'image."));
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  } else {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("❌ Impossible de lancer l'URL : $url");
        }
      },
      child: Row(
        children: [
          Icon(Icons.attach_file, color: Colors.blue),
          SizedBox(width: 8),
          Flexible(child: Text("Ouvrir le fichier", style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demandes à valider")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('demandes')
            .where('etat', isEqualTo: 'en cours')
            .orderBy('date_creation', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("❌ Erreur de chargement"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) return Center(child: Text("Aucune demande en attente."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                key: ValueKey(doc.id),
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("📌 Raison : ${data['raison']}"),
                  subtitle: Text("État : ${data['etat']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () => _afficherDetailsDemande(context, data),
                      ),
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _validerDemande(context, doc.id),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _annulerDemande(context, doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
