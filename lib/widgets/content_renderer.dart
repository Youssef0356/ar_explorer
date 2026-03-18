import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/topic_model.dart';
import '../services/theme_service.dart';

class ContentRenderer extends StatelessWidget {
  final List<ContentBlock> blocks;

  const ContentRenderer({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.asMap().entries.map((entry) {
        final i = entry.key;
        final block = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildBlock(block, isDark, i),
        );
      }).toList(),
    );
  }

  Widget _buildBlock(ContentBlock block, bool isDark, int index) {
    switch (block.type) {
      case ContentBlockType.heading:
        return Row(
          children: [
            Container(
              width: 4,
              height: 22,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Text(
                block.content,
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.textPrimaryC(isDark),
                ),
              ),
            ),
          ],
        );
      case ContentBlockType.subheading:
        return Text(
          block.content,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.accentBlue,
          ),
        );
      case ContentBlockType.body:
        return Text(
          block.content,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryC(isDark),
            height: 1.65,
          ),
        );
      case ContentBlockType.bullet:
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  block.content,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryC(isDark),
                  ),
                ),
              ),
            ],
          ),
        );
      case ContentBlockType.numbered:
        // Robust extraction of number at the start of string (e.g. "1. ", "12. ", "1)")
        final numberRegex = RegExp(r'^(\d+)[.\)]\s*');
        final match = numberRegex.firstMatch(block.content);
        
        String number;
        String content;
        
        if (match != null) {
          number = match.group(1) ?? '';
          content = block.content.substring(match.end);
        } else {
          // Fallback if no number found at start
          number = '?'; 
          content = block.content;
        }

        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withOpacity(
                    isDark ? 0.15 : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryC(isDark),
                  ),
                ),
              ),
            ],
          ),
        );
      case ContentBlockType.code:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: Text(
            block.content,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: isDark ? AppTheme.accentCyan : const Color(0xFF0366D6),
              height: 1.5,
            ),
          ),
        );
      case ContentBlockType.infoBox:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withOpacity(isDark ? 0.08 : 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.accentCyan.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.accentCyan,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  block.content,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCyan,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      case ContentBlockType.warningBox:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.warningAmber.withOpacity(
              isDark ? 0.08 : 0.06,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppTheme.warningAmber.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningAmber,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  block.content,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.warningAmber,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      case ContentBlockType.quote:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: AppTheme.accentBlue.withOpacity(0.6),
                width: 4,
              ),
            ),
            color: AppTheme.accentBlue.withOpacity(isDark ? 0.05 : 0.03),
          ),
          child: Text(
            block.content,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontStyle: FontStyle.italic,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        );
      case ContentBlockType.divider:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: AppTheme.dividerC(isDark)),
        );
      case ContentBlockType.image:
        return _buildImage(block.content, isDark);
    }
  }

  Widget _buildImage(String path, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: AppTheme.cardC(isDark),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Image not found', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
