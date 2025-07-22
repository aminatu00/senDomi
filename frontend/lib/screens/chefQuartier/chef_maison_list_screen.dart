import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/maison.dart';
import '../../models/user_model.dart';
import '../../models/proprietaire.dart';
import 'ajouter_maison_chef_screen.dart';

class ChefMaisonListScreen extends StatefulWidget {
  final UserModel chef;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  const ChefMaisonListScreen({super.key, required this.chef});

  @override
  _ChefMaisonListScreenState createState() => _ChefMaisonListScreenState();
}

class _ChefMaisonListScreenState extends State<ChefMaisonListScreen> {
  final TextEditingController _adresseController = TextEditingController();

  Future<void> _modifierMaison(String id, Map<String, dynamic> data) async {
    _adresseController.text = data['adresse'] ?? '';

    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Icon(
  Icons.edit, // ou Icons.home
  size: 40,
  color: widget.primaryColor,
),

                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "Modifier la maison",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _adresseController,
                        decoration: InputDecoration(
                          labelText: "Adresse",
                          labelStyle: TextStyle(color: widget.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: TextStyle(color: widget.textPrimary, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: BorderSide(color: widget.textSecondary),
                              ),
                              child: Text(
                                "Annuler",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final nouvelleAdresse = _adresseController.text.trim();
                                if (nouvelleAdresse.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('maisons')
                                      .doc(id)
                                      .update({
                                    'adresse': nouvelleAdresse,
                                    'quartierId': widget.chef.quartierId,
                                  });
                                  Navigator.pop(ctx);
                                  _adresseController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Maison modifiée avec succès"),
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                              ),
                              child: const Text(
                                "Enregistrer",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _supprimerMaison(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Icon(
                  Icons.warning,
                  size: 40,
                  color: Colors.red,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      "Confirmer la suppression",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: widget.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Êtes-vous sûr de vouloir supprimer cette maison ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(color: widget.textSecondary),
                            ),
                            child: Text(
                              "Annuler",
                              style: TextStyle(
                                fontSize: 16,
                                color: widget.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Supprimer",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('maisons').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Maison supprimée avec succès"),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<ProprietaireModel?> _getProprietaire(String proprietaireId) async {
    if (proprietaireId.isEmpty) return null;

    final doc = await FirebaseFirestore.instance
        .collection('proprietaires')
        .doc(proprietaireId)
        .get();

    if (doc.exists) {
      return ProprietaireModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Widget _buildMaisonCard(MaisonModel maison, Map<String, dynamic> maisonData) {
    return FutureBuilder<ProprietaireModel?>(
      future: _getProprietaire(maison.proprietaireId),
      builder: (context, snapshot) {
        String proprietaireNom = "Inconnu";
        String proprietaireTel = "";
        Color cardColor = widget.primaryColor.withOpacity(0.1);
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          proprietaireNom = "Chargement...";
        } else if (snapshot.hasData) {
          proprietaireNom = "${snapshot.data!.prenom} ${snapshot.data!.nom}";
          proprietaireTel = snapshot.data!.telephone;
          cardColor = widget.secondaryColor.withOpacity(0.1);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.primaryColor.withOpacity(0.3),
                            widget.primaryColor,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        maison.adresse,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: widget.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Propriétaire",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      proprietaireNom,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.textPrimary,
                      ),
                    ),
                    if (proprietaireTel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        proprietaireTel,
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: "Modifier",
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _modifierMaison(maison.id, maisonData),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Tooltip(
                          message: "Supprimer",
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _supprimerMaison(maison.id),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maisons du Quartier", 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600
                  ),
                ),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor,
                widget.secondaryColor,
              ],
            ),
          ),
        ),
        elevation: 3,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.backgroundColor,
              widget.primaryColor.withOpacity(0.03),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('maisons')
              .where('quartierId', isEqualTo: widget.chef.quartierId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.primaryColor,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Chargement des maisons...",
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final maisons = snapshot.data?.docs ?? [];

            if (maisons.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined, 
                      size: 80, 
                      color: widget.primaryColor.withOpacity(0.2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Aucune maison dans ce quartier",
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.textPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Commencez par ajouter une nouvelle maison",
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              itemCount: maisons.length,
              itemBuilder: (context, index) {
                final maisonData = maisons[index].data() as Map<String, dynamic>;
                final maison = MaisonModel.fromMap(maisonData, maisons[index].id);
                return _buildMaisonCard(maison, maisonData);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AjouterMaisonChefScreen(chef: widget.chef)),
          );
        },
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 5,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}