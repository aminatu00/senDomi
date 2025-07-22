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
  
  // Nouvelle palette de couleurs turquoise
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran

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

  Widget _buildMaisonCard(MaisonModel maison, ProprietaireModel? prop) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      color: Colors.transparent,
      child: InkWell(
        onTap: prop != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProprietaireDetailScreen(proprietaire: prop),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec icône
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.house_rounded,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
              ),
              
              // Contenu
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Adresse
                    Text(
                      maison.adresse,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Propriétaire
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            prop != null ? "${prop.nom} ${prop.prenom}" : "Propriétaire inconnu",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Bouton de détail
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [primaryColor.withOpacity(0.2), primaryColor.withOpacity(0.1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: prop != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProprietaireDetailScreen(proprietaire: prop),
                                    ),
                                  );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Voir détails",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: primaryColor),
                              ],
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150.0,
              floating: true,
              pinned: true,
              backgroundColor: primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Maisons du Quartier",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        secondaryColor,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.home_work, size: 150, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Champ de recherche
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher une maison...",
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _filteredMaisons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_work_outlined, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              "Aucune maison trouvée",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Essayez une autre recherche",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredMaisons.length,
                        itemBuilder: (context, index) {
                          final maison = _filteredMaisons[index];
                          return FutureBuilder<ProprietaireModel?>(
                            future: _getProprietaire(maison.proprietaireId),
                            builder: (context, snapshot) {
                              return _buildMaisonCard(maison, snapshot.data);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}