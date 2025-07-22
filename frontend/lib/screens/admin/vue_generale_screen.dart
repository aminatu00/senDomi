import 'package:flutter/material.dart';
import '../../models/quartier.dart';
import '../../services/firestore_service.dart';
import 'maisons_par_quartier_screen.dart';

class VueGeneraleScreen extends StatefulWidget {
  @override
  _VueGeneraleScreenState createState() => _VueGeneraleScreenState();
}

class _VueGeneraleScreenState extends State<VueGeneraleScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Quartier> quartiers = [];
  List<Quartier> filteredQuartiers = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Nouvelle palette de couleurs turquoise
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran

  @override
  void initState() {
    super.initState();
    _loadQuartiers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadQuartiers() async {
    final data = await _firestoreService.getQuartiers();

    // Tri des quartiers par numéro dans le nom
    data.sort((a, b) {
      final numA = int.tryParse(RegExp(r'\d+').firstMatch(a.nom)?.group(0) ?? '') ?? 0;
      final numB = int.tryParse(RegExp(r'\d+').firstMatch(b.nom)?.group(0) ?? '') ?? 0;
      return numA.compareTo(numB);
    });

    setState(() {
      quartiers = data;
      filteredQuartiers = data;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredQuartiers = quartiers
          .where((q) => q.nom.toLowerCase().contains(query))
          .toList();
    });
  }

  void _openMaisonsParQuartier(BuildContext context, Quartier quartier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MaisonsParQuartierScreen(quartierId: quartier.id),
      ),
    );
  }

  Widget _buildQuartierCard(Quartier quartier) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openMaisonsParQuartier(context, quartier),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.3),
                      primaryColor,
                    ],
                  ),
                ),
                child: Icon(Icons.location_city, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  quartier.nom,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Voir les maisons",
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor,
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
                  "Vue Générale",
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
                      child: Icon(Icons.map, size: 150, color: Colors.white),
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
              // Champ de recherche moderne
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
                    hintText: "Rechercher un quartier...",
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
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
                child: filteredQuartiers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              "Aucun quartier trouvé",
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
                          childAspectRatio: 0.85,
                        ),
                        itemCount: filteredQuartiers.length,
                        itemBuilder: (context, index) {
                          final quartier = filteredQuartiers[index];
                          return _buildQuartierCard(quartier);
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