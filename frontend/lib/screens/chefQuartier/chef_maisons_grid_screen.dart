import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'maison_details_screen.dart';

class ChefMaisonsGridScreen extends StatefulWidget {
  final UserModel chef;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color cardColors = const Color(0xFFF5FDFC);

  const ChefMaisonsGridScreen({super.key, required this.chef});

  @override
  State<ChefMaisonsGridScreen> createState() => _ChefMaisonsGridScreenState();
}

class _ChefMaisonsGridScreenState extends State<ChefMaisonsGridScreen> {
  List<QueryDocumentSnapshot> maisons = [];
  List<QueryDocumentSnapshot> filteredMaisons = [];
  String search = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaisons();
    _searchController.addListener(() => _filter(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMaisons() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('maisons')
        .where('quartierId', isEqualTo: widget.chef.quartierId)
        .get();

    setState(() {
      maisons = snapshot.docs;
      filteredMaisons = maisons;
    });
  }

  void _filter(String value) {
    setState(() {
      search = value;
      filteredMaisons = maisons.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final adresse = data['adresse']?.toLowerCase() ?? '';
        return adresse.contains(value.toLowerCase());
      }).toList();
    });
  }

  void _openMaisonDetails(DocumentSnapshot maison) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MaisonDetailsScreen(maisonId: maison.id),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildMaisonCard(Map<String, dynamic> maisonData, DocumentSnapshot doc, int index) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
    ];
    final color = colors[index % colors.length];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(8),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        elevation: 4,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openMaisonDetails(doc),
          borderRadius: BorderRadius.circular(24),
          splashColor: widget.accentColor.withOpacity(0.2),
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: widget.cardColors,
              boxShadow: [
                BoxShadow(
                  color: widget.primaryColor.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),]
            ),
        child: Padding(
  padding: const EdgeInsets.all(20.0),
  child: LayoutBuilder(
    builder: (context, constraints) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.2),
                          color,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.home, 
                      size: 36, 
                      color: Colors.white
                    ),
                  ),
                 
          const SizedBox(height: 16), // tu peux réduire un peu ce padding si nécessaire
          Flexible(
            child: Text(
              maisonData['adresse'] ?? 'Adresse inconnue',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // ✅ empêche que le texte déborde trop
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Voir les détails",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      );
    },
  ),
),
 ),
        ),
      ),
    );
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Maisons du quartier", 
        style: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.w600,
          fontSize: 18
        ),
      ),
      backgroundColor: widget.primaryColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.primaryColor,
              widget.secondaryColor,
            ],
          ),
        ),
      ),
      elevation: 2,
    ),
   body: SingleChildScrollView(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          widget.backgroundColor,
          widget.primaryColor.withOpacity(0.03),
        ],
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16),
            shadowColor: widget.primaryColor.withOpacity(0.2),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                // … inchangé
              ),
            ),
          ),
        ),

        /// ✅ Remplacement ici :
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: filteredMaisons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 80,
                        color: widget.primaryColor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Aucune maison trouvée",
                        style: TextStyle(
                          fontSize: 20,
                          color: widget.textPrimary.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (search.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              _filter("");
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Réinitialiser la recherche"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredMaisons.length,
                  itemBuilder: (context, index) {
                    final maison = filteredMaisons[index].data() as Map<String, dynamic>;
                    return _buildMaisonCard(maison, filteredMaisons[index], index);
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