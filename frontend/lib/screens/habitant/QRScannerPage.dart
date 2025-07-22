// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../models/certificat_model.dart';

// class QRScannerPage extends StatefulWidget {
//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }

// class _QRScannerPageState extends State<QRScannerPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   // Fonction pour marquer le certificat comme détruit
//   Future<void> marquerCertificatCommeDetruit(String certificatId) async {
//     try {
//       final certificatRef = FirebaseFirestore.instance.collection('certificats').doc(certificatId);
//       final certificatSnapshot = await certificatRef.get();

//       if (certificatSnapshot.exists) {
//         final certificatData = certificatSnapshot.data() as Map<String, dynamic>;
//         final certificat = Certificat.fromMap(certificatData, certificatId);

//         if (certificat.estDetruit) {
//           print("Le certificat a déjà été détruit.");
//         } else {
//           // Mettre à jour le certificat pour qu'il soit marqué comme détruit
//           await certificatRef.update({
//             'estDetruit': true,  // Marquer comme détruit
//             'dateValidation': DateTime.now(), // Date de destruction
//           });

//           print("Certificat marqué comme détruit.");
//         }
//       } else {
//         print("Certificat non trouvé.");
//       }
//     } catch (e) {
//       print("Erreur lors de la mise à jour du certificat : $e");
//     }
//   }

//   // Fonction pour vérifier si le certificat a été détruit
//   Future<bool> estCertificatDetruit(String certificatId) async {
//     final certificatRef = FirebaseFirestore.instance.collection('certificats').doc(certificatId);
//     final snapshot = await certificatRef.get();

//     if (snapshot.exists) {
//       final certificatData = snapshot.data() as Map<String, dynamic>;
//       final certificat = Certificat.fromMap(certificatData, certificatId);
//       return certificat.estDetruit;
//     }

//     return false;  // Le certificat n'existe pas, donc il n'est pas détruit
//   }

//   // Fonction pour gérer la lecture du QR Code
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       final certificatId = scanData.code;  // Récupère l'ID du certificat scanné
//       print("Certificat ID scanné: $certificatId");

//       // Vérifier si le certificat est déjà détruit
//       bool estDetruit = await estCertificatDetruit(certificatId);

//       if (estDetruit) {
//         // Si le certificat est détruit, afficher un message
//         print("Ce certificat a déjà été détruit.");
//       } else {
//         // Si le certificat n'est pas détruit, le marquer comme détruit
//         await marquerCertificatCommeDetruit(certificatId);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Scanner QR Code")),
//       body: Center(
//         child: QRView(
//           key: qrKey,
//           onQRViewCreated: _onQRViewCreated,
//           overlay: QrScannerOverlayShape(
//             borderColor: Colors.green,
//             borderRadius: 10,
//             borderLength: 30,
//             borderWidth: 10,
//             cutOutSize: 250,
//           ),
//         ),
//       ),
//     );
//   }
// }
