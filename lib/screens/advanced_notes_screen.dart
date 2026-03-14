
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../models/module_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/pdf_export_service.dart';
import '../widgets/animated_google_background.dart';

class AdvancedNotesScreen extends StatefulWidget {
  const AdvancedNotesScreen({super.key});

  @override
  State<AdvancedNotesScreen> createState() => _AdvancedNotesScreenState();
}

class _AdvancedNotesScreenState extends State<AdvancedNotesScreen> {
  bool _isExporting = false;

  Future<void> _exportPdf(BuildContext context, Map<String, String> notes) async {
    final soundService = context.read<SoundService>();
    soundService.playTap();

    setState(() => _isExporting = true);

    try {
      final path = await PdfExportService.generateNotesPdf(notes);
      
      setState(() => _isExporting = false);
      soundService.playSuccess();

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.cardC(context.read<ThemeService>().isDarkMode),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('📄 PDF Ready!'),
            content: const Text('Your notes have been compiled into a professional document.\n\nSave or share it now.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                   Navigator.pop(ctx);
                   Share.shareXFiles([XFile(path)], text: 'My AR Explorer Notes');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Share / Save'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();
    final progress = context.watch<ProgressService>();
    final allNotes = progress.allNotes;

    // Filter to only notes that have content
    final activeNotes = allNotes.entries.where((e) => e.value.trim().isNotEmpty).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, isDark, soundService, allNotes),
                  Expanded(
                    child: activeNotes.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildNotesList(isDark, activeNotes, progress),
                  ),
                ],
              ),
            ),
            if (_isExporting)
               Positioned.fill(
                  child: Container(
                     color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                     child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentPink),
                     ),
                  ),
               )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, SoundService soundService, Map<String, String> notes) {
    final hasNotes = notes.values.any((n) => n.trim().isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              soundService.playTap();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.glassCard(isDark),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimaryC(isDark),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Notes',
                  style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
                ),
                Text(
                  'Compile & Export',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.accentPink),
                ),
              ],
            ),
          ),
          if (hasNotes)
            GestureDetector(
               onTap: () => _exportPdf(context, notes),
               child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPink.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: Row(
                     children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('EXPORT', style: AppTheme.buttonText.copyWith(color: Colors.white, fontSize: 12)),
                     ],
                  ),
               ),
            ).animate().shimmer(duration: const Duration(seconds: 3), color: Colors.white60),
        ],
      ),
    );
  }

  Widget _buildNotesList(bool isDark, List<MapEntry<String, String>> activeNotes, ProgressService progress) {
     // Group them by Module for display
     Map<LearningModule, List<MapEntry<String, String>>> grouped = {};
     for (var entry in activeNotes) {
        final moduleId = entry.key.split('_')[0];
        final module = allModules.firstWhere((m) => m.id == moduleId);
        if (!grouped.containsKey(module)) grouped[module] = [];
        grouped[module]!.add(entry);
     }

     return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: grouped.length,
        itemBuilder: (context, index) {
           final module = grouped.keys.elementAt(index);
           final notes = grouped[module]!;

           return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Row(
                       children: [
                          Icon(module.icon, color: AppTheme.getModuleColor(allModules.indexOf(module)), size: 18),
                          const SizedBox(width: 8),
                          Text(
                             module.title,
                             style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
                          ),
                       ],
                    ),
                    const SizedBox(height: 12),
                    ...notes.map((entry) {
                       final topicId = entry.key.split('_')[1];
                       final topic = module.topics.firstWhere((t) => t.id == topicId);

                       return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassCard(isDark),
                          child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                                Text(
                                   topic.title,
                                   style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark), fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                   entry.value,
                                   style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
                                )
                             ],
                          ),
                       );
                    }),
                 ],
              ),
           );
        },
     );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_document, size: 64, color: AppTheme.textMutedC(isDark).withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            Text(
              'No Notes Yet',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
            ),
            const SizedBox(height: 12),
            Text(
              'Take notes during the modules. They will appear here where you can export them as a professional PDF.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark)),
            ),
          ],
        ),
      ),
    );
  }
}
