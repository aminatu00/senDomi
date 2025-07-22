import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DemandeCertificatScreen extends StatefulWidget {
  @override
  _DemandeCertificatScreenState createState() =>
      _DemandeCertificatScreenState();
}

class _DemandeCertificatScreenState extends State<DemandeCertificatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _raisonController = TextEditingController();
  String? _validiteSelectionnee;

  PlatformFile? _cinFile;
  PlatformFile? _justificatifFile;

  bool _isSubmitting = false;

  // Nouvelle palette turquoise 🎨
  final Color primaryColor = const Color(0xFF00C9B8);   // Turquoise vif
  final Color secondaryColor = const Color(0xFF009688);  // Turquoise foncé
  final Color accentColor = const Color(0xFF00EAD3);     // Turquoise clair
  final Color backgroundColor = const Color(0xFFF0FAF8); // Fond très clair
  final Color textPrimary = const Color(0xFF333333);     // Texte principal
  final Color textSecondary = const Color(0xFF666666);   // Texte secondaire

  // Cloudinary config
  final String cloudinaryCloudName = 'dpfxtypn2';
  final String cloudinaryUploadPreset = 'senDomicile';

  Future<void> _pickFile(bool isCIN) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          if (isCIN) {
            _cinFile = result.files.first;
          } else {
            _justificatifFile = result.files.first;
          }
        });
      }
    } catch (e) {
      print("Erreur de sélection de fichier: $e");
      _showErrorSnackBar("Erreur lors de la sélection du fichier");
    }
  }

  Future<String?> _uploadToCloudinary(PlatformFile file, String fileType) async {
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/auto/upload');
      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = cloudinaryUploadPreset;

      if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path!,
          filename: file.name,
        ));
      } else {
        _showErrorSnackBar("Fichier invalide ou introuvable.");
        return null;
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = json.decode(responseData);
        return jsonData['secure_url'];
      } else {
        _showErrorSnackBar("Erreur d'upload $fileType : ${response.statusCode}");
        return null;
      }
    } catch (e) {
      _showErrorSnackBar("Erreur d'upload ($fileType) : $e");
      return null;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _soumettreDemande() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cinFile == null || _justificatifFile == null) {
      _showErrorSnackBar('Veuillez téléverser tous les documents.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar("Utilisateur non connecté.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('quartierId')) {
        _showErrorSnackBar("Impossible de récupérer le quartier de l'utilisateur.");
        setState(() => _isSubmitting = false);
        return;
      }
      final quartierId = userData['quartierId'];

      final cinUrl = await _uploadToCloudinary(_cinFile!, 'CIN');
      final justificatifUrl = await _uploadToCloudinary(_justificatifFile!, 'Justificatif');

      if (cinUrl != null && justificatifUrl != null) {
        await FirebaseFirestore.instance.collection('demandes').add({
          'raison': _raisonController.text.trim(),
          'date_validite': _validiteSelectionnee,
          'cin_url': cinUrl,
          'justificatif_url': justificatifUrl,
          'etat': 'en cours',
          'habitantId': user.uid,
          'quartierId': quartierId,
          'motif_annulation': null,
          'date_creation': FieldValue.serverTimestamp(),
        });

        _showSuccessSnackBar("Demande envoyée avec succès!");

        setState(() {
          _raisonController.clear();
          _validiteSelectionnee = null;
          _cinFile = null;
          _justificatifFile = null;
          _isSubmitting = false;
        });
      } else {
        _showErrorSnackBar("Erreur lors de l'envoi des fichiers.");
        setState(() => _isSubmitting = false);
      }
    } catch (e) {
      _showErrorSnackBar("Erreur lors de la soumission : $e");
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _raisonController.dispose();
    super.dispose();
  }

  Widget _buildFileCard(PlatformFile? file, String label, IconData icon, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              backgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentColor, primaryColor],
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(label, style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
                ],
              ),
              const SizedBox(height: 16),
              
              if (file != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          file.name,
                          style: TextStyle(fontSize: 14, color: textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() {
                          if (label.contains("CIN")) {
                            _cinFile = null;
                          } else {
                            _justificatifFile = null;
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: primaryColor),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload, size: 20),
                    const SizedBox(width: 8),
                    Text("Sélectionner un fichier"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Demande de Certificat", style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône
              Center(
                child: Container(
                  width: 80,
                  height: 80,
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
                  child: const Icon(Icons.assignment, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              
              // Titre
              Center(
                child: Text(
                  "Formulaire de demande",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Remplissez les informations requises pour votre demande",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              
              // Raison de la demande
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("Raison de la demande", style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
              ),
              TextFormField(
                controller: _raisonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Ex: Ouverture de compte, inscription scolaire...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  prefixIcon: Icon(Icons.text_snippet, color: primaryColor),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Veuillez entrer une raison.' : null,
              ),
              const SizedBox(height: 24),
              
              // Durée de validité
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("Durée de validité du justificatif", style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )),
              ),
              DropdownButtonFormField<String>(
                value: _validiteSelectionnee,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                ),
                items: [
                  DropdownMenuItem(value: 'moins_1_mois', child: Text('Moins de 1 mois')),
                  DropdownMenuItem(value: '3_mois', child: Text('3 mois')),
                  DropdownMenuItem(value: 'plus_3_mois', child: Text('Plus de 3 mois')),
                ],
                onChanged: (value) => setState(() => _validiteSelectionnee = value),
                validator: (value) =>
                    value == null ? 'Veuillez choisir une durée de validité.' : null,
                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 40),
              
              // Documents
              Text("Documents à fournir", style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
              const SizedBox(height: 16),
              Text(
                "Veuillez téléverser les documents suivants :",
                style: TextStyle(color: textSecondary),
              ),
              const SizedBox(height: 24),
              
              _buildFileCard(_cinFile, "Copie de la CIN", Icons.badge, () => _pickFile(true)),
              _buildFileCard(_justificatifFile, "Justificatif de domicile", Icons.home, () => _pickFile(false)),
              const SizedBox(height: 40),
              
              // Bouton Soumettre
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
                    onPressed: _isSubmitting ? null : _soumettreDemande,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                "Soumettre la demande",
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
      ),
    );
  }
}