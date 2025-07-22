import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/proprietaire.dart';
import '../../models/user_model.dart';

class ProprietaireDetailScreen extends StatefulWidget {
  final ProprietaireModel proprietaire;
  
  const ProprietaireDetailScreen({required this.proprietaire});

  @override
  _ProprietaireDetailScreenState createState() => _ProprietaireDetailScreenState();
}

class _ProprietaireDetailScreenState extends State<ProprietaireDetailScreen> {
  late Future<List<UserModel>> _habitantsFuture;
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran

  @override
  void initState() {
    super.initState();
    _habitantsFuture = _loadHabitants();
  }

  Future<List<UserModel>> _loadHabitants() async {
    final firestore = FirebaseFirestore.instance;

    // Trouver la maison du propriétaire
    final maisonQuery = await firestore
        .collection('maisons')
        .where('proprietaireId', isEqualTo: widget.proprietaire.id)
        .limit(1)
        .get();

    if (maisonQuery.docs.isEmpty) {
      return [];
    }

    final maisonId = maisonQuery.docs.first.id;

    // Trouver les habitants de cette maison
    final usersSnapshot = await firestore
        .collection('users')
        .where('maisonId', isEqualTo: maisonId)
        .where('role', isEqualTo: 'user')
        .get();

    return usersSnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.1),
            ),
            child: Icon(icon, size: 20, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitantCard(UserModel user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [primaryColor.withOpacity(0.3), primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.person, size: 20, color: Colors.white),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          "Né(e) le ${user.dateNaissance.toLocal().toString().split(' ')[0]}",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.proprietaire;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              backgroundColor: primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Détails du Propriétaire",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        secondaryColor,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.person, size: 150, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte du propriétaire
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person, size: 48, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow("Nom complet", "${p.nom} ${p.prenom}", Icons.person_outline),
                      _buildDetailRow("Téléphone", p.telephone, Icons.phone),
                      if (p.email.isNotEmpty) 
                        _buildDetailRow("Email", p.email, Icons.email),
                      if (p.dateNaissance.isNotEmpty) 
                        _buildDetailRow("Date de naissance", p.dateNaissance, Icons.cake),
                      if (p.lieuNaissance.isNotEmpty) 
                        _buildDetailRow("Lieu de naissance", p.lieuNaissance, Icons.place),
                    ],
                  ),
                ),
              ),

              // Section habitants
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Habitants de cette maison",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              FutureBuilder<List<UserModel>>(
                future: _habitantsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Text(
                            "Erreur de chargement des habitants",
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.people_alt_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "Aucun habitant enregistré",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: snapshot.data!.map(_buildHabitantCard).toList(),
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