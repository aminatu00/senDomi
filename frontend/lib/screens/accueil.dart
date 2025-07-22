import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AccueilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/home_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dégradé professionnel
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A2E3A).withOpacity(0.85),
                  Color(0xFF1A4F5F).withOpacity(0.75),
                  Color(0xFF2A7F8F).withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Contenu
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // --- Header logo + boutons ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo + nom
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Image.asset(
                                'assets/logoAc.png',
                                height: 50,
                                width: 50,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 6),
                            // Text(
                            //   'senDomicile',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 20,
                            //     fontWeight: FontWeight.bold,
                            //     letterSpacing: 1.1,
                            //   ),
                            // ),
                          ],
                        ),

                        // Boutons responsives
                        screenWidth > 400
                            ? Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                                    },
                                    child: Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00C9B8), // Turquoise vif
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      'S\'inscrire',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                                    },
                                    child: Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00C9B8), // Turquoise vif
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      'S\'inscrire',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // --- Texte principal ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Obtenez votre',
                          style: TextStyle(
                            fontSize: screenWidth < 400 ? 30 : 38,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            height: 1.3,
                          ),
                        ),
                        Text(
                          'certificat de domicile',
                          style: TextStyle(
                            fontSize: screenWidth < 400 ? 34 : 42,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          'en quelques clics',
                          style: TextStyle(
                            fontSize: screenWidth < 400 ? 30 : 38,
                            color: Color(0xFF00EAD3), // Turquoise clair
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // --- Description ---
                    Container(
                      width: screenWidth < 600 ? double.infinity : screenWidth * 0.6,
                      child: Text(
                        'Solution numérique simple, rapide et sécurisée pour vos démarches administratives',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // --- Bouton principal ---
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C9B8), Color(0xFF009688)], // Dégradé turquoise
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00C9B8).withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Commencer maintenant',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 22, color: Colors.white),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 50),

                    // --- Avantages ---
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        FeatureItem(icon: Icons.bolt_rounded, text: 'Rapide', color: Color(0xFF00EAD3)),
                        FeatureItem(icon: Icons.lock_rounded, text: 'Sécurisé', color: Color(0xFF00EAD3)),
                        FeatureItem(icon: Icons.phone_iphone_rounded, text: 'Mobile', color: Color(0xFF00EAD3)),
                        FeatureItem(icon: Icons.assignment_turned_in_rounded, text: 'Officiel', color: Color(0xFF00EAD3)),
                      ],
                    ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget Avantage ---
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const FeatureItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}