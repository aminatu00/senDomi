import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';  // Assurez-vous d'importer ce package
import 'package:flutter/material.dart'; // Ajout de Material pour Color

import '../../models/user_model.dart';
import '../../models/maison.dart';
import '../../models/certificat_model.dart';

// Génération du QR code Flutter -> Image
Future<ui.Image> generateQRCodeImage(String data) async {
  final qrValidationResult = QrValidator.validate(
    data: data,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.M,
  );

  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      gapless: true,
      color: const Color(0xFF000000), // 🖤 Noir
      emptyColor: const Color(0xFFFFFFFF), // 🤍 Blanc
    );
    return await painter.toImage(200); // Taille de l'image QR
  } else {
    throw Exception('QR Code invalide');
  }
}

Future<void> generateCertificatPDF(UserModel user, MaisonModel maison) async {
  final pdf = pw.Document();

  final certifId = FirebaseFirestore.instance.collection('certificats').doc().id;

  final dateNaissanceFormatted = DateFormat('dd/MM/yyyy').format(user.dateNaissance);
  final todayFormatted = DateFormat('dd/MM/yyyy').format(DateTime.now());

  // Images pour signature et cachet
  final signatureImage = pw.MemoryImage(
    (await rootBundle.load('assets/signature.png')).buffer.asUint8List(),
  );
  final cachetImage = pw.MemoryImage(
    (await rootBundle.load('assets/cachet.png')).buffer.asUint8List(),
  );

  // Génération du QR code à partir de l'ID du certificat
  final qrImage = await generateQRCodeImage(certifId);
  final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
  final imageBytes = byteData!.buffer.asUint8List();
  final qrPdfImage = pw.MemoryImage(imageBytes);

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
                "le (la) nommé(e) ${user.name},\n"
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
              pw.Center(child: pw.Image(qrPdfImage, width: 100, height: 100)),
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

  final pdfBytes = await pdf.save();

  // ✅ Upload vers Cloudinary
  final cloudinaryCloudName = 'dpfxtypn2';
  final cloudinaryUploadPreset = 'senDomicile';

  try {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudinaryCloudName/auto/upload');
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = cloudinaryUploadPreset;

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      pdfBytes,
      filename: 'certificat_${user.name}.pdf',
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      final pdfUrl = jsonData['secure_url'];

      final certificat = Certificat(
        id: certifId,
        habitantId: user.uid,
        demandeId: '', // optionnel selon ton besoin
        dateDemande: DateTime.now(),
        statut: 'payée',
        fichierPDF: pdfUrl,
        dateValidation: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('certificats')
          .doc(certifId)
          .set(certificat.toMap());

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
    } else {
      throw Exception('Erreur lors de l\'upload vers Cloudinary');
    }
  } catch (e) {
    print("Erreur lors de l'upload ou de l'enregistrement : $e");
  }
}
