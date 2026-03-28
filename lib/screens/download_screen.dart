import 'dart:io';

import 'package:burn_scan/models/report_file_type.dart';
import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/providers/patient_provider.dart';
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
    return AppShell(
      title: 'Download Report',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: InfoCard(
          child: Center(
            child: _busy
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _error == null
                            ? Icons.check_circle
                            : Icons.error_outline,
                        size: 64,
                        color: _error == null
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error == null
                            ? 'Report saved successfully'
                            : 'Unable to generate report',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error ?? _outputFile!.path,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          ),
                          child: const Text('Return Home'),
                        ),
                      ),
                    ],
                  ),
          ),
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
