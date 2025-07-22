import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaisonDetailsScreen extends StatefulWidget {
  final String maisonId;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  const MaisonDetailsScreen({super.key, required this.maisonId});

  @override
  State<MaisonDetailsScreen> createState() => _MaisonDetailsScreenState();
}

class _MaisonDetailsScreenState extends State<MaisonDetailsScreen> {
  Map<String, dynamic>? maisonData;
  Map<String, dynamic>? proprietaireData;
  List<Map<String, dynamic>> habitants = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final maisonDoc = await firestore.collection('maisons').doc(widget.maisonId).get();
      if (!maisonDoc.exists) throw Exception("Maison introuvable");

      maisonData = maisonDoc.data();
      final proprietaireId = maisonData?['proprietaireId'];

      if (proprietaireId != null && proprietaireId != "") {
        final propDoc = await firestore.collection('proprietaires').doc(proprietaireId).get();
        if (propDoc.exists) proprietaireData = propDoc.data();
      }

      final habitantsSnapshot = await firestore.collection('users')
          .where('maisonId', isEqualTo: widget.maisonId)
          .get();

      habitants = habitantsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) => user['role'] != 'chef')
          .toList();

      setState(() => isLoading = false);
    } catch (e) {
      print("Erreur : $e");
      setState(() => isLoading = false);
     ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text("Erreur de chargement: $e"),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

    }
  }

  String _formatTextDate(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return "Date invalide";
    }
  }

Widget _buildSectionHeader(String title, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: widget.primaryColor.withOpacity(0.1),
    ), // 👈 ici on ferme bien la BoxDecoration
    child: Row(
      children: [
        Icon(icon, size: 28, color: widget.primaryColor),
        const SizedBox(width: 15),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: widget.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: widget.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitantCard(Map<String, dynamic> data, int index) {
    final colors = [widget.primaryColor, widget.secondaryColor, const Color(0xFF4CAF50)];
    final color = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(16),
  color: Colors.white,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ],
), // 👈 cette parenthèse manquait
child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
  color: color.withOpacity(0.1),
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(16),
    topRight: Radius.circular(16),
  ),
), // 👈 ferme ici avant d'ajouter `child`

            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.3),
                        color,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    data['name'] ?? 'Nom inconnu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['email'] != null) 
                  _buildInfoRow("Email", data['email']),
                if (data['telephone'] != null) 
                  _buildInfoRow("Téléphone", data['telephone']),
                if (data['role'] != null) 
                  _buildInfoRow("Statut", "Habitant"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la Maison", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor.withOpacity(0.9),
                widget.secondaryColor,
              ],
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.backgroundColor,
              widget.primaryColor.withOpacity(0.02),
            ],
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.primaryColor,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Chargement des données...",
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Maison
                    _buildInfoCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader("Maison", Icons.home),
                          _buildInfoRow("Adresse", 
                              maisonData?['adresse'] ?? 'Non renseignée'),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),

                    // Section Propriétaire
                    if (proprietaireData != null) 
                      _buildInfoCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSectionHeader("Propriétaire", Icons.person),
                            _buildInfoRow("Nom complet", 
                                "${proprietaireData!['nom']} ${proprietaireData!['prenom']}"),
                            if (proprietaireData?['dateNaissance'] != null)
                              _buildInfoRow("Date de naissance", 
                                  _formatTextDate(proprietaireData!['dateNaissance'])),
                            if (proprietaireData?['email'] != null)
                              _buildInfoRow("Email", proprietaireData!['email']),
                            if (proprietaireData?['telephone'] != null)
                              _buildInfoRow("Téléphone", proprietaireData!['telephone']),
                            if (proprietaireData?['adresse'] != null)
                              _buildInfoRow("Adresse", proprietaireData!['adresse']),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),

                    // Section Habitants
                    _buildInfoCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 28, color: widget.primaryColor),
                                const SizedBox(width: 15),
                                Text(
                                  "Habitants (${habitants.length})",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: widget.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                if (habitants.isNotEmpty)
                                  ...habitants.asMap().entries.map(
                                    (e) => _buildHabitantCard(e.value, e.key)
                                  ).toList()
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 50,
                                          color: widget.textSecondary.withOpacity(0.3),
                                        ),
                                        const SizedBox(height: 15),
                                        Text(
                                          "Aucun habitant enregistré",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: widget.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}