import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'signup_screen.dart';
import 'admin/admin_home_screen.dart';
import 'habitant/user_home_screen.dart';
import 'chefQuartier/chef_home_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = "";
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Couleurs de la nouvelle palette
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color accentColor = const Color(0xFF00EAD3); // Turquoise clair
  final Color backgroundFieldColor = const Color(0xFFF5FCF9); // Fond de champ
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      message = "";
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      final userModel = await AuthService().getUserData(uid);

      if (userModel != null) {
        if (userModel.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AdminHomeScreen(user: userModel)),
          );
        } else if (userModel.role == 'chef') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ChefQuartierHomeScreen(user: userModel)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserHomeScreen(user: userModel)),
          );
        }
      } else {
        setState(() {
          message = "Utilisateur non trouvé.";
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;

      switch (e.code) {
        case 'user-not-found':
          errorMsg = "Aucun utilisateur n'a été trouvé avec cet email.";
          break;
        case 'wrong-password':
          errorMsg = "Mot de passe incorrect. Veuillez réessayer.";
          break;
        case 'invalid-email':
          errorMsg = "L'adresse email est invalide.";
          break;
        case 'user-disabled':
          errorMsg = "Ce compte a été désactivé. Veuillez contacter l'administration.";
          break;
        case 'too-many-requests':
          errorMsg = "Trop de tentatives. Veuillez réessayer plus tard.";
          break;
        case 'network-request-failed':
          errorMsg = "Erreur réseau. Vérifiez votre connexion internet.";
          break;
        default:
          errorMsg = "Erreur d'authentification : ${e.message}";
      }

      setState(() {
        message = errorMsg;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.05),
                      // Logo avec effet de profondeur
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 120,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      
                      // Titre avec dégradé
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
                          "Se connecter",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      SizedBox(height: 30),

                      /// Formulaire
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Veuillez entrer votre email'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  filled: true,
                                  fillColor: backgroundFieldColor,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Mot de passe
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                validator: (value) => value == null || value.isEmpty
                                    ? 'Veuillez entrer votre mot de passe'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Mot de passe',
                                  filled: true,
                                  fillColor: backgroundFieldColor,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Bouton de connexion avec dégradé
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : loginUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Connexion",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Message d'erreur
                            if (message.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                            color: Colors.red.shade700, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Mot de passe oublié
                      TextButton(
                        onPressed: () {
                          // Naviguer vers réinitialisation si besoin
                        },
                        child: Text(
                          '',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Séparateur
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                      ),

                      // Créer un compte
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SignupScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(text: "Vous n'avez pas de compte ? "),
                              TextSpan(
                                text: "Créer un compte",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    );
  },
  child: Text(
    'Mot de passe oublié ?',
    style: TextStyle(
      color: primaryColor,
      fontWeight: FontWeight.w500,
    ),
  ),
),

                      Spacer(),
                      
                      // Footer
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          '© ${DateTime.now().year} senDomicile - Tous droits réservés',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}