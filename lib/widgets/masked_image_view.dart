import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class MaskedImageView extends StatelessWidget {
  const MaskedImageView({
    super.key,
    required this.imageFile,
    this.maskBytes,
    this.height = 320,
  });

  final File imageFile;
  final Uint8List? maskBytes;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.black12,
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.contain),
            if (maskBytes != null)
              Image.memory(maskBytes!, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
