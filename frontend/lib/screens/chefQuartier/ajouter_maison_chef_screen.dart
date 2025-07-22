import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/proprietaire.dart';
import '../../models/maison.dart';

class AjouterMaisonChefScreen extends StatefulWidget {
  final UserModel chef;
  final MaisonModel? maison;
  final Color primaryColor = const Color(0xFF00C9B8);
  final Color secondaryColor = const Color(0xFF009688);
  final Color accentColor = const Color(0xFF00EAD3);
  final Color backgroundColor = const Color(0xFFF0FAF8);
  final Color textPrimary = const Color(0xFF333333);
  final Color textSecondary = const Color(0xFF666666);

  const AjouterMaisonChefScreen({super.key, required this.chef, this.maison});

  @override
  State<AjouterMaisonChefScreen> createState() => _AjouterMaisonChefScreenState();
}

class _AjouterMaisonChefScreenState extends State<AjouterMaisonChefScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adresseController = TextEditingController();
  List<ProprietaireModel> proprietaires = [];
  ProprietaireModel? proprietaireSelectionne;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProprietairesDuQuartier();
    if (widget.maison != null) {
      _adresseController.text = widget.maison!.adresse;
    }
  }

  Future<void> _chargerProprietairesDuQuartier() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('proprietaires')
          .where('quartierId', isEqualTo: widget.chef.quartierId)
          .get();

      final loadedProprietaires = snapshot.docs.map((doc) {
        return ProprietaireModel.fromMap(doc.data(), doc.id);
      }).toList();

      setState(() {
        proprietaires = loadedProprietaires;
        if (widget.maison != null && proprietaires.isNotEmpty) {
          try {
            proprietaireSelectionne = proprietaires.firstWhere(
              (p) => p.id == widget.maison!.proprietaireId,
            );
          } catch (e) {
            proprietaireSelectionne = null;
          }
        }
        isLoading = false;
      });
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

  Future<void> _enregistrerMaison() async {
    if (!_formKey.currentState!.validate()) return;

    final adresse = _adresseController.text.trim();
    final proprietaireId = proprietaireSelectionne?.id ?? '';

    try {
      final data = {
        'adresse': adresse,
        'quartierId': widget.chef.quartierId,
        'proprietaireId': proprietaireId,
      };

      if (widget.maison == null) {
        // Création
        await FirebaseFirestore.instance.collection('maisons').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🏠 Maison ajoutée avec succès"),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        // Mise à jour
        await FirebaseFirestore.instance
            .collection('maisons')
            .doc(widget.maison!.id)
            .update(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("🔄 Maison modifiée avec succès"),
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

Future<void> _supprimerMaison() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, size: 32, color: Colors.white),
                  const SizedBox(width: 16),
                  Text(
                    "Confirmer la suppression",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Voulez-vous vraiment supprimer cette maison ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: widget.textSecondary),
                          ),
                          child: Text(
                            "Annuler",
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.textSecondary,
                              fontWeight: FontWeight.w600,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Supprimer",
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirm == true) {
    try {
      await FirebaseFirestore.instance
          .collection('maisons')
          .doc(widget.maison!.id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🗑️ Maison supprimée avec succès"),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erreur de suppression: $e"),
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

  @override
  void dispose() {
    _adresseController.dispose();
    super.dispose();
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    String? Function(String?)? validator,
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
      child: DropdownButtonFormField<ProprietaireModel>(
        isExpanded: true,
        value: proprietaireSelectionne,
        items: [
          DropdownMenuItem(
            value: null,
            child: Text("Sélectionnez un propriétaire", 
                      style: TextStyle(
                        color: widget.textSecondary,
                        fontStyle: FontStyle.italic
                      )),
          ),
          ...proprietaires.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Text("${p.nom} ${p.prenom}"),
            );
          }).toList(),
        ],
        onChanged: (value) => setState(() => proprietaireSelectionne = value),
        decoration: InputDecoration(
          labelText: 'Propriétaire',
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
            child: Icon(Icons.person, color: widget.primaryColor, size: 22),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
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
    final isEdit = widget.maison != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Modifier Maison" : "Ajouter une Maison",
          style: const TextStyle(
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
                      "Chargement des propriétaires...",
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
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
                                      color: widget.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isEdit ? Icons.home_work : Icons.add_home_work,
                                      size: 28,
                                      color: widget.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    isEdit ? "Modifier la maison" : "Ajouter une maison",
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
                                "Remplissez les informations de la maison",
                                style: TextStyle(
                                  color: widget.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildFormField(
                                controller: _adresseController,
                                labelText: 'Adresse complète',
                                icon: Icons.location_on_outlined,
                                validator: (value) => 
                                    value!.isEmpty ? 'Adresse requise' : null,
                              ),
                              _buildDropdownField(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _enregistrerMaison,
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
                                isEdit ? "Mettre à jour" : "Ajouter la maison",
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
                        if (isEdit) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shadowColor: Colors.red.withOpacity(0.3),
                            ),
                            onPressed: _supprimerMaison,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  "Supprimer la maison",
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
                                    child: Icon(Icons.delete, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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