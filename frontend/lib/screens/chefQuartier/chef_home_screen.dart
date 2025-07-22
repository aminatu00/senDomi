import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../login_screen.dart';
import 'chef_maison_list_screen.dart';
import 'chef_proprietaire_list_screen.dart';
import 'chef_user_management_screen.dart';
import 'chef_certificats_screen.dart';
import 'chef_dashboard_screen.dart';
import 'chef_maisons_grid_screen.dart';
import 'mes_certificats_screen.dart';

class ChefQuartierHomeScreen extends StatelessWidget {
  final UserModel user;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  const ChefQuartierHomeScreen({super.key, required this.user});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

 void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildModernDrawer(context),
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
              leading: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => showLogoutDialog(context),
                  tooltip: "Déconnexion",
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Espace Délégué de Quartier",
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
                  title: "Tableau de bord",
                  icon: Icons.dashboard,
                  color: const Color(0xFF4CAF50),
                  onTap: () => navigateTo(context,ChefDashboardScreen(chef: user)),
                ),
                _buildModernFeatureCard(
                  title: "Vue des Maisons",
                  icon: Icons.grid_view,
                  color: primaryColor,
                  onTap: () => navigateTo(context,ChefMaisonsGridScreen(chef: user)),
                ),
                _buildModernFeatureCard(
                  title: "Gérer Habitants",
                  icon: Icons.people_alt,
                  color: secondaryColor,
                  onTap: () => navigateTo(context,ChefUserManagementScreen(chef: user)),
                ),
                _buildModernFeatureCard(
                  title: "Valider Certificats",
                  icon: Icons.assignment,
                  color: const Color(0xFFFF9800),
                  onTap: () => navigateTo(context,ChefCertificatsScreen(chef: user)),
                ),
                _buildModernFeatureCard(
                  title: "Gérer Maisons",
                  icon: Icons.house,
                  color: const Color(0xFF9C27B0),
                  onTap: () => navigateTo(context,ChefMaisonListScreen(chef: user)),
                ),
                _buildModernFeatureCard(
                  title: "Gérer Propriétaires",
                  icon: Icons.people,
                  color: const Color(0xFF2196F3),
                  onTap: () => navigateTo(context,ChefProprietaireListScreen(chef: user)),
                ),
              ],
            ),
          ),
        ),
      ),
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
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 40,
                              color: primaryColor,
                            ),
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
                          "Délégué de Quartier",
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
              icon: Icons.dashboard,
              title: "Tableau de bord",
              onTap: () => navigateTo(context,ChefDashboardScreen(chef: user)),
            ),
            _buildModernDrawerItem(
                context: context,
              icon: Icons.grid_view,
              title: "Vue des Maisons",
              onTap: () => navigateTo(context,ChefMaisonsGridScreen(chef: user)),
            ),
            _buildModernDrawerItem(
                context: context,
              icon: Icons.people_alt,
              title: "Gérer Habitants",
              onTap: () => navigateTo(context,ChefUserManagementScreen(chef: user)),
            ),
            _buildModernDrawerItem(
                context: context,
              icon: Icons.house,
              title: "Gérer Maisons",
              onTap: () => navigateTo(context,ChefMaisonListScreen(chef: user)),
            ),
            _buildModernDrawerItem(
                context: context,
              icon: Icons.people,
              title: "Gérer Propriétaires",
              onTap: () => navigateTo(context,ChefProprietaireListScreen(chef: user)),
            ),
            _buildModernDrawerItem(
                context: context,
              icon: Icons.assignment,
              title: "Valider Certificats",
              onTap: () => navigateTo(context,ChefCertificatsScreen(chef: user)),
            ),
            _buildModernDrawerItem(
                context: context,
              icon: Icons.assignment_turned_in,
              title: "Historique Certificats",
              onTap: () => navigateTo(context,ChefMesCertificatsScreen(chef: user)),
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
              onTap: () => showLogoutDialog(context),
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
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                  color: textPrimary,
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
  required VoidCallback onTap,
  bool isLogout = false,
})
{
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
            color: isLogout ? Colors.red : textPrimary,
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
          onTap();
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