import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'user_add_screen.dart';
import 'user_edit_screen.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<UserModel>> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = _firestoreService.getUsersStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestion des Habitants")),
      body: StreamBuilder<List<UserModel>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun habitant trouvé"));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Button pour modifier l'utilisateur
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Naviguer vers l'écran de modification avec l'utilisateur sélectionné
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserEditScreen(user: user),
                          ),
                        );
                      },
                    ),
                    // Button pour supprimer l'utilisateur
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Supprimer l'utilisateur via FirestoreService
                        await _firestoreService.deleteUser(user.uid);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Naviguer vers l'écran de modification (par tap sur l'utilisateur)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserEditScreen(user: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers l'écran d'ajout d'utilisateur
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserAddScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
