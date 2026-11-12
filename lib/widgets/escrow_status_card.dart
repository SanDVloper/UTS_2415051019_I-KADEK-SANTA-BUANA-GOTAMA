import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Reusable Escrow security banner widget highlighting guaranteed wage
/// locking and transparent worker fund protection.
class EscrowStatusCard extends StatelessWidget {
  final String amount;
  final String status;
  final String? subtitle;
  final bool isDetailed;

  const EscrowStatusCard({
    super.key,
    required this.amount,
    this.status = 'Locked',
    this.subtitle,
    this.isDetailed = false,
  });

  String get _statusLabel {
    switch (status.toLowerCase()) {
      case 'locked':
        return '🔒 Upah Terkunci di Sistem';
      case 'processing':
        return '⏳ Proses Verifikasi';
      case 'released':
        return '✅ Upah Berhasil Dicairkan';
      default:
        return '🔒 Sistem Escrow Aktif';
    }
  }

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'locked':
      case 'released':
        return AppColors.secondary;
      case 'processing':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color get _statusBgColor {
    switch (status.toLowerCase()) {
      case 'locked':
      case 'released':
        return AppColors.secondaryLight;
      case 'processing':
        return AppColors.warningLight;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isDetailed) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _statusBgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 18, color: _statusColor),
                const SizedBox(width: 8),
                Text(
                  'Dana Escrow: $amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status == 'Locked' ? 'Aman Terjamin ✓' : status,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle ?? 'Nominal Upah Terproteksi',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.check_circle_outline, size: 14, color: AppColors.secondary),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pemberi kerja telah mendepositkan upah penuh ke rekening Escrow KaryaSetara sebelum penugasan dimulai.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMain, height: 1.3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
