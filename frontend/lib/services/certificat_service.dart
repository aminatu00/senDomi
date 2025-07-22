import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔄 correction ici
import '../models/certificat_model.dart'; // 🔁 adapte le chemin si nécessaire

Future<String> uploadCertificatPDF(Uint8List pdfData) async {
  final storageRef = FirebaseStorage.instance.ref();
  final fileRef = storageRef.child('certificats/${DateTime.now().millisecondsSinceEpoch}.pdf');

  try {
    final uploadTask = fileRef.putData(pdfData);
    final snapshot = await uploadTask.whenComplete(() => null);
    final fileURL = await snapshot.ref.getDownloadURL();
    return fileURL;
  } catch (e) {
    print("Erreur lors du téléchargement du PDF : $e");
    return "";
  }
}
Future<String> getChefIdFromQuartier(String quartierId) async {
  final query = await FirebaseFirestore.instance
      .collection('users')
      .where('quartierId', isEqualTo: quartierId)
      .where('role', isEqualTo: 'chef')
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    return query.docs.first['uid'];
  } else {
    throw Exception('Aucun chef trouvé pour ce quartier.');
  }
}


Future<void> saveCertificatToFirestore(Certificat certif, Uint8List pdfData) async {
  try {
    final pdfUrl = await uploadCertificatPDF(pdfData);

    if (pdfUrl.isNotEmpty) {
      final updatedCertificat = Certificat(
        id: certif.id,
        habitantId: certif.habitantId,
        demandeId: certif.demandeId,
        dateDemande: certif.dateDemande,
        statut: certif.statut,
        fichierPDF: pdfUrl,
        dateValidation: certif.dateValidation,
      );

      final certificatsCollection = FirebaseFirestore.instance.collection('certificats');
      await certificatsCollection.doc(updatedCertificat.id).set(updatedCertificat.toMap());
    }
  } catch (e) {
    print("Erreur lors de la sauvegarde du certificat : $e");
  }
}
