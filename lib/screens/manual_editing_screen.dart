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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F4F6C), Color(0xFF1E8F9B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22003D4B),
                    blurRadius: 28,
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
                      'Step 5 of 6',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manual refinement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Adjust the burn mask with clinical judgment while keeping the source image untouched.',
                    style: TextStyle(
                      color: Color(0xFFE2F7F8),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InfoCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F6F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.brush_outlined,
                          color: Color(0xFF1E8F9B),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refine the burn mask',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use Add Burn or Erase Burn to correct the AI output in real time while keeping the image and mask separate.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (imageFile != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FBFB),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD8EBEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.gesture_outlined,
                                  size: 18,
                                  color: Color(0xFF1E8F9B),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Interactive editing canvas',
                                  style: TextStyle(
                                    color: Color(0xFF234044),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          BurnEditorCanvas(imageFile: imageFile),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FBFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD8EBEE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Editing tools',
                          style: TextStyle(
                            color: Color(0xFF234044),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                            context
                                .read<EditingProvider>()
                                .setMode(selection.first);
                          },
                        ),
                        const SizedBox(height: 20),
                        _SliderCard(
                          label: 'Brush size',
                          value: editing.brushSize.toStringAsFixed(0),
                          icon: Icons.radio_button_checked_outlined,
                          child: Slider(
                            min: 1,
                            max: 100,
                            value: editing.brushSize,
                            onChanged: (value) {
                              context
                                  .read<EditingProvider>()
                                  .setBrushSize(value);
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SliderCard(
                          label: 'AI sensitivity',
                          value: editing.sensitivity.toStringAsFixed(2),
                          icon: Icons.tune,
                          child: Slider(
                            min: 0,
                            max: 1,
                            value: editing.sensitivity,
                            onChanged: (value) {
                              context
                                  .read<EditingProvider>()
                                  .setSensitivity(value);
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatPanel(
                          label: 'Current TBSA',
                          value:
                              '${editing.burnPercentage.toStringAsFixed(2)}%',
                          icon: Icons.local_fire_department_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPanel(
                          label: 'Edit mode',
                          value:
                              editing.mode == EditingMode.add ? 'Add' : 'Erase',
                          icon: editing.mode == EditingMode.add
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: imageFile == null || !editing.hasMask
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ReportGenerationScreen(),
                          ),
                        );
                      },
                icon: const Icon(Icons.description_outlined),
                label: const Text('Continue to Report Generation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.child,
  });

  final String label;
  final String value;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9EDEF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF1E8F9B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF234044),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E8F9B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _StatPanel extends StatelessWidget {
  const _StatPanel({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8EBEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1E8F9B)),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF628185),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF234044),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
