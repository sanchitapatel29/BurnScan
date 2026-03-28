import 'package:burn_scan/models/report_file_type.dart';
import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/providers/patient_provider.dart';
import 'package:burn_scan/screens/download_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:burn_scan/widgets/masked_image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportGenerationScreen extends StatefulWidget {
  const ReportGenerationScreen({super.key});

  @override
  State<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends State<ReportGenerationScreen> {
  final _fileNameController = TextEditingController(
    text: 'burn_assessment_report',
  );
  ReportFileType _selectedType = ReportFileType.pdf;

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = context.watch<PatientProvider>().patient;
    final workflow = context.watch<ImageWorkflowProvider>();
    final editing = context.watch<EditingProvider>();

    return AppShell(
      title: 'Report Generation',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (patient != null)
              InfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Patient ID: ${patient.patientId}'),
                    Text('Name: ${patient.name}'),
                    Text('Age: ${patient.age}'),
                    Text('Weight: ${patient.weight.toStringAsFixed(1)} kg'),
                    Text(
                      'Estimated TBSA: ${editing.burnPercentage.toStringAsFixed(2)}%',
                    ),
                    const SizedBox(height: 20),
                    if (workflow.processedImage != null)
                      MaskedImageView(
                        imageFile: workflow.processedImage!,
                        maskBytes: editing.maskBytes,
                        height: 300,
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            InfoCard(
              child: Column(
                children: [
                  TextFormField(
                    controller: _fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'Output file name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ReportFileType>(
                    value: _selectedType,
                    items: ReportFileType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'File type',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: patient == null ||
                              workflow.processedImage == null ||
                              editing.maskBytes == null ||
                              _fileNameController.text.trim().isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => DownloadScreen(
                                    fileName: _fileNameController.text.trim(),
                                    fileType: _selectedType,
                                  ),
                                ),
                              );
                            },
                      child: const Text('Generate and Download'),
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