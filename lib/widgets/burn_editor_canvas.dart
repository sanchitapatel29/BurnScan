import 'dart:io';

import 'package:burn_scan/providers/editing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BurnEditorCanvas extends StatelessWidget {
  const BurnEditorCanvas({
    super.key,
    required this.imageFile,
  });

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<EditingProvider>(
          builder: (context, editingProvider, child) {
            return GestureDetector(
              onPanDown: (details) => _handlePaint(
                details.localPosition,
                constraints.biggest,
                editingProvider,
              ),
              onPanUpdate: (details) => _handlePaint(
                details.localPosition,
                constraints.biggest,
                editingProvider,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.black12,
                  width: double.infinity,
                  height: 360,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(imageFile, fit: BoxFit.contain),
                      if (editingProvider.maskBytes != null)
                        Image.memory(
                          editingProvider.maskBytes!,
                          fit: BoxFit.contain,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handlePaint(
    Offset localPosition,
    Size boxSize,
    EditingProvider editingProvider,
  ) {
    final imageWidth = editingProvider.imageWidth;
    final imageHeight = editingProvider.imageHeight;
    if (imageWidth == 0 || imageHeight == 0) {
      return;
    }

    final imageAspect = imageWidth / imageHeight;
    final boxAspect = boxSize.width / boxSize.height;

    double renderedWidth;
    double renderedHeight;
    double offsetX = 0;
    double offsetY = 0;

    if (imageAspect > boxAspect) {
      renderedWidth = boxSize.width;
      renderedHeight = renderedWidth / imageAspect;
      offsetY = (boxSize.height - renderedHeight) / 2;
    } else {
      renderedHeight = boxSize.height;
      renderedWidth = renderedHeight * imageAspect;
      offsetX = (boxSize.width - renderedWidth) / 2;
    }

    final dx = localPosition.dx - offsetX;
    final dy = localPosition.dy - offsetY;
    if (dx < 0 || dy < 0 || dx > renderedWidth || dy > renderedHeight) {
      return;
    }

    final imageX = (dx / renderedWidth) * imageWidth;
    final imageY = (dy / renderedHeight) * imageHeight;
    editingProvider.applyBrush(imageX: imageX, imageY: imageY);
  }
}