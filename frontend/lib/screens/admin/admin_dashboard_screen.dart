import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  // Nouvelle palette de couleurs turquoise
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran
  
  // Récupération du nombre d'utilisateurs par rôle (chef ou user)
  Future<int> getCount(String collectionName, {String? role}) async {
    Query query = FirebaseFirestore.instance.collection(collectionName);
    if (role != null) {
      query = query.where('role', isEqualTo: role); // Filtrer par rôle
    }
    final snapshot = await query.get();
    return snapshot.size;
  }

  // Récupérer les certificats attribués par jour
  Future<List<Map<String, dynamic>>> getCertificatesPerDay() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('certificats') // Collection des certificats
        .orderBy('dateAttribuee', descending: false) // Trier par date d'attribution
        .get();

    Map<DateTime, int> dailyCount = {};

    snapshot.docs.forEach((doc) {
      final date = (doc['dateAttribuee'] as Timestamp).toDate();
      final day = DateTime(date.year, date.month, date.day); // On regroupe par jour

      dailyCount.update(day, (value) => value + 1, ifAbsent: () => 1);
    });

    return dailyCount.entries
        .map((entry) => {
              'date': entry.key,
              'count': entry.value,
            })
        .toList();
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
                  "Tableau de bord",
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
                      child: Icon(Icons.analytics, size: 150, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Vue d'ensemble des données",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  )),
              const SizedBox(height: 20),

              // Statistiques dynamiques
              FutureBuilder<List<int>>(
                future: Future.wait([
                  getCount("users", role: "chef"), // Chefs de quartier
                  getCount("users", role: "user"), // Habitants
                  getCount("maisons"),
                  getCount("proprietaires"),
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00C9B8)));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            "Erreur de chargement des données",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                    children: [
                      _buildStatCard("Delegué de Quartier", Icons.location_city, data[0], primaryColor),
                      _buildStatCard("Habitants", Icons.people, data[1], const Color(0xFF4CAF50)),
                      _buildStatCard("Maisons", Icons.house, data[2], const Color(0xFFFF9800)),
                      _buildStatCard("Propriétaires", Icons.person, data[3], const Color(0xFF9C27B0)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),

              // Graphique des certificats attribués par jour
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getCertificatesPerDay(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00C9B8)));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            "Erreur de chargement du graphique",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    );
                  }

                  final certificatesData = snapshot.data!;
                  return _buildGraphSection(certificatesData);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Carte pour les statistiques
  Widget _buildStatCard(String title, IconData icon, int count, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                colors: [
                  color.withOpacity(0.3),
                  color,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text("$count", 
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: color
              )),
          const SizedBox(height: 8),
          Text(title, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              )),
        ],
      ),
    );
  }

  // Graphique dynamique pour les certificats
  Widget _buildGraphSection(List<Map<String, dynamic>> certificatesData) {
    // Si aucune donnée, on affiche un message
    if (certificatesData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text("Évolution des certificats attribués",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: primaryColor
                )),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: primaryColor.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune donnée disponible",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Préparation des données pour le graphique
    List<FlSpot> spots = [];
    List<String> dates = [];
    int index = 0;

    for (var data in certificatesData) {
      final date = data['date'] as DateTime;
      final count = data['count'] as int;
      
      spots.add(FlSpot(index.toDouble(), count.toDouble()));
      dates.add("${date.day}/${date.month}");
      index++;
    }

    // Trouver la valeur max pour l'axe Y
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("Évolution des certificats attribués",
          //     style: TextStyle(
          //       fontSize: 18, 
          //       fontWeight: FontWeight.bold, 
          //       color: primaryColor
          //     )),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: spots,
                    color: primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryColor.withOpacity(0.15),
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.3),
                          primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < dates.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[value.toInt()],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2), 
                    width: 1
                  ),
                ),
             lineTouchData: LineTouchData(
  touchTooltipData: LineTouchTooltipData(
    getTooltipColor: (LineBarSpot spot) => primaryColor,
    tooltipBorderRadius: BorderRadius.circular(8),
    getTooltipItems: (touchedSpots) {
      return touchedSpots.map((touchedSpot) {
        return LineTooltipItem(
          '${touchedSpot.y.toInt()} certificats',
          const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList();
    },
  ),
),
),
            ),
          ),
        ],
      ),
    );
  }
}