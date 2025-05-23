import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../login_screen.dart';
import 'quartier_list_screen.dart';
import 'maison_list_screen.dart';
import 'proprietaire_list_screen.dart';
import 'maison_list_screen.dart';
import 'user_management_screen.dart';
import 'vue_generale_screen.dart';


// import 'Habitant_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  final UserModel user;
  const AdminHomeScreen({required this.user});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

 void navigateTo(BuildContext context, String routeName) {
  if (routeName == 'quartiers') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuartierListScreen()));
  } else if (routeName == 'maisons') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MaisonListScreen()));
  } 
  else if (routeName == 'proprietaires') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ProprietaireListScreen()),
  );
}
else if (routeName == 'habitants') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => UserManagementScreen()),
  );
}
 else if (routeName == 'vue') {
     Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => VueGeneraleScreen()),
  );
  }

 else if (routeName == 'justificatifs') {
    // TODO
  } else if (routeName == 'certificats') {
    // TODO
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Espace Admin")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin : ${user.name}',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.grid_view),
              title: Text('vue generale'),
              onTap: () => navigateTo(context, "vue"),
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text('Gérer Quartiers'),
              onTap: () => navigateTo(context, "quartiers"),
            ),
            ListTile(
              leading: Icon(Icons.house),
              title: Text('Gérer Maisons'),
              onTap: () => navigateTo(context, "maisons"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Gérer Propriétaires'),
              onTap: () => navigateTo(context, "proprietaires"),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Gérer Habitants'),
              onTap: () => navigateTo(context, "habitants"),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Justificatifs à valider'),
              onTap: () => navigateTo(context, "justificatifs"),
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Certificats'),
              onTap: () => navigateTo(context, "certificats"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () => logout(context),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          "Bienvenue ${user.name}, sélectionnez une action dans le menu",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
