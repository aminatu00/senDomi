import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/maison.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChefUserAddScreen extends StatefulWidget {
  final String quartierId;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  ChefUserAddScreen({super.key, required this.quartierId});

  @override
  _ChefUserAddScreenState createState() => _ChefUserAddScreenState();
}

class _ChefUserAddScreenState extends State<ChefUserAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime? selectedDateNaissance;
  String? selectedMaisonId;

  final FirestoreService _firestoreService = FirestoreService();
  List<MaisonModel> maisons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaisons();
  }

  Future<void> _loadMaisons() async {
    try {
      maisons = await _firestoreService.getMaisonsByQuartier(widget.quartierId);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de chargement: $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              onSurface: widget.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: widget.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDateNaissance = picked);
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez sélectionner une date de naissance"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (selectedMaisonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez sélectionner une maison"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final maison = maisons.firstWhere((m) => m.id == selectedMaisonId);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      UserCredential authResult = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = authResult.user!.uid;

      final newUser = UserModel(
        uid: uid,
        name: _nameController.text.trim(),
        email: email,
        role: 'user',
        createdAt: DateTime.now(),
        dateNaissance: selectedDateNaissance!,
        maisonId: maison.id,
        quartierId: widget.quartierId,
        proprietaireId: maison.proprietaireId,
      );

      await _firestoreService.addUser(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Habitant ajouté avec succès"),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur Firebase Auth : ${e.message}"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: widget.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(icon, color: widget.primaryColor, size: 22),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        style: TextStyle(
          color: widget.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        validator: validator ?? (v) => v!.isEmpty ? 'Champ requis' : null,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_today, 
                    color: widget.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  selectedDateNaissance == null
                      ? 'Date de naissance'
                      : DateFormat('dd MMMM yyyy').format(selectedDateNaissance!),
                  style: TextStyle(
                    color: selectedDateNaissance == null 
                        ? widget.textSecondary 
                        : widget.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: widget.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedMaisonId,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Maison',
          labelStyle: TextStyle(
            color: widget.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.primaryColor, width: 1.5),
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(Icons.home, color: widget.primaryColor, size: 22),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: maisons.map((maison) {
          return DropdownMenuItem(
            value: maison.id,
            child: Text(
              maison.adresse,
              style: TextStyle(
                color: widget.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => selectedMaisonId = value),
        validator: (value) => value == null ? 'Sélectionner une maison' : null,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
        style: TextStyle(color: widget.textPrimary, fontSize: 16),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un habitant", 
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
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
              stops: const [0.3, 0.9],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.backgroundColor.withOpacity(0.6),
              widget.backgroundColor,
            ],
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.primaryColor,
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Chargement des maisons...",
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person_add_alt_1, 
                                      size: 28, color: widget.primaryColor),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Nouvel Habitant",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: widget.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Remplissez les informations du nouvel habitant",
                              style: TextStyle(
                                color: widget.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _buildFormField(
                              controller: _nameController,
                              labelText: 'Nom complet',
                              icon: Icons.person_outline,
                            ),
                            _buildFormField(
                              controller: _emailController,
                              labelText: 'Email',
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Email requis';
                                if (!value.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            _buildFormField(
                              controller: _passwordController,
                              labelText: 'Mot de passe',
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Mot de passe requis';
                                if (value.length < 6) return 'Au moins 6 caractères';
                                return null;
                              },
                            ),
                            _buildDatePickerField(),
                            _buildDropdownField(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shadowColor: widget.primaryColor.withOpacity(0.4),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              "Ajouter l'habitant",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Positioned(
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.arrow_forward, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}