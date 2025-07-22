import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../login_screen.dart';
import 'quartier_list_screen.dart';
import 'chefQuartier_Management_Screen.dart';
import 'admin_dashboard_screen.dart';
import 'vue_generale_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final UserModel user;
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran

  const AdminHomeScreen({super.key, required this.user});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  void navigateTo(BuildContext context, String routeName) {
    Widget target;
    switch (routeName) {
      case 'vue':
        target = VueGeneraleScreen();
        break;
      case 'quartiers':
        target = QuartierListScreen();
        break;
      case 'chefs_quartier':
        target = ChefQuartierManagementScreen();
        break;
      case 'dashboard':
        target = DashboardScreen();
        break;
      default:
        target = VueGeneraleScreen();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => showLogoutDialog(context),
                  tooltip: "Déconnexion",
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Espace du Maire",
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
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(Icons.admin_panel_settings, size: 150, color: Colors.white),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bienvenue,",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor,
                primaryColor.withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildModernFeatureCard(
                  context: context,
                  title: "Vue Générale",
                  icon: Icons.grid_view,
                  color: const Color(0xFF4CAF50),
                  route: "vue",
                ),
                _buildModernFeatureCard(
                  context: context,
                  title: "Gérer Quartiers",
                  icon: Icons.location_city,
                  color: primaryColor,
                  route: "quartiers",
                ),
                _buildModernFeatureCard(
                  context: context,
                  title: "Delegué de Quartier",
                  icon: Icons.person_outline,
                  color: secondaryColor,
                  route: "chefs_quartier",
                ),
                _buildModernFeatureCard(
                  context: context,
                  title: "Dashboard",
                  icon: Icons.dashboard,
                  color: const Color(0xFFFF9800),
                  route: "dashboard",
                ),
                // if (MediaQuery.of(context).size.width > 600)
                //   _buildModernFeatureCard(
                //     context: context,
                //     title: "Statistiques",
                //     icon: Icons.bar_chart,
                //     color: const Color(0xFF9C27B0),
                //     route: "vue",
                //   ),
              ],
            ),
          ),
        ),
      ),
      drawer: _buildModernDrawer(context),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, secondaryColor],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),],
                          ),
                         child: const CircleAvatar(
  radius: 40,
  backgroundImage: AssetImage('assets/maire.jpeg'),
  backgroundColor: Colors.white,
),

                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Maire commune",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Menu items
            _buildModernDrawerItem(
              context: context,
              icon: Icons.grid_view,
              title: "Vue Générale",
              route: "vue",
            ),
            _buildModernDrawerItem(
              context: context,
              icon: Icons.location_city,
              title: "Gérer Quartiers",
              route: "quartiers",
            ),
            _buildModernDrawerItem(
              context: context,
              icon: Icons.person_outline,
              title: "Gérer Delegués",
              route: "chefs_quartier",
            ),
            _buildModernDrawerItem(
              context: context,
              icon: Icons.dashboard,
              title: "Dashboard",
              route: "dashboard",
            ),
           
            
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: Colors.grey.shade300),
            ),
            _buildModernDrawerItem(
              context: context,
              icon: Icons.logout,
              title: "Déconnexion",
              isLogout: true,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => navigateTo(context, route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.3),
                      color,
                    ],
                  ),
                ),
                child: Icon(icon, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Accéder",
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? route,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isLogout ? Colors.red.withOpacity(0.05) : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLogout 
                ? Colors.red.withOpacity(0.1) 
                : primaryColor.withOpacity(0.1),
          ),
          child: Icon(icon, 
            color: isLogout ? Colors.red : primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: !isLogout 
            ? Icon(Icons.arrow_forward_ios_rounded, 
                size: 16, 
                color: Colors.grey.shade400)
            : null,
        onTap: () async {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 250));
          if (isLogout) {
            showLogoutDialog(context);
          } else if (route != null && context.mounted) {
            navigateTo(context, route);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Déconnexion",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Voulez-vous vraiment vous déconnecter ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Déconnexion"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}