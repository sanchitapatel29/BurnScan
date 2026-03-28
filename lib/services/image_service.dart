import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<File> processImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Unable to decode image.');
    }

    final processed = img.copyResize(decoded, width: 1024);
    img.adjustColor(
      processed,
      contrast: 1.18,
      saturation: 1.08,
      gamma: 0.95,
    );

    final centerX = processed.width / 2;
    final centerY = processed.height / 2;
    final maxDistance = centerX * centerX + centerY * centerY;

    for (var y = 0; y < processed.height; y++) {
      for (var x = 0; x < processed.width; x++) {
        final pixel = processed.getPixel(x, y);
        final dx = x - centerX;
        final dy = y - centerY;
        final normalizedDistance =
            ((dx * dx + dy * dy) / maxDistance).clamp(0.0, 1.0);
        final lift = (20 * normalizedDistance).round();

        processed.setPixelRgba(
          x,
          y,
          (pixel.r + lift).clamp(0, 255),
          (pixel.g + lift).clamp(0, 255),
          (pixel.b + lift).clamp(0, 255),
          pixel.a,
        );
      }
    }

    final output = Uint8List.fromList(img.encodeJpg(processed, quality: 92));
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(output, flush: true);
    return file;
  }
}
