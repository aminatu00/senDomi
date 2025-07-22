import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'chef_user_add_screen.dart';
import 'chef_user_edit_screen.dart';
import '../../models/maison.dart';

class ChefUserManagementScreen extends StatefulWidget {
  final UserModel chef;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  ChefUserManagementScreen({super.key, required this.chef});

  @override
  _ChefUserManagementScreenState createState() => _ChefUserManagementScreenState();
}

class _ChefUserManagementScreenState extends State<ChefUserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<UserModel>> _usersStream;
  final List<Color> _userColors = [
    const Color(0xFF00C9B8),
    const Color(0xFF4CAF50),
    const Color(0xFF2196F3),
    const Color(0xFF9C27B0),
    const Color(0xFFFF9800),
    const Color(0xFFE91E63),
  ];

  @override
  void initState() {
    super.initState();
    _usersStream = _firestoreService.getUsersStreamFilteredByQuartier(widget.chef.quartierId);
  }

Widget _buildUserCard(UserModel user, int index) {
  final color = _userColors[index % _userColors.length];
  
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      color: Colors.white,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
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
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: widget.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 24),
                        color: Colors.orange,
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => ChefUserEditScreen(user: user),
                              transitionsBuilder: (_, animation, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 24),
                        color: Colors.red,
                        onPressed: () async {
                          await _confirmDeleteUser(user);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.email, "Email", user.email),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.badge, "Statut", "Habitant"),
                  if (user.maisonId.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    FutureBuilder<MaisonModel?>(
                      future: _firestoreService.getMaisonById(user.maisonId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildShimmerInfoRow(Icons.home, "Adresse");
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return _buildInfoRow(Icons.home, "Adresse", "Introuvable");
                        }

                        final maison = snapshot.data!;
                        return _buildInfoRow(Icons.home, "Maison", maison.adresse);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 22, color: widget.textSecondary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildShimmerInfoRow(IconData icon, String label) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 22, color: widget.textSecondary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: widget.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Future<void> _confirmDeleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                'Confirmer la suppression',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: widget.textPrimary,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Voulez-vous vraiment supprimer cet habitant ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: widget.primaryColor),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Supprimer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteUser(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Habitant supprimé avec succès"),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de suppression: $e"),
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habitants du Quartier", 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
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
        elevation: 3,
      ),
      body: Container(
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
        child: StreamBuilder<List<UserModel>>(
          stream: _usersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: 6,
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                child: const ProfileShimmer(
  isRectBox: true,
  isDarkMode: false,
  padding: EdgeInsets.all(16),
  margin: EdgeInsets.zero,
),

                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_alt_outlined, 
                      size: 80, 
                      color: widget.primaryColor.withOpacity(0.2),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Aucun habitant dans votre quartier",
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.textPrimary.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => ChefUserAddScreen(quartierId: widget.chef.quartierId),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Ajouter un habitant"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 15),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              );
            }

            final users = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildUserCard(users[index], index);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ChefUserAddScreen(quartierId: widget.chef.quartierId),
              transitionsBuilder: (_, animation, __, child) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        backgroundColor: widget.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 5,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}