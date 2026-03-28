import 'package:burn_scan/providers/auth_provider.dart';
import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/providers/patient_provider.dart';
import 'package:burn_scan/screens/auth_screen.dart';
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
      title: 'BurnScan Home',
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
              MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinical burn workflow',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Offline-first assessment with image processing, AI-assisted detection, manual correction, and exportable reports.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
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
