import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/screens/report_generation_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/burn_editor_canvas.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManualEditingScreen extends StatelessWidget {
  const ManualEditingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ImageWorkflowProvider>();
    final editing = context.watch<EditingProvider>();
    final imageFile = workflow.processedImage;

    return AppShell(
      title: 'Manual Editing',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refine the burn mask',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use Add Burn or Erase Burn to correct the AI output in real time while keeping the image and mask separate.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (imageFile != null) BurnEditorCanvas(imageFile: imageFile),
                  const SizedBox(height: 20),
                  SegmentedButton<EditingMode>(
                    segments: const [
                      ButtonSegment(
                        value: EditingMode.add,
                        label: Text('Add Burn'),
                        icon: Icon(Icons.brush),
                      ),
                      ButtonSegment(
                        value: EditingMode.erase,
                        label: Text('Erase Burn'),
                        icon: Icon(Icons.auto_fix_off),
                      ),
                    ],
                    selected: {editing.mode},
                    onSelectionChanged: (selection) {
                      context.read<EditingProvider>().setMode(selection.first);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Brush size: ${editing.brushSize.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    min: 1,
                    max: 100,
                    value: editing.brushSize,
                    onChanged: (value) {
                      context.read<EditingProvider>().setBrushSize(value);
                    },
                  ),
                  Text(
                    'AI sensitivity: ${editing.sensitivity.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    min: 0,
                    max: 1,
                    value: editing.sensitivity,
                    onChanged: (value) {
                      context.read<EditingProvider>().setSensitivity(value);
                    },
                    onChangeEnd: (value) async {
                      final result = await context
                          .read<ImageWorkflowProvider>()
                          .detectBurn(sensitivity: value);
                      if (result != null && context.mounted) {
                        context
                            .read<EditingProvider>()
                            .initializeFromDetection(result);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current estimated TBSA: ${editing.burnPercentage.toStringAsFixed(2)}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: imageFile == null || !editing.hasMask
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ReportGenerationScreen(),
                          ),
                        );
                      },
                child: const Text('Continue to Report Generation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
