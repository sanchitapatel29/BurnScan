import 'package:burn_scan/models/patient.dart';
import 'package:burn_scan/providers/patient_provider.dart';
import 'package:burn_scan/screens/image_upload_screen.dart';
import 'package:burn_scan/widgets/app_shell.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Patient Details',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record patient details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'These values remain in memory for the current assessment only.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _idController,
                      decoration:
                          const InputDecoration(labelText: 'Patient ID'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid age.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration:
                          const InputDecoration(labelText: 'Weight (kg)'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid weight.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continueToUpload,
                  child: const Text('Continue to Image Upload'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  void _continueToUpload() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<PatientProvider>().savePatient(
          Patient(
            patientId: _idController.text.trim(),
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            weight: double.parse(_weightController.text.trim()),
          ),
        );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ImageUploadScreen(),
      ),
    );
  }
}
