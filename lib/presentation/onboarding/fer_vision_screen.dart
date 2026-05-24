import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

/// FER Vision Screen
/// Explains the deep purpose of the FER Network in an inspiring, clear way.
/// This is the heart of the app's identity and reason for existing.
class FerVisionScreen extends StatelessWidget {
  const FerVisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('FER Network — De Visie'),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_moon_outlined,
                    size: 64,
                    color: AppTheme.primary,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Een autonoom netwerk\nvoor ferrets & mensen',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Quantum-bestendig. Offline-first. Privé. Gemaakt met AI.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            _buildSection(
              context,
              icon: Icons.security,
              title: 'Waarom dit bestaat',
              content:
                  'In een wereld van surveillance, afhankelijkheid van big tech en opkomende quantum computers, verdient iedereen een netwerk dat écht van henzelf is. FER Network is mijn antwoord: een privé, veerkrachtig digitaal thuis voor autonome wezens — ferrets en mensen.',
            ),

            _buildSection(
              context,
              icon: Icons.offline_bolt,
              title: 'Offline-first & Resilient',
              content:
                  'Werkt zonder constant internet. Slaat berichten, bestanden en wallet data lokaal op met SQLite. Synchroniseert slim wanneer verbinding terug is. Frequency-hopping zorgt voor veerkrachtige communicatie. Nooit meer "geen verbinding" als je het écht nodig hebt.',
            ),

            _buildSection(
              context,
              icon: Icons.lock,
              title: 'Quantum-bestendig (Post-Quantum)',
              content:
                  'Lattice-based encryptie (experimentele/educatieve implementatie van post-quantum concepten). Voorbereid op een toekomst waarin huidige encryptie mogelijk gebroken wordt. Privacy die meegroeit met de technologie.',
            ),

            _buildSection(
              context,
              icon: Icons.pets,
              title: 'De Ferret Identiteit (AiFERiD)',
              content:
                  'Dit is geen generieke app. Het is een digitale autonome ferret — speels, nieuwsgierig, veerkrachtig. AiFERiD is jouw (en mijn) identiteit in dit netwerk. Een creatief statement en een praktische tool tegelijk. Gemaakt in nauwe samenwerking met AI (Claude).',
            ),

            _buildSection(
              context,
              icon: Icons.gamepad,
              title: 'Speels & Bruikbaar',
              content:
                  'Base44 donkere UI met kleurrijke tiles, animaties en micro-interacties. Omdat serieuze privacy en veerkracht ook mooi en leuk mogen zijn. Messaging, wallet, bestanden, gaming hub — alles voelt als een game, maar werkt als een serieuze tool.',
            ),

            SizedBox(height: 4.h),

            // Credits & co-creation
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    'Co-created with human creativity & Claude',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Dit project is ontstaan uit nieuwsgierigheid, praktische noodzaak en de lol van mens + AI samen complexe systemen bouwen. De ferret is de spirit animal.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.networkDashboard,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Begin met FER Network'),
              ),
            ),

            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: () {
                  // Could open settings or crypto info later
                  Navigator.pop(context);
                },
                child: Text(
                  'Terug naar Dashboard',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 28),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
