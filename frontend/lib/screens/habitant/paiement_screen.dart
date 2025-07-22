import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'webview_screen.dart';
import '../../services/certificat_service.dart';
import '../../models/user_model.dart';

class PaiementScreen extends StatefulWidget {
  final String demandeId;

  const PaiementScreen({Key? key, required this.demandeId}) : super(key: key);

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  bool isLoading = false;
  // Nouvelle palette turquoise 🎨
  final Color primaryColor = const Color(0xFF00C9B8);   // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688);  // Turquoise foncé
  final Color accentColor = const Color(0xFF00EAD3);     // Turquoise clair
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond très clair
  final Color textPrimary = const Color(0xFF333333);     // Texte principal
  final Color textSecondary = const Color(0xFF666666);   // Texte secondaire

  final double montant = 500.0; // Montant fixe pour le paiement

  Future<void> _effectuerPaiement() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          "https://app.paydunya.com/sandbox-api/v1/checkout-invoice/create",
        ),
        headers: {
          "Content-Type": "application/json",
          "PAYDUNYA-MASTER-KEY": "",
          "PAYDUNYA-PRIVATE-KEY": "",
          "PAYDUNYA-TOKEN": "",
        },
        body: jsonEncode({
          "invoice": {
            "total_amount": montant,
            "description": "Paiement pour la demande #${widget.demandeId}",
          },
          "store": {"name": "SenDomicile"},
        }),
      );

      final data = jsonDecode(response.body);

      if (data['response_code'] != "00") {
        throw Exception("Erreur PayDunya : ${data['response_text']}");
      }

      final String url = data['response_text'];

      // Mise à jour de la demande et du certificat
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final demandeRef = FirebaseFirestore.instance
            .collection('demandes')
            .doc(widget.demandeId);
        await demandeRef.update({'etat': 'payée'});

        final certificatQuery =
            await FirebaseFirestore.instance
                .collection('certificats')
                .where('demandeId', isEqualTo: widget.demandeId)
                .limit(1)
                .get();

        if (certificatQuery.docs.isNotEmpty) {
          await certificatQuery.docs.first.reference.update({
            'statut': 'payée',
            'dateValidation': DateTime.now().toIso8601String(),
          });
        } else {
          Future<UserModel> getUserModel(String uid) async {
            final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
            return UserModel.fromMap(doc.data()!);
          }

          final firebaseUser = FirebaseAuth.instance.currentUser!;
          final userModel = await getUserModel(firebaseUser.uid);
          final chefId = await getChefIdFromQuartier(userModel.quartierId);

          await FirebaseFirestore.instance.collection('certificats').add({
            'habitantId': userModel.uid,
            'demandeId': widget.demandeId,
            'dateDemande': DateTime.now().toIso8601String(),
            'statut': 'valide',
            'fichierPDF': '',
            'dateValidation': DateTime.now().toIso8601String(),
            'chefId': chefId,
            'estDetruit': false,
          });
        }
      }

      // Ouvre l'URL de paiement
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WebViewScreen(url: url)),
      );
    } catch (e) {
      _showDialog("Erreur", "Une erreur est survenue : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: TextStyle(color: primaryColor)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: primaryColor)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Paiement sécurisé", style: TextStyle(
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de paiement
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accentColor, primaryColor],
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
                  Icons.payment,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              Text(
                "Finalisez votre paiement",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                "Pour accéder à votre certificat de résidence, veuillez effectuer le paiement sécurisé",
                style: TextStyle(
                  fontSize: 16, 
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Carte de détails du paiement
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Référence
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Référence:",
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary,
                              ),
                            ),
                            Text(
                              "#${widget.demandeId.substring(0, 8)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Montant
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Montant:",
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary,
                              ),
                            ),
                            Text(
                              "$montant FCFA",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        Divider(height: 1, color: Colors.grey.shade300),
                        const SizedBox(height: 30),

                        Text(
                          "Méthodes de paiement acceptées",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Logos des moyens de paiement
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            Image.asset('assets/om.png', height: 40),
                            Image.asset('assets/wave.png', height: 40),
                            Image.asset('assets/visa.jpeg', height: 40),
                            Image.asset('assets/mastercard.jpeg', height: 40),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Bouton de paiement
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),)
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _effectuerPaiement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payment, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          "Payer maintenant",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Information de sécurité
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Vous serez redirigé vers la plateforme sécurisée PayDunya pour effectuer votre paiement",
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Badge de sécurité
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    "Paiement 100% sécurisé",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}