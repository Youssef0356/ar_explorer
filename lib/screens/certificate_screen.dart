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
                aspectRatio: 1.414, // Match A4 landscape ratio
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final h = constraints.maxHeight;
                    final w = constraints.maxWidth;
                    return Stack(
                      children: [
                        // 1. Dark Blue Gradient Background
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0A0E21), // Prime Dark
                                  Color(0xFF0F1B40), // Dark Blue
                                  Color(0xFF050814), // Deep Dark
                                ],
                              ),
                              border: Border.all(
                                color: AppTheme.accentCyan.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        
                        // 2. Decorative Shapes (Corners & Background)
                        Positioned(
                          top: -h * 0.3,
                          left: -w * 0.15,
                          child: Container(
                            width: w * 0.6,
                            height: w * 0.6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.accentCyan.withOpacity(0.15),
                                  const Color(0x00000000),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -h * 0.4,
                          right: -w * 0.2,
                          child: Container(
                            width: w * 0.8,
                            height: w * 0.8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.accentBlue.withOpacity(0.12),
                                  const Color(0x00000000),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Inner Border Line
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.accentCyan.withOpacity(0.15),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        

                        // 3. Main Titles & Logo
                        Positioned(
                          top: h * 0.06,
                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CERTIFICATE',
                                style: GoogleFonts.outfit(
                                  fontSize: h * 0.1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'OF ACHIEVEMENT',
                                style: GoogleFonts.outfit(
                                  fontSize: h * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentCyan,
                                  letterSpacing: 4,
                                ),
                              ),
                              SizedBox(height: h * 0.02),
                              Image.asset(
                                'assets/images/app_logoTransparent.png',
                                height: h * 0.24,
                                opacity: const AlwaysStoppedAnimation(0.9),
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        // 4. Present to Phrase
                        Positioned(
                          top: h * 0.48,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'THIS IS TO CERTIFY THAT',
                              style: GoogleFonts.inter(
                                fontSize: h * 0.022,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),

                        // 5. Username Positioned
                        Positioned(
                          top: h * 0.56, 
                          left: w * 0.1,
                          right: w * 0.1,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                username.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: h * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentCyan,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: AppTheme.accentCyan.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 6. Completion Text
                        Positioned(
                          top: h * 0.72,
                          left: w * 0.15,
                          right: w * 0.15,
                          child: Center(
                            child: Text(
                              'HAS SUCCESSFULLY COMPLETED THE AR EXPLORER JOURNEY',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: h * 0.018,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // 8. Date and Signature
                        Positioned(
                          bottom: h * 0.08,
                          left: w * 0.15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _getFormattedDate(),
                                style: GoogleFonts.inter(
                                  fontSize: h * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: h * 0.01),
                              Container(
                                width: w * 0.2,
                                height: 1,
                                color: AppTheme.accentCyan.withOpacity(0.5),
                              ),
                              SizedBox(height: h * 0.01),
                              Text(
                                'DATE',
                                style: GoogleFonts.inter(
                                  fontSize: h * 0.016,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        Positioned(
                          bottom: h * 0.065, // slightly lower to gracefully fit cursive font
                          right: w * 0.15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '356 Company',
                                style: GoogleFonts.dancingScript(
                                  fontSize: h * 0.055,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentCyan,
                                ),
                              ),
                              SizedBox(height: h * 0.01),
                              Container(
                                width: w * 0.25,
                                height: 1,
                                color: AppTheme.accentCyan.withOpacity(0.5),
                              ),
                              SizedBox(height: h * 0.01),
                              Text(
                                'AUTHORIZED SIGNATURE',
                                style: GoogleFonts.inter(
                                  fontSize: h * 0.016,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.5),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
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
