import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case 'Menunggu':
        return AppColors.warning;
      case 'Siap Dikirim':
        return AppColors.info;
      case 'Dalam Perjalanan':
        return const Color(0xFF818CF8); // Indigo 400
      case 'Sampai Tujuan':
      case 'Lengkap':
        return AppColors.success;
      case 'Gagal Kirim':
      case 'Rusak':
        return AppColors.error;
      case 'Kurang':
        return AppColors.warning;
      default:
        return AppColors.textTertiary;
    }
  }
}
