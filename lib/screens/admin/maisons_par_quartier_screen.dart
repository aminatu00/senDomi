import 'package:flutter/material.dart';
import '../../models/maison.dart';
import '../../models/proprietaire.dart';
import '../../services/firestore_service.dart';
import 'proprietaire_detail_screen.dart';

class MaisonsParQuartierScreen extends StatefulWidget {
  final String quartierId;

  const MaisonsParQuartierScreen({required this.quartierId});

  @override
  _MaisonsParQuartierScreenState createState() => _MaisonsParQuartierScreenState();
}

class _MaisonsParQuartierScreenState extends State<MaisonsParQuartierScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<MaisonModel> _allMaisons = [];
  List<MaisonModel> _filteredMaisons = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, ProprietaireModel> _proprietairesCache = {};

  @override
  void initState() {
    super.initState();
    _loadMaisons();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMaisons = _allMaisons.where((maison) {
        return maison.adresse.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _loadMaisons() async {
    final maisons = await _firestoreService.getMaisonsParQuartier(widget.quartierId);
    setState(() {
      _allMaisons = maisons;
      _filteredMaisons = maisons;
    });
  }

  Future<ProprietaireModel?> _getProprietaire(String id) async {
    if (_proprietairesCache.containsKey(id)) {
      return _proprietairesCache[id];
    }
    try {
      final prop = await _firestoreService.getProprietaireById(id);
      _proprietairesCache[id] = prop;
      return prop;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maisons du Quartier")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher une maison...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredMaisons.isEmpty
                  ? Center(child: Text("Aucune maison trouvée."))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: _filteredMaisons.length,
                      itemBuilder: (context, index) {
                        final maison = _filteredMaisons[index];
                        return FutureBuilder<ProprietaireModel?>(
                          future: _getProprietaire(maison.proprietaireId),
                          builder: (context, snapshot) {
                            final prop = snapshot.data;
                            return GestureDetector(
                              onTap: () {
                                if (prop != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProprietaireDetailScreen(proprietaire: prop),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      maison.adresse,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      prop != null
                                          ? "${prop.nom} ${prop.prenom}"
                                          : "Propriétaire inconnu",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
