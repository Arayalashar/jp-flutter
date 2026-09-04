import 'package:flutter/material.dart';

class LightTheme {
  static const Color background = Color(0xFFF9FAFB); // Off-white canvas
  static const Color surface = Color(0xFFFFFFFF);    // Pure white cards
  static const Color primary = Color(0xFFFF7A00);    // Vibrant Orange
  static const Color textPrimary = Color(0xFF111827); // Soft black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);     // Hairline border
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  
  static BoxDecoration cardDecoration({double radius = 24}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
