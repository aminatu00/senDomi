import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../models/maison.dart';
import '../models/proprietaire.dart';
import '../models/quartier.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool _obscurePassword = true;

  String? selectedMaisonId;
  String? selectedProprietaireId;
  String? selectedQuartierId;
  DateTime? selectedDateNaissance;

  List<MaisonModel> maisons = [];

  String message = "";
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  
  // Nouvelle palette de couleurs turquoise
  final Color primaryColor = const Color(0xFF00C9B8); // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688); // Turquoise foncé
  final Color accentColor = const Color(0xFF00EAD3); // Turquoise clair
  final Color backgroundFieldColor = const Color(0xFFF5FCF9); // Fond de champ
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond d'écran

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => _isLoading = true);
    try {
      final maisonSnapshot =
          await FirebaseFirestore.instance.collection('maisons').get();

      List<MaisonModel> fetchedMaisons = maisonSnapshot.docs
          .map((doc) => MaisonModel.fromMap(doc.data(), doc.id))
          .toList();

      // Trie les maisons par numéro
      fetchedMaisons.sort((a, b) {
        final numA = int.tryParse(RegExp(r'\d+').firstMatch(a.adresse)?.group(0) ?? '0') ?? 0;
        final numB = int.tryParse(RegExp(r'\d+').firstMatch(b.adresse)?.group(0) ?? '0') ?? 0;
        return numA.compareTo(numB);
      });

      setState(() {
        maisons = fetchedMaisons;
      });
    } catch (e) {
      setState(() => message = "Erreur lors du chargement des données.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateNaissance(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateNaissance ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDateNaissance = picked);
    }
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate() ||
        selectedMaisonId == null ||
        selectedDateNaissance == null) {
      setState(() =>
          message = "Veuillez remplir tous les champs obligatoires.");
      return;
    }

    setState(() {
      _isLoading = true;
      message = "";
    });

    final error = await AuthService().registerUserWithData(
      emailController.text.trim(),
      passwordController.text.trim(),
      nameController.text.trim(),
      selectedMaisonId!,
      selectedQuartierId!,
      selectedProprietaireId!,
      selectedDateNaissance!,
      context,
    );

    if (error != null) {
      setState(() {
        message = error;
        _isLoading = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
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
              padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                        child: Image.asset('assets/logo.png', height: 120),
                      ),
                      SizedBox(height: 20),
                      
                      // Titre avec dégradé
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: Text(
                          "Créer un compte",
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
                      SizedBox(height: 20),
                      
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
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Veuillez entrer un email'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Email",
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
                            SizedBox(height: 16),

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
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Veuillez entrer un mot de passe'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Mot de passe",
                                  filled: true,
                                  fillColor: backgroundFieldColor,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
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
                            SizedBox(height: 16),

                            // Nom complet
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
                                controller: nameController,
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Entrez votre nom complet'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: "Nom complet",
                                  filled: true,
                                  fillColor: backgroundFieldColor,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Date de naissance
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
                              child: InkWell(
                                onTap: () => _selectDateNaissance(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: backgroundFieldColor,
                                    hintText: "Date de naissance",
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedDateNaissance == null
                                            ? "Choisir une date"
                                            : "${selectedDateNaissance!.toLocal()}"
                                                .split(' ')[0],
                                        style: TextStyle(
                                          color: selectedDateNaissance == null
                                              ? Colors.grey[600]
                                              : Colors.black,
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: primaryColor),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Maison
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
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: backgroundFieldColor,
                                  hintText: "Sélectionnez une maison",
                                  hintStyle: TextStyle(color: Colors.grey[600]),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  prefixIcon: Icon(Icons.home_outlined, color: primaryColor),
                                ),
                                dropdownColor: Colors.white,
                                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                iconSize: 30,
                                value: selectedMaisonId,
                                items: maisons.map((maison) {
                                  return DropdownMenuItem(
                                    value: maison.id,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        maison.adresse,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedMaisonId = val;
                                    final maison = maisons.firstWhere((m) => m.id == val);
                                    selectedQuartierId = maison.quartierId;
                                    selectedProprietaireId = maison.proprietaireId;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 32),

                            // Bouton inscription avec dégradé
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
                                onPressed: _isLoading ? null : registerUser,
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
                                        "S'inscrire",
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

                      // Lien vers connexion
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(text: "Vous avez déjà un compte ? "),
                              TextSpan(
                                text: "Se connecter",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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