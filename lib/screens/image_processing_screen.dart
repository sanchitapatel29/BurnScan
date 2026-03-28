import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/screens/ai_detection_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:burn_scan/widgets/masked_image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageProcessingScreen extends StatefulWidget {
  const ImageProcessingScreen({super.key});

  @override
  State<ImageProcessingScreen> createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends State<ImageProcessingScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ImageWorkflowProvider>().processCurrentImage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ImageWorkflowProvider>();

    return AppShell(
      title: 'Image Processing',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Local preprocessing',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Background suppression and contrast enhancement are simulated locally for offline reliability.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (workflow.isBusy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (workflow.processedImage != null)
                const SizedBox.shrink()
              else
                Container(
                  height: 240,
                  alignment: Alignment.center,
                  child: Text(workflow.error ?? 'Processing failed.'),
                ),
              if (!workflow.isBusy && workflow.processedImage != null)
                MaskedImageView(
                  imageFile: workflow.processedImage!,
                  height: 340,
                ),
              const SizedBox(height: 24),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Chip(label: Text('Background removal: simulated')),
                  Chip(label: Text('CLAHE enhancement: simulated')),
                  Chip(label: Text('Offline processing')),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: workflow.processedImage == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AIDetectionScreen(),
                            ),
                          );
                        },
                  child: const Text('Continue to AI Detection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}