import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';

class ChefCertificatsScreen extends StatefulWidget {
  final UserModel chef;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  const ChefCertificatsScreen({required this.chef, Key? key}) : super(key: key);

  @override
  State<ChefCertificatsScreen> createState() => _ChefCertificatsScreenState();
}

class _ChefCertificatsScreenState extends State<ChefCertificatsScreen> {
  void _confirmerValidation(String demandeId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, size: 32, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(
                      "Confirmer la validation",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "Êtes-vous sûr de vouloir valider cette demande ?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _validerDemande(demandeId);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: widget.primaryColor.withOpacity(0.4),
                            ),
                            child: const Text(
                              "Valider",
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
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
  }

  Future<void> _validerDemande(String demandeId) async {
    try {
      await FirebaseFirestore.instance.collection('demandes').doc(demandeId).update({
        'etat': 'validée',
      });

      final certifSnap = await FirebaseFirestore.instance
          .collection('certificats')
          .where('demandeId', isEqualTo: demandeId)
          .limit(1)
          .get();

      if (certifSnap.docs.isNotEmpty) {
        final certifDoc = certifSnap.docs.first;

        await FirebaseFirestore.instance.collection('certificats').doc(certifDoc.id).update({
          'statut': 'valide',
          'chefId': widget.chef.uid,
          'dateValidation': DateTime.now().toIso8601String(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✅ Demande validée et certificat mis à jour."), 
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
        ),
      );

      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Erreur lors de la validation."), 
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _annulerDemande(String demandeId) async {
    final motifController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 32, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(
                      "Motif d'annulation",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: motifController,
                      decoration: InputDecoration(
                        hintText: "Ex: Document illisible",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('demandes').doc(demandeId).update({
                                'etat': 'annulée',
                                'motif_annulation': motifController.text,
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text("❌ Demande annulée."), 
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Confirmer",
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
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
  }

  void _afficherDetailsDemande(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, size: 28, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(
                      "Détails de la demande",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Raison", data['raison'] ?? 'Non spécifiée'),
                    const SizedBox(height: 12),
                    _buildInfoRow("Validité", data['date_validite'] ?? 'Non spécifiée'),
                    const SizedBox(height: 12),
                    _buildInfoRow("État", data['etat'] ?? 'Non spécifiée'),
                    const SizedBox(height: 24),
                    const Text("🆔 CIN :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildFileWidget(data['cin_url']),
                    const SizedBox(height: 24),
                    const Text("📎 Justificatif :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildFileWidget(data['justificatif_url']),
                    if (data['motif_annulation'] != null) ...[
                      const SizedBox(height: 24),
                      Text("❗ Motif d'annulation :", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(data['motif_annulation'], style: TextStyle(color: widget.textSecondary)),
                    ],
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Fermer",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label :", 
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                color: widget.textSecondary,
                fontSize: 15
              )
            ),
          ),
          Expanded(
            child: Text(
              value, 
              style: TextStyle(
                color: widget.textPrimary,
                fontSize: 15
              )
            )
          ),
        ],
      ),
    );
  }

  Widget _buildFileWidget(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("⚠️ Aucun fichier disponible.", style: TextStyle(color: Colors.grey)),
      );
    }

    final isImage = url.endsWith(".jpg") || url.endsWith(".jpeg") || url.endsWith(".png");

    if (isImage) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.black,
              insetPadding: const EdgeInsets.all(10),
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("❌ Erreur de chargement", style: TextStyle(color: Colors.white)),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              url,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: const Center(child: Text("❌ Erreur de chargement")),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: widget.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Impossible d'ouvrir le fichier.")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: widget.primaryColor),
            const SizedBox(width: 12),
            Text(
              "Ouvrir le document", 
              style: TextStyle(
                color: widget.primaryColor, 
                fontWeight: FontWeight.w600
              )
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> _fetchUsersQuartiers() async {
    final usersSnap = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, String> map = {};
    for (var doc in usersSnap.docs) {
      map[doc.id] = doc.data()['quartierId'] ?? '';
    }
    return map;
  }

  Widget _buildDemandeCard(DocumentSnapshot doc, Map<String, dynamic> data) {
    final statusColor = data['etat'] == 'validée' 
      ? Colors.green 
      : data['etat'] == 'annulée' 
        ? Colors.red 
        : Colors.orange;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['raison'] ?? 'Raison non spécifiée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: widget.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data['etat'] ?? 'État inconnu',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: widget.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      "Demandé le: ${DateFormat('dd/MM/yyyy').format((data['date_creation'] as Timestamp).toDate())}",
                      style: TextStyle(
                        color: widget.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.visibility, 
                      Colors.blue, 
                      "Détails", 
                      () => _afficherDetailsDemande(context, data)
                    ),
                    _buildActionButton(
                      Icons.check_circle, 
                      Colors.green, 
                      "Valider", 
                      () => _confirmerValidation(doc.id)
                    ),
                    _buildActionButton(
                      Icons.cancel, 
                      Colors.red, 
                      "Annuler", 
                      () => _annulerDemande(doc.id)
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 28,
        tooltip: tooltip,
        padding: const EdgeInsets.all(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validation des Certificats", 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
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
              stops: const [0.3, 0.9],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.backgroundColor.withOpacity(0.6),
              widget.backgroundColor,
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('demandes').where('etat', isEqualTo: 'en cours').snapshots(),
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
                      "Chargement des demandes...",
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

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _noDemandesWidget("Aucune demande en attente", "Toutes les demandes sont traitées");
            }

            final allDemandes = snapshot.data!.docs;

            return FutureBuilder<Map<String, String>>(
              future: _fetchUsersQuartiers(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: widget.primaryColor));
                }

                final users = userSnap.data ?? {};
                final filtered = allDemandes.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final habitantId = data['habitantId'];
                  final quartier = users[habitantId] ?? '';
                  return quartier == widget.chef.quartierId;
                }).toList()
                  ..sort((a, b) {
                    final dateA = (a.data() as Map<String, dynamic>)['date_creation'] as Timestamp?;
                    final dateB = (b.data() as Map<String, dynamic>)['date_creation'] as Timestamp?;
                    return dateB?.compareTo(dateA!) ?? 0;
                  });

                if (filtered.isEmpty) {
                  return _noDemandesWidget("Aucune demande dans votre quartier", "Toutes les demandes sont traitées");
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildDemandeCard(doc, data);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _noDemandesWidget(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_turned_in, 
                size: 60, 
                color: widget.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                color: widget.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: widget.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}