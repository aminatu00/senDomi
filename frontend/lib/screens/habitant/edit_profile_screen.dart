import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/maison.dart';
import '../../models/proprietaire.dart';
import '../../models/quartier.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({required this.user, super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Nouvelle palette turquoise 🎨
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  DateTime? _selectedDate;

  List<MaisonModel> _maisons = [];
  MaisonModel? _selectedMaison;
  Quartier? _quartier;
  ProprietaireModel? _proprietaire;
  bool _isLoading = false;
  File? _selectedImage;
  String? _uploadedPhotoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedDate = widget.user.dateNaissance;
    _loadMaisons();
  }

  Future<void> _loadMaisons() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('maisons').get();
      final maisons = snapshot.docs.map((doc) {
        return MaisonModel.fromMap(doc.data(), doc.id);
      }).toList();

      MaisonModel? selected;
      if (maisons.isNotEmpty) {
        selected = maisons.firstWhere(
          (m) => m.id == widget.user.maisonId,
          orElse: () => maisons.first,
        );
        await _loadLinkedData(selected);
      }

      setState(() {
        _maisons = maisons;
        _selectedMaison = selected;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur de chargement des maisons : $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLinkedData(MaisonModel maison) async {
    try {
      final quartierDoc = await FirebaseFirestore.instance
          .collection('quartiers')
          .doc(maison.quartierId)
          .get();
      final proprietaireDoc = await FirebaseFirestore.instance
          .collection('proprietaires')
          .doc(maison.proprietaireId)
          .get();

      setState(() {
        _quartier = Quartier.fromMap(quartierDoc.data()!, quartierDoc.id);
        _proprietaire = ProprietaireModel.fromMap(proprietaireDoc.data()!, proprietaireDoc.id);
      });
    } catch (e) {
      print("Erreur de chargement des données liées : $e");
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dpfxtypn2';
    const uploadPreset = 'profile';

    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      final respData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(respData);
        return data['secure_url'];
      } else {
        print("❌ Échec Cloudinary (code ${response.statusCode}) : $respData");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception pendant l'upload Cloudinary : $e");
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));

      final uploadedUrl = await _uploadToCloudinary(_selectedImage!);
      if (uploadedUrl != null) {
        setState(() => _uploadedPhotoUrl = uploadedUrl);

        // Mettre à jour la photo dans Firebase Authentication
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePhotoURL(uploadedUrl);
          await user.reload();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec de l'envoi de l'image"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        dateNaissance: _selectedDate!,
        maisonId: _selectedMaison?.id ?? '',
        quartierId: _selectedMaison?.quartierId ?? '',
        proprietaireId: _selectedMaison?.proprietaireId ?? '',
        photoUrl: _uploadedPhotoUrl ?? widget.user.photoUrl,
      );

      // Mettre à jour la photo de l'utilisateur dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(updatedUser.uid)
          .update({
        'photoUrl': _uploadedPhotoUrl ?? widget.user.photoUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context, updatedUser);
    } catch (e) {
      print("❌ Erreur lors de la mise à jour : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de mise à jour : $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Modifier le Profil", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        )),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        elevation: 8,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo de profil
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [accentColor, primaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _uploadedPhotoUrl != null
                                  ? NetworkImage(_uploadedPhotoUrl!)
                                  : widget.user.photoUrl != null
                                      ? NetworkImage(widget.user.photoUrl!)
                                      : null,
                              backgroundColor: Colors.transparent,
                              child: (_uploadedPhotoUrl == null && widget.user.photoUrl == null)
                                  ? Icon(Icons.person, size: 60, color: Colors.white)
                                  : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),)
                              ],
                            ),
                            child: Icon(Icons.camera_alt, color: primaryColor, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Informations personnelles
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),)
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Informations personnelles",
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nom complet
                        Text("Nom complet", style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.person, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Email
                        Text("Email", style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            prefixIcon: Icon(Icons.email, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Date de naissance
                        Text("Date de naissance", style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: backgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedDate == null
                                      ? "Choisir une date"
                                      : "${_selectedDate!.toLocal()}".split(' ')[0],
                                  style: TextStyle(
                                    color: _selectedDate == null 
                                        ? textSecondary 
                                        : textPrimary,
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down, color: primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Adresse et informations liées
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Adresse et informations",
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Sélection Maison
                        Text("Adresse", style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        )),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<MaisonModel>(
                          value: _selectedMaison,
                          items: _maisons.map((maison) {
                            return DropdownMenuItem<MaisonModel>(
                              value: maison,
                              child: Text(
                                maison.adresse,
                                style: TextStyle(fontSize: 16, color: textPrimary),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            prefixIcon: Icon(Icons.home, color: primaryColor),
                          ),
                          onChanged: (value) {
                            setState(() => _selectedMaison = value);
                            _loadLinkedData(value!);
                          },
                          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                          borderRadius: BorderRadius.circular(16),
                          dropdownColor: Colors.white,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Informations liées
                        if (_quartier != null || _proprietaire != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Informations liées", style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                              )),
                              const SizedBox(height: 16),
                              
                              // Quartier
                              if (_quartier != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryColor.withOpacity(0.1),
                                        ),
                                        child: Icon(Icons.location_city, color: primaryColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Quartier", style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 14,
                                          )),
                                          const SizedBox(height: 4),
                                          Text(
                                            _quartier!.nom,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Propriétaire
                              if (_proprietaire != null)
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primaryColor.withOpacity(0.1),
                                      ),
                                      child: Icon(Icons.person_pin, color: primaryColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Propriétaire", style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 14,
                                        )),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${_proprietaire!.prenom} ${_proprietaire!.nom}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Bouton Enregistrer
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Enregistrer les modifications",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}