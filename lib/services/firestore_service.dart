import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/proprietaire.dart';
import '../models/maison.dart';
import '../models/user_model.dart';
import '../models/quartier.dart';

class FirestoreService {
  // Référence à la collection "proprietaires" dans Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupérer la liste des propriétaires
  Future<List<ProprietaireModel>> getProprietaires() async {
    try {
      // On va récupérer tous les documents de la collection "proprietaires"
      QuerySnapshot snapshot = await _db.collection('proprietaires').get();
      return snapshot.docs.map((doc) {
        return ProprietaireModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des propriétaires : $e");
      return [];
    }
  }

  // Ajouter un nouveau propriétaire
  Future<void> addProprietaire(ProprietaireModel proprietaire) async {
    try {
      await _db.collection('proprietaires').add(proprietaire.toMap());
    } catch (e) {
      print("Erreur lors de l'ajout du propriétaire : $e");
    }
  }

  // Modifier un propriétaire existant
  Future<void> updateProprietaire(ProprietaireModel proprietaire) async {
    try {
      await _db
          .collection('proprietaires')
          .doc(proprietaire.id)
          .update(proprietaire.toMap());
    } catch (e) {
      print("Erreur lors de la mise à jour du propriétaire : $e");
    }
  }

  // Supprimer un propriétaire
  Future<void> deleteProprietaire(String id) async {
    try {
      await _db.collection('proprietaires').doc(id).delete();
    } catch (e) {
      print("Erreur lors de la suppression du propriétaire : $e");
    }
  }


  //maison

   Future<List<MaisonModel>> getMaisons() async {
  try {
    // On récupère toutes les maisons dans Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('maisons').get();
    
    // Vérifie que nous avons bien des maisons
    print('Maisons dans Firestore: ${snapshot.docs.length}');
    
    return snapshot.docs.map((doc) {
      return MaisonModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  } catch (e) {
    print("Erreur lors de la récupération des maisons : $e");
    return [];
  }
}


//LES USERS 
 // === Récupérer tous les utilisateurs en temps réel ===
 Stream<List<UserModel>> getUsersStream() {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id; // Injecte l'ID Firestore dans la map
      return UserModel.fromMap(data);
    }).toList();
  });
}


  // === Supprimer un utilisateur ===
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }

  Future<void> updateUser(UserModel user) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(user.toMap());
  } catch (e) {
    print("Erreur lors de la mise à jour de l'utilisateur : $e");
  }
}
//quartier
Future<List<Quartier>> getQuartiers() async {
  final snapshot = await FirebaseFirestore.instance.collection('quartiers').get();
  return snapshot.docs.map((doc) =>
      Quartier.fromMap(doc.data(), doc.id)).toList();
}

 Future<List<MaisonModel>> getMaisonsParQuartier(String quartierId) async {
    final snapshot = await _db
        .collection('maisons')
        .where('quartierId', isEqualTo: quartierId)
        .get();

    return snapshot.docs
        .map((doc) => MaisonModel.fromMap(doc.data(), doc.id))
        .toList();
  }
Future<ProprietaireModel> getProprietaireById(String id) async {
  final doc = await FirebaseFirestore.instance
      .collection('proprietaires')
      .doc(id)
      .get();

  if (!doc.exists) {
    throw Exception("Propriétaire introuvable");
  }

  return ProprietaireModel.fromMap(doc.data()!, doc.id);
}


 
}
