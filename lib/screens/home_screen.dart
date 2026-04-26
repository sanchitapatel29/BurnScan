import 'package:burn_scan/providers/auth_provider.dart';
import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/providers/patient_provider.dart';
import 'package:burn_scan/screens/login_screen.dart';
import 'package:burn_scan/screens/patient_details_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/home_action_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'BurnScan',
      actions: [
        IconButton(
          onPressed: () async {
            context.read<PatientProvider>().clear();
            context.read<ImageWorkflowProvider>().reset();
            context.read<EditingProvider>().clear();
            await context.read<AuthProvider>().logout();
            if (!context.mounted) {
              return;
            }
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF053847),
                    Color(0xFF0A7778),
                    Color(0xFF52B7AE)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22003B3F),
                    blurRadius: 30,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Start an assessment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Choose a module to continue the burn assessment workflow.',
                    style: TextStyle(
                      color: Color(0xFFD9F6F2),
                      height: 1.45,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Calculate TBSA is the primary workflow for patient assessment.',
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                HomeActionTile(
                  title: 'Calculate TBSA',
                  icon: Icons.healing,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PatientDetailsScreen(),
                      ),
                    );
                  },
                ),
                HomeActionTile(
                  title: 'Patient Queue',
                  icon: Icons.groups_2,
                  onTap: () => _showPlaceholder(context),
                ),
                HomeActionTile(
                  title: 'Saved Reports',
                  icon: Icons.folder_copy,
                  onTap: () => _showPlaceholder(context),
                ),
                HomeActionTile(
                  title: 'Body Map',
                  icon: Icons.accessibility_new,
                  onTap: () => _showPlaceholder(context),
                ),
                HomeActionTile(
                  title: 'Care Notes',
                  icon: Icons.note_alt,
                  onTap: () => _showPlaceholder(context),
                ),
                HomeActionTile(
                  title: 'Settings',
                  icon: Icons.tune,
                  onTap: () => _showPlaceholder(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Placeholder module ready for future expansion.'),
      ),
    );
  }
}
