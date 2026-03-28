import 'package:burn_scan/models/patient.dart';
import 'package:flutter/foundation.dart';

class PatientProvider extends ChangeNotifier {
  Patient? _patient;

  Patient? get patient => _patient;

  void savePatient(Patient patient) {
    _patient = patient;
    notifyListeners();
  }

  void clear() {
    _patient = null;
    notifyListeners();
  }
}
