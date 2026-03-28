import 'dart:math' as math;
import 'package:burn_scan/models/detection_result.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

enum EditingMode { add, erase }

class EditingProvider extends ChangeNotifier {
  img.Image? _maskImage;
  Uint8List? _maskBytes;
  double _brushSize = 28;
  double _sensitivity = 0.55;
  double _burnPercentage = 0;
  EditingMode _mode = EditingMode.add;

  Uint8List? get maskBytes => _maskBytes;
  double get brushSize => _brushSize;
  double get sensitivity => _sensitivity;
  double get burnPercentage => _burnPercentage;
  EditingMode get mode => _mode;
  bool get hasMask => _maskBytes != null;
  int get imageWidth => _maskImage?.width ?? 0;
  int get imageHeight => _maskImage?.height ?? 0;

  void initializeFromDetection(DetectionResult detectionResult) {
    final decoded = img.decodeImage(detectionResult.maskBytes);
    if (decoded == null) {
      throw Exception('Unable to decode detection mask.');
    }

    _maskImage = img.Image.from(decoded);
    _maskBytes = Uint8List.fromList(detectionResult.maskBytes);
    _sensitivity = detectionResult.sensitivity;
    _burnPercentage = _estimateCoverage();
    notifyListeners();
  }

  void setMode(EditingMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setBrushSize(double size) {
    _brushSize = size;
    notifyListeners();
  }

  void setSensitivity(double sensitivity) {
    _sensitivity = sensitivity;
    notifyListeners();
  }

  void applyBrush({
    required double imageX,
    required double imageY,
  }) {
    final mask = _maskImage;
    if (mask == null) {
      return;
    }

    final radius = math.max(1, _brushSize ~/ 2);
    final centerX = imageX.round();
    final centerY = imageY.round();

    for (var y = centerY - radius; y <= centerY + radius; y++) {
      if (y < 0 || y >= mask.height) {
        continue;
      }
      for (var x = centerX - radius; x <= centerX + radius; x++) {
        if (x < 0 || x >= mask.width) {
          continue;
        }

        final dx = x - centerX;
        final dy = y - centerY;
        if ((dx * dx) + (dy * dy) <= radius * radius) {
          if (_mode == EditingMode.erase) {
            mask.setPixelRgba(x, y, 0, 0, 0, 0);
          } else {
            mask.setPixelRgba(x, y, 214, 48, 49, 170);
          }
        }
      }
    }

    _maskBytes = Uint8List.fromList(img.encodePng(mask));
    _burnPercentage = _estimateCoverage();
    notifyListeners();
  }

  double _estimateCoverage() {
    final mask = _maskImage;
    if (mask == null) {
      return 0;
    }

    var active = 0;
    final total = mask.width * mask.height;
    for (var y = 0; y < mask.height; y++) {
      for (var x = 0; x < mask.width; x++) {
        if (mask.getPixel(x, y).a > 0) {
          active++;
        }
      }
    }
    return (active / total) * 100;
  }

  void clear() {
    _maskImage = null;
    _maskBytes = null;
    _burnPercentage = 0;
    _mode = EditingMode.add;
    _brushSize = 28;
    _sensitivity = 0.55;
    notifyListeners();
  }
}
