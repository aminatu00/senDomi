import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // Import manquant pour PdfColors
import 'package:printing/printing.dart';
import '../../theme/colors.dart';
import '../../models/user_model.dart';
import '../../models/certificat_model.dart';
import 'pdf_viewer_screen.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/maison.dart';




class ChefMesCertificatsScreen extends StatelessWidget {
  final UserModel chef;

  const ChefMesCertificatsScreen({super.key, required this.chef});

  Future<Map<String, UserModel>> fetchUsersDuQuartier() async {
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('quartierId', isEqualTo: chef.quartierId)
        .get();

    final Map<String, UserModel> userMap = {};
    for (var doc in usersSnap.docs) {
      userMap[doc.id] = UserModel.fromMap(doc.data());
    }
    return userMap;
  }

  // Fonction pour générer le QR code
  Future<Uint8List> generateQrCode(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    final qrCode = qrValidationResult.qrCode!;

    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: true,
    );
    final image = await painter.toImage(200);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.description, 
                size: 60, 
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Aucun certificat attribué",
              style: TextStyle(
                fontSize: 22,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Vous n'avez encore validé aucun certificat",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatCard(BuildContext context, Certificat certif, UserModel? habitant) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.1),
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
              color: AppColors.primaryColor.withOpacity(0.1),
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
                    habitant?.name ?? "Habitant inconnu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: certif.statut == 'valide' 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    certif.statut.toUpperCase(),
                    style: TextStyle(
                      color: certif.statut == 'valide' ? Colors.green : Colors.orange,
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
                    Icon(Icons.calendar_today, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      "Demandé le: ${DateFormat('dd/MM/yyyy').format(certif.dateDemande)}",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (certif.dateValidation != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        "Validé le: ${DateFormat('dd/MM/yyyy').format(certif.dateValidation!)}",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.visibility, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PDFViewerScreen(url: certif.fichierPDF),
                            ),
                          );
                        },
                        iconSize: 28,
                        tooltip: "Voir le PDF",
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.download, color: AppColors.primaryColor),
                        onPressed: () => generateCertificatPDF(certif, habitant!),
                        iconSize: 28,
                        tooltip: "Télécharger",
                        padding: const EdgeInsets.all(14),
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
  }

Future<void> generateCertificatPDF(Certificat certif, UserModel habitant) async {
  final maisonSnap = await FirebaseFirestore.instance
    .collection('maisons')
    .doc(habitant.maisonId)
    .get();

final maison = MaisonModel.fromMap(maisonSnap.data()!, maisonSnap.id);

    
    final pdf = pw.Document();
    final Uint8List qrBytes = await generateQrCode(certif.id);
    final qrImage = pw.MemoryImage(qrBytes);


  final certifId = FirebaseFirestore.instance.collection('certificats').doc().id;

  final dateNaissanceFormatted = DateFormat('dd/MM/yyyy').format(habitant.dateNaissance);
  final todayFormatted = DateFormat('dd/MM/yyyy').format(DateTime.now());

  // Images pour signature et cachet
  final signatureImage = pw.MemoryImage(
    (await rootBundle.load('assets/signature.png')).buffer.asUint8List(),
  );
  final cachetImage = pw.MemoryImage(
    (await rootBundle.load('assets/cachet.png')).buffer.asUint8List(),
  );



  // Création du PDF
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("RÉPUBLIQUE DU SÉNÉGAL", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Text("Un Peuple - Un But - Une Foi\n"),
              pw.Text("République - Arrondissement - Commune des Parcelles Assainies\n"),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  "CERTIFICAT DE DOMICILE",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                "Je soussigné, Monsieur SERIGNE FALLOU GAYE,\n"
                "délégué de quartier de la commune des parcelles assainies, certifie que\n"
                "le (la) nommé(e) ${habitant.name},\n"
                "né(e) le $dateNaissanceFormatted,\n"
                "est domicilié(e) à la villa située à l’adresse suivante :\n"
                "${maison.adresse}.\n\n"
                "En foi de quoi, ce présent certificat lui est délivré pour servir et faire valoir\n"
                "ce que de droit.",
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 50),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Fait à Dakar,\nle $todayFormatted", style: pw.TextStyle(fontSize: 12)),
                  pw.Column(
                    children: [
                      pw.SizedBox(width: 100, height: 50, child: pw.Image(signatureImage)),
                      pw.Text("Signature\nChef de quartier", style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.bottomLeft,
                child: pw.SizedBox(width: 80, height: 80, child: pw.Image(cachetImage)),
              ),
              pw.SizedBox(height: 20),
              pw.Text("QR Code de vérification :", style: pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 10),
              pw.Center(child: pw.Image(qrImage, width: 100, height: 100)),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text("ID : $certifId", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ),
            ],
          ),
        );
      },
    ),
  );


    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes certificats attribués", 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.secondaryColor,
              ],
              stops: const [0.3, 0.9],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.5),
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
              AppColors.backgroundColor.withOpacity(0.6),
              AppColors.backgroundColor,
            ],
          ),
        ),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('certificats').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Chargement des certificats...",
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error, size: 60, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Erreur de chargement",
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Veuillez réessayer plus tard",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final certificatsDocs = snapshot.data!.docs;

            // Filtrer les certificats attribués par le chef
            final chefCertificatsDocs = certificatsDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['chefId'] == chef.uid;
            }).toList();

            if (chefCertificatsDocs.isEmpty) {
              return _buildEmptyState();
            }

            return FutureBuilder<Map<String, UserModel>>(
              future: fetchUsersDuQuartier(),
              builder: (context, userSnap) {
                if (userSnap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                }

                if (userSnap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error, size: 60, color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Erreur de chargement des habitants",
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Impossible de charger les informations",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final userMap = userSnap.data ?? {};
                final habitantIds = userMap.keys.toSet();

                final certificatsQuartier = chefCertificatsDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return habitantIds.contains(data['habitantId']);
                }).toList();
                
                // Trie les certificats par dateValidation décroissante
                certificatsQuartier.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  Timestamp getTimestamp(dynamic value) {
                    if (value is Timestamp) return value;
                    if (value is String) return Timestamp.fromDate(DateTime.parse(value));
                    throw Exception("Date invalide : $value");
                  }

                  final dateA = getTimestamp(dataA['dateValidation'] ?? dataA['dateDemande']);
                  final dateB = getTimestamp(dataB['dateValidation'] ?? dataB['dateDemande']);

                  return dateB.compareTo(dateA);
                });

                if (certificatsQuartier.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people, 
                              size: 60, 
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Aucun certificat dans votre quartier",
                            style: TextStyle(
                              fontSize: 22,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Les certificats que vous avez validés ne concernent pas votre quartier",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  itemCount: certificatsQuartier.length,
                  itemBuilder: (context, index) {
                    final certifData = certificatsQuartier[index].data() as Map<String, dynamic>;
                    final certif = Certificat.fromMap(certifData, certificatsQuartier[index].id);
                    final habitant = userMap[certif.habitantId];

                    return _buildCertificatCard(context, certif, habitant);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}