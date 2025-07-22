import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'paiement_screen.dart';
import '../../models/user_model.dart';
import 'CertificatsScreen.dart';

class HistoriqueDemandeScreen extends StatefulWidget {
  const HistoriqueDemandeScreen({Key? key}) : super(key: key);

  @override
  _HistoriqueDemandeScreenState createState() => _HistoriqueDemandeScreenState();
}

class _HistoriqueDemandeScreenState extends State<HistoriqueDemandeScreen> {
  // Nouvelle palette turquoise 🎨
  final Color primaryColor = const Color(0xFF00C9B8);   // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688);  // Turquoise foncé
  final Color accentColor = const Color(0xFF00EAD3);     // Turquoise clair
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond très clair
  final Color textPrimary = const Color(0xFF333333);     // Texte principal
  final Color textSecondary = const Color(0xFF666666);   // Texte secondaire

  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _demandesFuture;

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  void _loadDemandes() {
    _demandesFuture = _getUserDemandes();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getUserDemandes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    final snapshot = await FirebaseFirestore.instance
        .collection('demandes')
        .where('habitantId', isEqualTo: user.uid)
        .orderBy('date_creation', descending: true)
        .get();

    return snapshot.docs;
  }

  void _annulerDemande(String docId) async {
    await FirebaseFirestore.instance.collection('demandes').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Demande annulée avec succès."),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
    setState(() {
      _loadDemandes();
    });
    
  }

  Color _getEtatColor(String etat) {
    switch (etat) {
      case 'validée':
        return const Color(0xFF4CAF50); // Vert
      case 'en cours':
        return const Color(0xFFFF9800); // Orange
      case 'annulée':
        return const Color(0xFFF44336); // Rouge
      case 'payée':
        return primaryColor; // Turquoise
      default:
        return primaryColor;
    }
  }

  IconData _getEtatIcon(String etat) {
    switch (etat) {
      case 'validée':
        return Icons.check_circle;
      case 'en cours':
        return Icons.access_time;
      case 'annulée':
        return Icons.cancel;
      case 'payée':
        return Icons.verified;
      default:
        return Icons.description;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '—';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Historique des Demandes", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        )),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 8,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _demandesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Erreur de chargement",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Impossible de charger vos demandes",
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final demandes = snapshot.data ?? [];

          if (demandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          primaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Aucune demande",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Vos demandes apparaîtront ici",
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                  child: Text(
                    "${demandes.length} Demande${demandes.length > 1 ? 's' : ''}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: demandes.length,
                    itemBuilder: (context, index) {
                      final doc = demandes[index];
                      final data = doc.data();
                      final docId = doc.id;

                      final raison = data['raison'] ?? '—';
                      final etat = data['etat'] ?? '—';
                      final motif = data['motif_annulation'] ?? '';
                      final date = _formatDate(data['date_creation']);
                      final statusColor = _getEtatColor(etat);

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                backgroundColor,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête avec raison et statut
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColor.withOpacity(0.1),
                                      ),
                                      child: Icon(
                                        _getEtatIcon(etat),
                                        color: statusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            raison,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            etat.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Date de création
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: textSecondary),
                                    const SizedBox(width: 8),
                                    Text(date, style: TextStyle(color: textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Motif d'annulation
                                if (etat == 'annulée' && motif.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.red.shade100),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Motif d'annulation : $motif",
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // Boutons d'action
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (etat == 'validée')
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF4CAF50),
                                              Colors.green.shade700,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.payment, size: 20),
                                          label: const Text("Payer"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => PaiementScreen(demandeId: docId),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (etat == 'payée')
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryColor,
                                              secondaryColor,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.picture_as_pdf, size: 20),
                                          label: const Text("Voir certificat"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final user = FirebaseAuth.instance.currentUser;
                                            if (user == null) return;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => CertificatsScreen(
                                                  user: UserModel.fromFirebaseUser(user),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (etat == 'en cours')
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.red.shade400,
                                              Colors.red.shade700,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                        ),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.cancel),
                                          label: const Text("Annuler"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text("Confirmation"),
                                                content: const Text("Voulez-vous vraiment annuler cette demande ?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: Text("Non", style: TextStyle(color: primaryColor)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: Text("Oui, annuler", style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                            );

                                            if (confirm == true) {
                                              _annulerDemande(docId);
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}