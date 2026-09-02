import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class CustomSnackbar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final color = isError ? AppColors.error : AppColors.success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface.withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
        ),
        elevation: 8,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'TUTUP',
          textColor: AppColors.textTertiary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
