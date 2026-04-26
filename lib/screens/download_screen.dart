import 'dart:io';

import 'package:burn_scan/models/report_file_type.dart';
import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/providers/patient_provider.dart';
import 'package:burn_scan/screens/reports_history_screen.dart';
import 'package:burn_scan/services/report_service.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({
    super.key,
    required this.fileName,
    required this.fileType,
  });

  final String fileName;
  final ReportFileType fileType;

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  File? _outputFile;
  String? _error;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  @override
  Widget build(BuildContext context) {
    final success = !_busy && _error == null;

    return AppShell(
      title: 'Download Report',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: success
                      ? const [Color(0xFF115D40), Color(0xFF2EAA73)]
                      : const [Color(0xFF7A1F2D), Color(0xFFC84E5E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22003B3F),
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
                      'Export Result',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _busy
                        ? 'Saving report locally'
                        : success
                            ? 'Report saved successfully'
                            : 'Unable to generate report',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _busy
                        ? 'Finalizing the export package and writing the file to local app storage.'
                        : success
                            ? 'The assessment file is ready and stored on device.'
                            : 'The export step was interrupted. Review the message below and try again.',
                    style: const TextStyle(
                      color: Color(0xFFEAF9F4),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            InfoCard(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: _busy
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 48,
                            width: 48,
                            child: CircularProgressIndicator(strokeWidth: 3.2),
                          ),
                          SizedBox(height: 18),
                          Text(
                            'Generating export...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF203233),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please wait while the report is written to local storage.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF5C7376),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 86,
                          width: 86,
                          decoration: BoxDecoration(
                            color: success
                                ? const Color(0xFFE9F8F0)
                                : const Color(0xFFFFF0F2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            success ? Icons.check_rounded : Icons.error_outline,
                            size: 46,
                            color: success
                                ? const Color(0xFF1A8A58)
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          success ? 'Export complete' : 'Export failed',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 28),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: success
                                ? const Color(0xFFF4FBF7)
                                : const Color(0xFFFFF5F6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: success
                                  ? const Color(0xFFD8EEDF)
                                  : const Color(0xFFF2D1D6),
                            ),
                          ),
                          child: Text(
                            _error ?? _outputFile!.path,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF4C6264),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            ),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('Return Home'),
                          ),
                        ),
                        if (success) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ReportsHistoryScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.folder_copy_outlined),
                              label: const Text('View Saved Reports'),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    final patient = context.read<PatientProvider>().patient;
    final processedImage = context.read<ImageWorkflowProvider>().processedImage;
    final maskBytes = context.read<EditingProvider>().maskBytes;
    final tbsa = context.read<EditingProvider>().burnPercentage;
    final reportService = context.read<ReportService>();

    try {
      if (patient == null || processedImage == null || maskBytes == null) {
        throw Exception('Assessment data is incomplete.');
      }

      final processedBytes = await processedImage.readAsBytes();

      final generatedFile = widget.fileType == ReportFileType.pdf
          ? await reportService.generatePdf(
              fileName: widget.fileName,
              patient: patient,
              processedImageBytes: processedBytes,
              maskBytes: maskBytes,
              tbsa: tbsa,
            )
          : await reportService.generateCompositeImage(
              fileName: widget.fileName,
              processedImageBytes: processedBytes,
              maskBytes: maskBytes,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _outputFile = generatedFile;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error.toString();
      });
    }
  }
}
