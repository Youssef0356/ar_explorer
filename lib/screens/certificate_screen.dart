import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentCyan.withValues(alpha: 0.5),
                    width: 8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Corner Decorations
                    const _CertificateCorners(),
                    
                    const SizedBox(height: 20),
                    const Icon(Icons.verified_rounded, size: 80, color: AppTheme.accentCyan),
                    const SizedBox(height: 24),
                    Text(
                      'CERTIFICATE OF COMPLETION',
                      style: AppTheme.headingLarge.copyWith(
                        letterSpacing: 2,
                        color: AppTheme.accentCyan,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This certifies that',
                      style: AppTheme.bodyLarge.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textSecondaryC(isDark),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      username,
                      style: AppTheme.headingLarge.copyWith(
                        fontSize: 42,
                        color: AppTheme.textPrimaryC(isDark),
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.accentCyan.withValues(alpha: 0.3),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'has successfully completed the comprehensive curriculum of',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryC(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AR EXPLORER',
                      style: AppTheme.headingMedium.copyWith(
                        letterSpacing: 1.5,
                        color: AppTheme.accentCyan,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mastering core definitions, coordinate systems, SLAM, hardware paradigms, and industrial AR applications.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMutedC(isDark),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Signature(label: 'Date', value: _getFormattedDate()),
                        _Signature(label: 'Authorized by', value: 'AR Explorer Academy'),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
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

class _CertificateCorners extends StatelessWidget {
  const _CertificateCorners();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _corner(0),
          _corner(1.57),
        ],
      ),
    );
  }

  Widget _corner(double angle) {
    return Transform.rotate(
      angle: angle,
      child: const Icon(Icons.architecture_rounded, size: 24, color: AppTheme.accentCyan),
    );
  }
}

class _Signature extends StatelessWidget {
  final String label;
  final String value;

  const _Signature({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryC(isDark),
          ),
        ),
        Container(
          width: 120,
          height: 1,
          color: AppTheme.textMutedC(isDark),
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
        ),
      ],
    );
  }
}
