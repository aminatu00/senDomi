import 'package:flutter/material.dart';
import '../../models/proprietaire.dart'; // Assure-toi que ce modèle existe
import '../../services/firestore_service.dart'; // Assure-toi que ce service existe pour interagir avec Firestore
import 'ajouter_proprietaire_screen.dart'; // Pour rediriger vers la page d'ajout/modification

class ProprietaireListScreen extends StatefulWidget {
  @override
  _ProprietaireListScreenState createState() => _ProprietaireListScreenState();
}

class _ProprietaireListScreenState extends State<ProprietaireListScreen> {
  List<ProprietaireModel> proprietaires = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProprietaires();
  }

  // Récupérer la liste des propriétaires depuis Firestore
  Future<void> _fetchProprietaires() async {
    proprietaires = await FirestoreService().getProprietaires(); // Utilise un service Firestore pour récupérer les données
    setState(() {
      isLoading = false;
    });
  }

  // Fonction pour supprimer un propriétaire
  Future<void> _deleteProprietaire(String id) async {
    await FirestoreService().deleteProprietaire(id); // Utiliser le service Firestore pour supprimer
    _fetchProprietaires(); // Rafraîchir la liste après suppression
  }

  // Fonction pour naviguer vers la page d'ajout ou de modification
  void _navigateToAddOrEdit(ProprietaireModel? proprietaire) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AjouterProprietaireScreen(proprietaire: proprietaire), // Passe l'objet propriétaire à la page de modification
      ),
    ).then((_) => _fetchProprietaires()); // Rafraîchir la liste après ajout/modification
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Propriétaires")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement pendant la récupération des données
          : ListView.builder(
              itemCount: proprietaires.length,
              itemBuilder: (context, index) {
                final proprietaire = proprietaires[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('${proprietaire.nom} ${proprietaire.prenom}'),
                    subtitle: Text(proprietaire.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _navigateToAddOrEdit(proprietaire), // Modifier
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteProprietaire(proprietaire.id), // Supprimer
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddOrEdit(null), // Passer null pour un nouvel ajout
        child: Icon(Icons.add),
      ),
    );
  }
}
