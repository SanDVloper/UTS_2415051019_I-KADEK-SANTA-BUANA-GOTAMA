import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Reusable Smart Match widget displaying matching percentage
/// and AI ranking based on worker skills, proximity, and accessibility accommodations.
class SmartMatchBadge extends StatelessWidget {
  final int score;
  final String? rank;
  final bool isDetailed;
  final List<String>? breakdownItems;

  const SmartMatchBadge({
    super.key,
    required this.score,
    this.rank,
    this.isDetailed = false,
    this.breakdownItems,
  });

  Color _getScoreColor() {
    if (score >= 85) return AppColors.secondary;
    if (score >= 70) return AppColors.warning;
    return AppColors.textMuted;
  }

  Color _getScoreBgColor() {
    if (score >= 85) return AppColors.secondaryLight;
    if (score >= 70) return AppColors.warningLight;
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    if (!isDetailed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getScoreBgColor(),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 13, color: _getScoreColor()),
            const SizedBox(width: 4),
            Text(
              'Match $score%',
              style: TextStyle(
                color: _getScoreColor(),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final defaultBreakdown = [
      '5/5 Kemampuan Terpenuhi (Mengetik, Membaca, Komunikasi Teks)',
      'Jarak Sangat Dekat: Lokasi berada dalam radius aktif Anda',
      'Kompatibilitas Aksesibilitas: Instruksi 100% via teks mandiri',
    ];

    final items = breakdownItems ?? defaultBreakdown;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getScoreColor(), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor().withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars_rounded, color: _getScoreColor(), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Smart Match Score: $score%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (rank != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getScoreBgColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rank!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: _getScoreColor(),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✓ ', style: TextStyle(color: _getScoreColor(), fontWeight: FontWeight.bold, fontSize: 13)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMain),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
