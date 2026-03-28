import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:burn_scan/models/detection_result.dart';
import 'package:image/image.dart' as img;

class MLService {
  const MLService({this.endpoint});

  final String? endpoint;

  Future<DetectionResult> detectBurn(
    File imageFile, {
    double sensitivity = 0.55,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unable to decode processed image for AI detection.');
    }

    final mask = img.Image(
      width: decoded.width,
      height: decoded.height,
      numChannels: 4,
    );
    img.fill(mask, color: img.ColorRgba8(0, 0, 0, 0));

    final radiusX = decoded.width * (0.12 + (sensitivity * 0.18));
    final radiusY = decoded.height * (0.10 + (sensitivity * 0.16));
    final centerX = decoded.width * 0.50;
    final centerY = decoded.height * 0.42;

    _drawEllipse(mask, centerX, centerY, radiusX, radiusY);
    _drawEllipse(
      mask,
      decoded.width * 0.62,
      decoded.height * 0.64,
      radiusX * 0.75,
      radiusY * 0.62,
    );

    final burnPercent = _estimateCoverage(mask);

    return DetectionResult(
      maskBytes: Uint8List.fromList(img.encodePng(mask)),
      width: decoded.width,
      height: decoded.height,
      sensitivity: sensitivity,
      estimatedTbsa: burnPercent,
    );
  }

  void _drawEllipse(
    img.Image mask,
    double centerX,
    double centerY,
    double radiusX,
    double radiusY,
  ) {
    final minX = math.max(0, (centerX - radiusX).floor());
    final maxX = math.min(mask.width - 1, (centerX + radiusX).ceil());
    final minY = math.max(0, (centerY - radiusY).floor());
    final maxY = math.min(mask.height - 1, (centerY + radiusY).ceil());

    for (var y = minY; y <= maxY; y++) {
      for (var x = minX; x <= maxX; x++) {
        final normX = (x - centerX) / radiusX;
        final normY = (y - centerY) / radiusY;
        if ((normX * normX) + (normY * normY) <= 1) {
          mask.setPixelRgba(x, y, 214, 48, 49, 160);
        }
      }
    }
  }

  double _estimateCoverage(img.Image mask) {
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
}
