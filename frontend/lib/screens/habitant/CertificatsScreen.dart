import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/maison.dart';
import '../../models/certificat_model.dart';
import '../habitant/certificat_pdf.dart';
import 'package:intl/intl.dart';

class CertificatsScreen extends StatelessWidget {
  final UserModel user;

  const CertificatsScreen({super.key, required this.user});

  Future<MaisonModel?> fetchMaison(String maisonId) async {
    final doc = await FirebaseFirestore.instance
        .collection('maisons')
        .doc(maisonId)
        .get();

    if (doc.exists) {
      return MaisonModel.fromMap(doc.data()!, doc.id);
    } else {
      return null;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'payée':
        return const Color(0xFF00C9B8); // Turquoise vif
      case 'expiré':
        return const Color(0xFFF44336); // Rouge
      case 'en attente':
        return const Color(0xFFFF9800); // Orange
      case 'valide':
        return const Color(0xFF4CAF50); // Vert
      default:
        return const Color(0xFF00C9B8); // Turquoise par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF8), // Fond très clair
      appBar: AppBar(
        title: Text("Mes Certificats", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        )),
        centerTitle: true,
        backgroundColor: const Color(0xFF00C9B8), // Turquoise vif
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 8,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('certificats')
            .where('habitantId', isEqualTo: user.uid)
            .where('statut', isEqualTo: 'valide')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF00C9B8), // Turquoise vif
                strokeWidth: 3,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                          const Color(0xFF00EAD3), // Turquoise clair
                          const Color(0xFF00C9B8),  // Turquoise vif
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C9B8).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.description,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Aucun certificat disponible",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333), // Texte primaire
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Vos certificats valides apparaîtront ici une fois générés.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF666666), // Texte secondaire
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final certificats = snapshot.data!.docs
            .map((doc) => Certificat.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList()
            ..sort((a, b) => b.dateDemande.compareTo(a.dateDemande));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                  child: Text(
                    "${certificats.length} Certificat${certificats.length > 1 ? 's' : ''} Disponible${certificats.length > 1 ? 's' : ''}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333), // Texte primaire
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: certificats.length,
                    itemBuilder: (context, index) {
                      final certif = certificats[index];
                      final statusColor = _getStatusColor(certif.statut);
                      final formattedDate = DateFormat('dd MMM yyyy').format(certif.dateDemande);
                      final formattedTime = DateFormat('HH:mm').format(certif.dateDemande);

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
                                const Color(0xFFF0FAF8), // Fond très clair
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Badge avec icône PDF
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF00EAD3), // Turquoise clair
                                        const Color(0xFF00C9B8),  // Turquoise vif
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Détails du certificat
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Certificat de domicile",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF333333), // Texte primaire
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            certif.statut,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Émis le $formattedDate à $formattedTime",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color(0xFF666666), // Texte secondaire
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Bouton Télécharger
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF00C9B8), // Turquoise vif
                                        const Color(0xFF009688), // Turquoise foncé
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () async {
                                      final maison = await fetchMaison(user.maisonId);
                                      if (maison != null) {
                                        await generateCertificatPDF(user, maison);
                                      }
                                    },
                                    icon: const Icon(Icons.download, color: Colors.white),
                                    tooltip: "Télécharger",
                                  ),
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