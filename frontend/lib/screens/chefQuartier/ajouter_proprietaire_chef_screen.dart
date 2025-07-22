import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/colors.dart';
import '../../models/user_model.dart';
import '../../models/proprietaire.dart';

class AjouterProprietaireChefScreen extends StatefulWidget {
  final ProprietaireModel? proprietaire;
  final UserModel chef;

  const AjouterProprietaireChefScreen({
    super.key,
    this.proprietaire,
    required this.chef,
  });

  @override
  State<AjouterProprietaireChefScreen> createState() =>
      _AjouterProprietaireChefScreenState();
}

class _AjouterProprietaireChefScreenState extends State<AjouterProprietaireChefScreen> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final telephoneController = TextEditingController();
  final lieuNaissanceController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.proprietaire != null) {
      final p = widget.proprietaire!;
      nomController.text = p.nom;
      prenomController.text = p.prenom;
      emailController.text = p.email;
      telephoneController.text = p.telephone;
      lieuNaissanceController.text = p.lieuNaissance;
      try {
        selectedDate = DateFormat('yyyy-MM-dd').parse(p.dateNaissance);
      } catch (_) {
        selectedDate = DateTime(1990);
      }
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    lieuNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez sélectionner une date de naissance"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final data = {
        'nom': nomController.text.trim(),
        'prenom': prenomController.text.trim(),
        'email': emailController.text.trim(),
        'telephone': telephoneController.text.trim(),
        'dateNaissance': DateFormat('yyyy-MM-dd').format(selectedDate!),
        'lieuNaissance': lieuNaissanceController.text.trim(),
        'chefId': widget.chef.uid,
        'quartierId': widget.chef.quartierId,
      };

      if (widget.proprietaire == null) {
        // Ajouter dans Firestore
        await FirebaseFirestore.instance.collection('proprietaires').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Propriétaire ajouté avec succès"),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        // Mettre à jour dans Firestore
        await FirebaseFirestore.instance
            .collection('proprietaires')
            .doc(widget.proprietaire!.id)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🔄 Propriétaire modifié avec succès"),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur: $e"),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 22),
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
            borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
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
            color: AppColors.primaryColor.withOpacity(0.08),
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
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.calendar_today, 
                    color: AppColors.primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  selectedDate == null
                      ? 'Date de naissance'
                      : DateFormat('dd MMMM yyyy').format(selectedDate!),
                  style: TextStyle(
                    color: selectedDate == null 
                        ? AppColors.textSecondary 
                        : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.proprietaire != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Modifier Propriétaire" : "Ajouter Propriétaire",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.secondaryColor,
              ],
              stops: const [0.3, 0.9],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.5),
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
              AppColors.backgroundColor.withOpacity(0.6),
              AppColors.backgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                                color: AppColors.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isEdit ? Icons.edit : Icons.person_add,
                                size: 28,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              isEdit ? "Modifier un propriétaire" : "Ajouter un propriétaire",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Remplissez les informations du propriétaire",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildFormField(
                          controller: nomController,
                          labelText: 'Nom',
                          icon: Icons.person,
                        ),
                        _buildFormField(
                          controller: prenomController,
                          labelText: 'Prénom',
                          icon: Icons.person_outline,
                        ),
                        _buildFormField(
                          controller: emailController,
                          labelText: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email requis';
                            if (!v.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        _buildFormField(
                          controller: telephoneController,
                          labelText: 'Téléphone',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildFormField(
                          controller: lieuNaissanceController,
                          labelText: 'Lieu de naissance',
                          icon: Icons.place,
                        ),
                        _buildDatePickerField(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _enregistrer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shadowColor: AppColors.primaryColor.withOpacity(0.4),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          isEdit ? "Mettre à jour" : "Ajouter le propriétaire",
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
                            child: Icon(
                              isEdit ? Icons.save : Icons.add,
                              size: 20,
                            ),
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
      ),
    );
  }
}