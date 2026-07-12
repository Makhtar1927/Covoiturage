import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/glass_container.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedCircle = 'UKAC Touba';
  final List<String> _circles = [
    'UKAC Touba',
    'Quartier Dianatou',
    'Résidence Darou Khoudoss',
    'Complexe Keur Nabi'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      
      // Perform log in and circle joining
      ref.read(currentUserProvider.notifier).loginAndVerify(name, email, _selectedCircle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final textColor = cs.onSurface;
    final subtitleColor = cs.onSurface.withValues(alpha: 0.6);
    final inputBorderColor = cs.onSurface.withValues(alpha: 0.15);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: cs.secondary.withValues(alpha: isDark ? 0.25 : 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Scrollable content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo / Icon
                    Center(
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_car_filled_rounded,
                          color: isDark ? Colors.black87 : Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "CommuniRide",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "Le covoiturage communautaire de confiance.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Glassmorphic Input Card
                    GlassContainer(
                      padding: const EdgeInsets.all(24.0),
                      useWhiteBlend: !isDark,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Inscription / Connexion",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Entrez votre adresse email @gmail.com pour rejoindre un cercle vérifié.",
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: "Nom complet",
                                labelStyle: TextStyle(color: subtitleColor),
                                prefixIcon: Icon(Icons.person_outline_rounded, color: subtitleColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: inputBorderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: inputBorderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: cs.primary),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Veuillez entrer votre nom";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: "Adresse email",
                                labelStyle: TextStyle(color: subtitleColor),
                                prefixIcon: Icon(Icons.email_outlined, color: subtitleColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: inputBorderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: inputBorderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: cs.primary),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Veuillez entrer votre adresse email";
                                }
                                final val = value.trim().toLowerCase();
                                if (!val.endsWith('@gmail.com')) {
                                  return "L'adresse email doit se terminer par @gmail.com";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Circle selection
                            DropdownButtonFormField<String>(
                              value: _selectedCircle,
                              isExpanded: true,
                              dropdownColor: cs.surface,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                labelText: "Rejoindre un Cercle",
                                labelStyle: TextStyle(color: subtitleColor),
                                prefixIcon: Icon(Icons.group_work_outlined, color: subtitleColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: inputBorderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: inputBorderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: BorderSide(color: cs.primary),
                                ),
                              ),
                              items: _circles.map((String circle) {
                                return DropdownMenuItem<String>(
                                  value: circle,
                                  child: Text(
                                    circle,
                                    style: TextStyle(color: textColor),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCircle = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 30),
                            // Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: cs.onPrimary,
                                backgroundColor: cs.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 5,
                                shadowColor: cs.primary.withValues(alpha: 0.3),
                              ),
                              onPressed: _submit,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "S'inscrire & Rejoindre",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20, color: cs.onPrimary),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
