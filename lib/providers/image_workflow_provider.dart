import 'dart:io';

import 'package:burn_scan/models/detection_result.dart';
import 'package:burn_scan/services/image_service.dart';
import 'package:burn_scan/services/ml_service.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImageWorkflowProvider extends ChangeNotifier {
  ImageWorkflowProvider(
    this._picker,
    this._imageService,
    this._mlService,
  );

  final ImagePicker _picker;
  final ImageService _imageService;
  final MLService _mlService;

  File? _selectedImage;
  File? _processedImage;
  DetectionResult? _detectionResult;
  bool _isBusy = false;
  String? _error;

  File? get selectedImage => _selectedImage;
  File? get processedImage => _processedImage;
  DetectionResult? get detectionResult => _detectionResult;
  bool get isBusy => _isBusy;
  String? get error => _error;

  Future<bool> pickImage(ImageSource source) async {
    try {
      _isBusy = true;
      _error = null;
      notifyListeners();

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );
      if (pickedFile == null) {
        return false;
      }

      _selectedImage = File(pickedFile.path);
      _processedImage = null;
      _detectionResult = null;
      return true;
    } catch (_) {
      _error = 'Unable to access image source.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<File?> processCurrentImage() async {
    if (_selectedImage == null) {
      _error = 'Select an image before processing.';
      notifyListeners();
      return null;
    }

    try {
      _isBusy = true;
      _error = null;
      notifyListeners();
      _processedImage = await _imageService.processImage(_selectedImage!);
      _detectionResult = null;
      return _processedImage;
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<DetectionResult?> detectBurn({double sensitivity = 0.55}) async {
    if (_processedImage == null) {
      _error = 'Process the image before AI detection.';
      notifyListeners();
      return null;
    }

    try {
      _isBusy = true;
      _error = null;
      notifyListeners();
      _detectionResult = await _mlService.detectBurn(
        _processedImage!,
        sensitivity: sensitivity,
      );
      return _detectionResult;
    } catch (error) {
      _error = error.toString();
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void reset() {
    _selectedImage = null;
    _processedImage = null;
    _detectionResult = null;
    _error = null;
    _isBusy = false;
    notifyListeners();
  }
}
