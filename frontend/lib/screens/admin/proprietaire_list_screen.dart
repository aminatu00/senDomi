import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/proprietaire.dart';
import '../../models/user_model.dart';

class ProprietaireDetailScreen extends StatefulWidget {
  final ProprietaireModel proprietaire;
  final Color primaryColor = const Color(0xFF1D6DAA);
  final Color accentColor = const Color(0xFF4FC3F7);

  const ProprietaireDetailScreen({required this.proprietaire});

  @override
  _ProprietaireDetailScreenState createState() =>
      _ProprietaireDetailScreenState();
}

class _ProprietaireDetailScreenState extends State<ProprietaireDetailScreen> {
  late Future<List<UserModel>> _habitantsFuture;

  @override
  void initState() {
    super.initState();
    _habitantsFuture = _loadHabitants();
  }

  Future<List<UserModel>> _loadHabitants() async {
    final firestore = FirebaseFirestore.instance;

    // Étape 1 : Récupérer les maisons liées au propriétaire
    final maisonsSnapshot = await firestore
        .collection('maisons')
        .where('proprietaireId', isEqualTo: widget.proprietaire.id)
        .get();

    final maisonIds = maisonsSnapshot.docs.map((doc) => doc.id).toList();

    if (maisonIds.isEmpty) return [];

    // Étape 2 : Récupérer les utilisateurs liés à ces maisons
    final usersSnapshot = await firestore
        .collection('users')
        .where('maisonId', whereIn: maisonIds)
        .where('role', isEqualTo: 'user')
        .get();

    return usersSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: widget.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitantCard(UserModel user) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: widget.primaryColor.withOpacity(0.2),
          child: Icon(Icons.person, color: widget.primaryColor),
        ),
        title: Text(user.name),
        subtitle: Text(
            user.dateNaissance != null
                ? "Né(e) le ${user.dateNaissance.toLocal().toString().split(' ')[0]}"
                : "Date inconnue",
            style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proprietaire;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Propriétaire", style: TextStyle(color: Colors.white)),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, widget.accentColor.withOpacity(0.05)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte du propriétaire
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.primaryColor.withOpacity(0.1),
                            border: Border.all(
                                color: widget.primaryColor, width: 2),
                          ),
                          child: Icon(Icons.person,
                              size: 60, color: widget.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow("Nom complet", "${p.nom} ${p.prenom}",
                          Icons.person_outline),
                      const Divider(height: 1),
                      _buildDetailRow("Téléphone", p.telephone, Icons.phone),
                      const Divider(height: 1),
                      if (p.email.isNotEmpty)
                        _buildDetailRow("Email", p.email, Icons.email),
                      if (p.dateNaissance.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildDetailRow(
                            "Date de naissance", p.dateNaissance, Icons.cake),
                      ],
                      if (p.lieuNaissance.isNotEmpty) ...[
                        const Divider(height: 1),
                        _buildDetailRow("Lieu de naissance", p.lieuNaissance,
                            Icons.place),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                "👥 Habitants de la/les maison(s)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor),
              ),
              const SizedBox(height: 8),

              FutureBuilder<List<UserModel>>(
                future: _habitantsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text(
                      "Erreur de chargement des habitants.",
                      style: TextStyle(color: Colors.red.shade700),
                    );
                  } else if (snapshot.data!.isEmpty) {
                    return Text("Aucun habitant enregistré.",
                        style: TextStyle(color: Colors.grey.shade600));
                  } else {
                    return Column(
                      children:
                          snapshot.data!.map(_buildHabitantCard).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
