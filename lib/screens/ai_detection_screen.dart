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
    final confidence =
        detection == null ? 0.0 : (0.68 + (detection.sensitivity * 0.24));

    return AppShell(
      title: 'AI Detection',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B175F), Color(0xFFB33A8B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22A62671),
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
                      'Step 4 of 6',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI-assisted detection',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review the machine-generated burn mask before moving into manual correction.',
                    style: TextStyle(
                      color: Color(0xFFFFE6F4),
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
                          color: const Color(0xFFFBE6F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_outlined,
                          color: Color(0xFFB33A8B),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prediction result',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 26),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The ML service is abstracted behind a placeholder detector and can be replaced with your external API later.',
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
                      color: const Color(0xFFFFF7FB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF2D8E8)),
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
                                    'Running AI detection...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF5A2446),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Generating an assistive burn mask from the processed wound image.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF845E76),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : workflow.processedImage != null && detection != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.visibility_outlined,
                                          size: 18,
                                          color: Color(0xFFB33A8B),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Annotated detection preview',
                                          style: TextStyle(
                                            color: Color(0xFF4A233C),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MaskedImageView(
                                    imageFile: workflow.processedImage!,
                                    maskBytes: detection.maskBytes,
                                    height: 340,
                                  ),
                                ],
                              )
                            : SizedBox(
                                height: 260,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 42,
                                          color: Color(0xFFB33A8B),
                                        ),
                                        const SizedBox(height: 14),
                                        const Text(
                                          'Detection unavailable',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4A233C),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          workflow.error ??
                                              'Detection unavailable.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF845E76),
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
                  if (detection != null)
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Estimated TBSA',
                            value:
                                '${detection.estimatedTbsa.toStringAsFixed(2)}%',
                            icon: Icons.local_fire_department_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Model confidence',
                            value: '${(confidence * 100).toStringAsFixed(0)}%',
                            icon: Icons.query_stats_outlined,
                          ),
                        ),
                      ],
                    ),
                  if (detection != null) ...[
                    const SizedBox(height: 12),
                    const _InsightBanner(
                      icon: Icons.edit_note_outlined,
                      text:
                          'Use manual editing next to correct boundaries, add missed regions, or erase false positives.',
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: workflow.isBusy ? null : _runDetection,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Run Again'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB33A8B),
                            minimumSize: const Size.fromHeight(56),
                            side: const BorderSide(
                              color: Color(0xFFE3B9D2),
                              width: 1.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: detection == null ||
                                  workflow.processedImage == null
                              ? null
                              : () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const ManualEditingScreen(),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.brush_outlined),
                          label: const Text('Manual Editing'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
        color: const Color(0xFFFFF7FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2D8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFCEAF4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFB33A8B)),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A5670),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4A233C),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0D3E5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB33A8B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6F5164),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
