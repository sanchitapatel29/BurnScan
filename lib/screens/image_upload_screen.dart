import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/screens/image_processing_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:burn_scan/widgets/masked_image_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ImageUploadScreen extends StatelessWidget {
  const ImageUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workflow = context.watch<ImageWorkflowProvider>();

    return AppShell(
      title: 'Image Upload',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acquire wound image',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Capture a new image or choose one from the device gallery.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: workflow.isBusy
                          ? null
                          : () => _pick(context, ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Capture'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: workflow.isBusy
                          ? null
                          : () => _pick(context, ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              if (workflow.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  workflow.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (workflow.selectedImage != null)
                MaskedImageView(imageFile: workflow.selectedImage!, height: 320)
              else
                Container(
                  height: 240,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: const Text('No image selected yet.'),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: workflow.selectedImage == null
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ImageProcessingScreen(),
                            ),
                          );
                        },
                  child: const Text('Continue to Processing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    await context.read<ImageWorkflowProvider>().pickImage(source);
  }
}