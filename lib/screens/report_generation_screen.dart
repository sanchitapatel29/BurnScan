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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF39442D), Color(0xFF5C8B3D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x223A4E22),
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
                      'Step 6 of 6',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Generate assessment report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review patient details, confirm the annotated image, and choose how the report should be exported locally.',
                    style: TextStyle(
                      color: Color(0xFFF0F7E8),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (patient != null)
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
                            color: const Color(0xFFF0F7E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF5C8B3D),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report preview',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 26),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Validate the summary before writing the export file.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FCF4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE0EBCD)),
                      ),
                      child: Column(
                        children: [
                          _previewRow('Patient ID', patient.patientId),
                          _previewRow('Name', patient.name),
                          _previewRow('Age', '${patient.age}'),
                          _previewRow(
                            'Weight',
                            '${patient.weight.toStringAsFixed(1)} kg',
                          ),
                          _previewRow(
                            'Estimated TBSA',
                            '${editing.burnPercentage.toStringAsFixed(2)}%',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (workflow.processedImage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FCF4),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE0EBCD)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(4, 0, 4, 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 18,
                                    color: Color(0xFF5C8B3D),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Annotated wound image',
                                    style: TextStyle(
                                      color: Color(0xFF34452B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MaskedImageView(
                              imageFile: workflow.processedImage!,
                              maskBytes: editing.maskBytes,
                              height: 300,
                            ),
                          ],
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
                  const Text(
                    'Export settings',
                    style: TextStyle(
                      color: Color(0xFF243321),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fileNameController,
                    decoration: const InputDecoration(
                      labelText: 'Output file name',
                      hintText: 'Enter report file name',
                      prefixIcon: Icon(
                        Icons.drive_file_rename_outline,
                        color: Color(0xFF5C8B3D),
                      ),
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
                      prefixIcon: Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Color(0xFF5C8B3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
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
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Generate and Download'),
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

  Widget _previewRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF66765B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  emphasize ? const Color(0xFF3B5A24) : const Color(0xFF243321),
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
