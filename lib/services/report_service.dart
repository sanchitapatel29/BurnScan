import 'dart:io';
import 'dart:typed_data';

import 'package:burn_scan/models/patient.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportService {
  Future<File> generatePdf({
    required String fileName,
    required Patient patient,
    required Uint8List processedImageBytes,
    required Uint8List maskBytes,
    required double tbsa,
  }) async {
    final pdf = pw.Document();
    final composedImage = await generateCompositeImage(
      fileName: fileName,
      processedImageBytes: processedImageBytes,
      maskBytes: maskBytes,
    );
    final composedImageBytes = await composedImage.readAsBytes();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Burn Assessment Report'),
          ),
          pw.Text(
            'Generated: ${DateFormat.yMMMd().add_jm().format(DateTime.now())}',
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              _row('Patient ID', patient.patientId),
              _row('Name', patient.name),
              _row('Age', '${patient.age} years'),
              _row('Weight', '${patient.weight.toStringAsFixed(1)} kg'),
              _row('Estimated TBSA', '${tbsa.toStringAsFixed(2)}%'),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Annotated Burn Map',
            style: const pw.TextStyle(fontSize: 16),
          ),
          pw.SizedBox(height: 12),
          pw.Image(
            pw.MemoryImage(composedImageBytes),
            fit: pw.BoxFit.contain,
            height: 320,
          ),
        ],
      ),
    );

    final directory = await getReportsDirectory();
    final output = File('${directory.path}/$fileName.pdf');
    await output.writeAsBytes(await pdf.save(), flush: true);
    return output;
  }

  Future<File> generateCompositeImage({
    required String fileName,
    required Uint8List processedImageBytes,
    required Uint8List maskBytes,
  }) async {
    final base = img.decodeImage(processedImageBytes);
    final mask = img.decodeImage(maskBytes);

    if (base == null || mask == null) {
      throw Exception('Unable to decode images for report generation.');
    }

    final resizedMask = mask.width == base.width && mask.height == base.height
        ? mask
        : img.copyResize(mask, width: base.width, height: base.height);

    final composed = img.Image.from(base);
    img.compositeImage(composed, resizedMask, blend: img.BlendMode.alpha);

    final directory = await getReportsDirectory();
    final output = File('${directory.path}/$fileName.png');
    await output.writeAsBytes(img.encodePng(composed), flush: true);
    return output;
  }

  Future<Directory> getReportsDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final reportsDirectory = Directory(
      p.join(documentsDirectory.path, 'reports'),
    );
    if (!await reportsDirectory.exists()) {
      await reportsDirectory.create(recursive: true);
    }
    return reportsDirectory;
  }

  Future<List<File>> listSavedPdfReports() async {
    final directories = <Directory>[
      await getReportsDirectory(),
      await getApplicationDocumentsDirectory(),
    ];
    final seenPaths = <String>{};
    final reports = <File>[];

    for (final directory in directories) {
      if (!await directory.exists()) {
        continue;
      }

      await for (final entity in directory.list()) {
        if (entity is! File) {
          continue;
        }
        if (p.extension(entity.path).toLowerCase() != '.pdf') {
          continue;
        }
        if (seenPaths.add(entity.path)) {
          reports.add(entity);
        }
      }
    }

    reports.sort(
      (first, second) => second
          .statSync()
          .modified
          .compareTo(first.statSync().modified),
    );
    return reports;
  }

  Future<void> deleteReport(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  pw.TableRow _row(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }
}
