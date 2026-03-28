import 'dart:typed_data';

class DetectionResult {
  const DetectionResult({
    required this.maskBytes,
    required this.width,
    required this.height,
    required this.sensitivity,
    required this.estimatedTbsa,
  });

  final Uint8List maskBytes;
  final int width;
  final int height;
  final double sensitivity;
  final double estimatedTbsa;
}
