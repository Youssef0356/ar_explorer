import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_theme.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    final soundService = context.read<SoundService>();
    soundService.playTap();
    
    setState(() => _isSaving = true);

    try {
      final Uint8List? imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        await Gal.putImageBytes(imageBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Certificate saved to gallery!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save certificate: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = context.watch<ProgressService>().username;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Explorer Certificate'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: AspectRatio(
                aspectRatio: 1.765, // Match images 1024x580 ratio
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight;
                    return Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/Certificate.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        // Username Positioned
                        // Centered horizontally, about 44% from top
                        Positioned(
                          top: h * 0.41, 
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              username.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: h * 0.08, // Dynamic font size
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentCyan, // Matching the cyan theme
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.accentCyan.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Date Positioned
                        // Centered horizontally, about 72% from top
                        Positioned(
                          top: h * 0.69,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              _getFormattedDate(),
                              style: GoogleFonts.inter(
                                fontSize: h * 0.035, // Dynamic font size
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentCyan.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveToGallery,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Save to Gallery'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Show off your achievement! Save this certificate to your gallery and share it with the world.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }
}
