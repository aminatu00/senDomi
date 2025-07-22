import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';

class ChefDashboardScreen extends StatefulWidget {
  final UserModel chef;

  const ChefDashboardScreen({super.key, required this.chef});

  @override
  State<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends State<ChefDashboardScreen> {
  // Nouvelle palette turquoise 🎨
  final Color primaryColor = const Color(0xFF00C9B8);   // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688);  // Turquoise foncé
  final Color accentColor = const Color(0xFF00EAD3);     // Turquoise clair
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond très clair
  final Color textPrimary = const Color(0xFF333333);     // Texte principal
  final Color textSecondary = const Color(0xFF666666);   // Texte secondaire

  List<FlSpot> spots = [];
  List<String> dateLabels = [];
  bool isLoading = true;

  int maisonCount = 0;
  int habitantCount = 0;
  int proprietaireCount = 0;
  int certificatCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final quartierId = widget.chef.quartierId;
    final chefId = widget.chef.uid;

    try {
      final maisonsSnapshot = await FirebaseFirestore.instance
          .collection('maisons')
          .where('quartierId', isEqualTo: quartierId)
          .count()
          .get();
      maisonCount = maisonsSnapshot.count ?? 0;

      final habitantsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('quartierId', isEqualTo: quartierId)
          .count()
          .get();
      habitantCount = habitantsSnapshot.count ?? 0;

      final proprietairesSnapshot = await FirebaseFirestore.instance
          .collection('proprietaires')
          .where('quartierId', isEqualTo: quartierId)
          .count()
          .get();
      proprietaireCount = proprietairesSnapshot.count ?? 0;

      final certificatsSnapshot = await FirebaseFirestore.instance
          .collection('certificats')
          .where('chefId', isEqualTo: chefId)
          .where('statut', isEqualTo: 'valide')
          .count()
          .get();
      certificatCount = certificatsSnapshot.count ?? 0;

      await _loadCertificatsParJour();

      setState(() => isLoading = false);
    } catch (e) {
      print("Erreur de chargement: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCertificatsParJour() async {
    final chefId = widget.chef.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('certificats')
        .where('chefId', isEqualTo: chefId)
        .where('statut', isEqualTo: 'valide')
        .get();

    Map<String, int> countByDay = {};

    for (var doc in snapshot.docs) {
      DateTime? date;

      final rawDate = doc['dateDemande'];
      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is String) {
        date = DateTime.tryParse(rawDate);
      }

      if (date != null) {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        countByDay[dateStr] = (countByDay[dateStr] ?? 0) + 1;
      }
    }

    final sorted = countByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    List<FlSpot> points = [];
    List<String> labels = [];

    for (int i = 0; i < sorted.length; i++) {
      points.add(FlSpot(i.toDouble(), sorted[i].value.toDouble()));
      labels.add(DateFormat('dd/MM').format(DateTime.parse(sorted[i].key)));
    }

    setState(() {
      spots = points;
      dateLabels = labels;
    });
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              backgroundColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$count",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accentColor, primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.bar_chart,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucun certificat validé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vos données de validation apparaîtront ici",
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  if (value.toInt() < dateLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dateLabels[value.toInt()], 
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: textSecondary),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryColor,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.3), Colors.transparent],
                  stops: const [0.1, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Tableau de bord",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 8,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenue,",
                          style: TextStyle(
                            fontSize: 20,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.chef.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Délégué de quartier",
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistiques
                  Text(
                    "Statistiques du quartier",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildStatCard("Maisons", maisonCount, Icons.home, const Color(0xFF00C9B8)),
                      _buildStatCard("Habitants", habitantCount, Icons.people, const Color(0xFF4CAF50)),
                      _buildStatCard("Propriétaires", proprietaireCount, Icons.person, const Color(0xFF9C27B0)),
                      _buildStatCard("Certificats", certificatCount, Icons.description, const Color(0xFFFF9800)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Graphique
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            backgroundColor,
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [accentColor, primaryColor],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.bar_chart,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Activité de validation",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Certificats validés par jour",
                            style: TextStyle(
                              fontSize: 16,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: _buildChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}