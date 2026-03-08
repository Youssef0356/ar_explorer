// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import 'achievement_badge.dart';

class ShareableAchievementCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String score;
  final bool isDark;

  const ShareableAchievementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.score,
    required this.isDark,
  });

  @override
  State<ShareableAchievementCard> createState() =>
      _ShareableAchievementCardState();
}

class _ShareableAchievementCardState extends State<ShareableAchievementCard> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareScreenshot() async {
    setState(() => _isSharing = true);
    try {
      // 1. Capture widget as image
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // 2. Save image to temp directory
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/ar_explorer_achievement_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      // 3. Share the image
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'I just leveled up in AR Explorer! Check out my progress. 🚀',
      );
    } catch (e) {
      debugPrint('Error sharing achievement: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share achievement.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The actual card we capture
        RepaintBoundary(
          key: _globalKey,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: widget.isDark ? 0.2 : 0.1),
                  AppTheme.cardC(widget.isDark),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.color.withValues(alpha: widget.isDark ? 0.3 : 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AR Explorer',
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.textMutedC(widget.isDark),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                Transform.scale(
                  scale: 1.5,
                  child: AchievementBadge(
                    icon: widget.icon,
                    label: '',
                    color: widget.color,
                    earned: true,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  widget.title,
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimaryC(widget.isDark),
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.subtitle,
                  style: AppTheme.bodyMedium.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.score.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: ${widget.score}',
                      style: AppTheme.headingSmall.copyWith(
                        color: widget.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // The share button outside the captured area
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSharing ? null : _shareScreenshot,
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share_rounded, size: 20),
            label: Text(_isSharing ? 'Preparing...' : 'Share Achievement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: AppTheme.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
