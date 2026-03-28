import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/screens/manual_editing_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:burn_scan/widgets/masked_image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AIDetectionScreen extends StatefulWidget {
  const AIDetectionScreen({super.key});

  @override
  State<AIDetectionScreen> createState() => _AIDetectionScreenState();
}

class _AIDetectionScreenState extends State<AIDetectionScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _runDetection());
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ImageWorkflowProvider>();
    final detection = workflow.detectionResult;

    return AppShell(
      title: 'AI Detection',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Burn region prediction',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'The ML service is abstracted behind a placeholder detector and can be replaced with your external API later.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (workflow.isBusy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (workflow.processedImage != null &&
                  detection != null) ...[
                MaskedImageView(
                  imageFile: workflow.processedImage!,
                  maskBytes: detection.maskBytes,
                  height: 340,
                ),
                const SizedBox(height: 16),
                Text(
                  'Estimated burn coverage: ${detection.estimatedTbsa.toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ] else
                Container(
                  height: 220,
                  alignment: Alignment.center,
                  child: Text(workflow.error ?? 'Detection unavailable.'),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: workflow.isBusy ? null : _runDetection,
                      child: const Text('Run Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: detection == null ||
                              workflow.processedImage == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ManualEditingScreen(),
                                ),
                              );
                            },
                      child: const Text('Continue to Manual Editing'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runDetection() async {
    final result = await context.read<ImageWorkflowProvider>().detectBurn();
    if (result != null && mounted) {
      context.read<EditingProvider>().initializeFromDetection(result);
    }
  }
}