import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../data/modules_data.dart';
import '../models/module_model.dart';

class PdfExportService {
  /// Generates a PDF document from the user's notes and returns the file path.
  static Future<String> generateNotesPdf(Map<String, String> notes) async {
    final pdf = pw.Document();

    // Group notes by Module -> Topic
    final Map<LearningModule, List<_TopicNote>> groupedNotes = {};
    for (final module in allModules) {
      for (final topic in module.topics) {
        final key = '${module.id}_${topic.id}';
        if (notes.containsKey(key) && notes[key]!.trim().isNotEmpty) {
          if (!groupedNotes.containsKey(module)) {
            groupedNotes[module] = [];
          }
          groupedNotes[module]!.add(_TopicNote(topic.title, notes[key]!));
        }
      }
    }

    // Load fonts for PDF
    final fontTitle = await PdfGoogleFonts.poppinsSemiBold();
    final fontBody = await PdfGoogleFonts.interRegular();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final List<pw.Widget> items = [];

          // Header
          items.add(
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                   pw.Text('AR Explorer Notes', style: pw.TextStyle(font: fontTitle, fontSize: 28, color: PdfColors.teal)),
                   pw.Text('Exported via Premium', style: pw.TextStyle(font: fontBody, fontSize: 12, color: PdfColors.grey)),
                ]
              )
            )
          );
          
          items.add(pw.SizedBox(height: 16));

          if (groupedNotes.isEmpty) {
             items.add(pw.Text('No notes saved yet.', style: pw.TextStyle(font: fontBody, fontSize: 16)));
             return items;
          }

          // Content
          for (final entry in groupedNotes.entries) {
            final module = entry.key;
            final topicNotes = entry.value;

            // Module Title
            items.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 24, bottom: 8),
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF3F4F6),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  module.title.toUpperCase(),
                  style: pw.TextStyle(font: fontTitle, fontSize: 18, color: PdfColors.blueGrey800),
                ),
              ),
            );

            // Topics within module
            for (final tn in topicNotes) {
              items.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, top: 8, bottom: 4),
                  child: pw.Text(
                    tn.topicTitle,
                    style: pw.TextStyle(font: fontTitle, fontSize: 14, color: PdfColors.blueGrey700),
                  ),
                ),
              );

              items.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, bottom: 12),
                  child: pw.Text(
                    tn.content,
                    style: pw.TextStyle(font: fontBody, fontSize: 11, lineSpacing: 1.5, color: PdfColors.grey900),
                  ),
                ),
              );
            }
          }

          return items;
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(font: fontBody, fontSize: 10, color: PdfColors.grey500),
            ),
          );
        },
      ),
    );

    // Save to local device temp directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/ar_explorer_notes_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}

class _TopicNote {
  final String topicTitle;
  final String content;

  _TopicNote(this.topicTitle, this.content);
}
