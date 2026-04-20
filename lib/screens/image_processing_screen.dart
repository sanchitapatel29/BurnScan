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
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF814E14), Color(0xFFCC8C34)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22A05A11),
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
                      'Step 3 of 6',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Local preprocessing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Prepare the wound image with local-only enhancement before handing it to the AI detection stage.',
                    style: TextStyle(
                      color: Color(0xFFFFF1DC),
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
                          color: const Color(0xFFFFF3E3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_outlined,
                          color: Color(0xFFC27C20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Processing pipeline',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Background suppression and contrast enhancement are simulated locally for offline reliability.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFAF3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF0DFC6)),
                    ),
                    child: workflow.isBusy
                        ? const SizedBox(
                            height: 340,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 42,
                                    width: 42,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3.2,
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                  Text(
                                    'Enhancing image locally...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4F3E2A),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Applying simulated background cleanup and contrast balancing.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF7B6A55),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : workflow.processedImage != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.image_search_outlined,
                                          size: 18,
                                          color: Color(0xFFC27C20),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Processed image preview',
                                          style: TextStyle(
                                            color: Color(0xFF493827),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MaskedImageView(
                                    imageFile: workflow.processedImage!,
                                    height: 340,
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 280,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 42,
                                          color: Color(0xFFC27C20),
                                        ),
                                        const SizedBox(height: 14),
                                        const Text(
                                          'Processing unavailable',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF493827),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          workflow.error ??
                                              'Processing failed.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF7B6A55),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: _PipelineBadge(
                          icon: Icons.layers_clear_outlined,
                          title: 'Background cleanup',
                          subtitle: 'Simulated',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _PipelineBadge(
                          icon: Icons.auto_fix_high_outlined,
                          title: 'CLAHE boost',
                          subtitle: 'Simulated',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _PipelineBadge(
                    icon: Icons.offline_bolt_outlined,
                    title: 'Offline processing',
                    subtitle:
                        'All enhancement happens inside the app without a network dependency.',
                    expanded: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: workflow.processedImage == null
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const AIDetectionScreen(),
                                ),
                              );
                            },
                      icon: const Icon(Icons.psychology_alt_outlined),
                      label: const Text('Continue to AI Detection'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineBadge extends StatelessWidget {
  const _PipelineBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.expanded = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0DFC6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0D9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFC27C20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF493827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7B6A55),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
