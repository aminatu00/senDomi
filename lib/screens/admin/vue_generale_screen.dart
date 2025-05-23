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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vue Générale - Quartiers")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher un quartier...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredQuartiers.length,
                itemBuilder: (context, index) {
                  final quartier = filteredQuartiers[index];
                  return GestureDetector(
                    onTap: () => _openMaisonsParQuartier(context, quartier),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          quartier.nom,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
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
