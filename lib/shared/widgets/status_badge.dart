import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Color _getBgColor() {
    switch (status) {
      case 'Menunggu':
        return AppColors.warningBg;
      case 'Siap Dikirim':
        return AppColors.infoBg;
      case 'Dalam Perjalanan':
        return const Color(0xFFE0E7FF); // Indigo 100
      case 'Sampai Tujuan':
      case 'Lengkap':
        return AppColors.successBg;
      case 'Gagal Kirim':
      case 'Rusak':
        return AppColors.errorBg;
      case 'Kurang':
        return AppColors.warningBg;
      default:
        return AppColors.surfaceVariant;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case 'Menunggu':
        return const Color(0xFFD97706);
      case 'Siap Dikirim':
        return const Color(0xFF2563EB);
      case 'Dalam Perjalanan':
        return const Color(0xFF4338CA); // Indigo 700
      case 'Sampai Tujuan':
      case 'Lengkap':
        return const Color(0xFF059669);
      case 'Gagal Kirim':
      case 'Rusak':
        return const Color(0xFFDC2626);
      case 'Kurang':
        return const Color(0xFFD97706);
      default:
        return AppColors.textSecondary;
    }
  }
}
