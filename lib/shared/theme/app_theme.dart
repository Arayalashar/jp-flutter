import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// ============================================================
// COLOR SYSTEM — Dark Glassmorphism
// ============================================================
class AppColors {
  // Background Layers
  static const Color backgroundDark = Color(0xFF0A0F1E);    // Deepest
  static const Color background = Color(0xFF0D1320);         // Primary bg
  static const Color backgroundLight = Color(0xFF111827);    // Slightly lighter

  // Surface / Cards
  static const Color surface = Color(0xFF1A1F2E);            // Card base
  static const Color surfaceLight = Color(0xFF222838);       // Elevated card
  static const Color surfaceVariant = Color(0xFF2A3040);     // Subtle bg

  // Accent — Neon Lime Green (matching reference)
  static const Color primary = Color(0xFFB8FF57);            // Main accent
  static const Color primaryDark = Color(0xFF8CD43C);        // Darker accent
  static const Color primaryDeep = Color(0xFF5FA321);        // Deepest
  static const Color primaryLight = Color(0xFFD4FF8A);       // Lighter
  static const Color primarySurface = Color(0x1AB8FF57);     // 10% opacity
  static const Color primaryMuted = Color(0x33B8FF57);       // 20% opacity

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);        // White-ish
  static const Color textSecondary = Color(0xFF94A3B8);      // Muted
  static const Color textTertiary = Color(0xFF64748B);       // Dimmed
  static const Color textOnPrimary = Color(0xFF0A0F1E);      // On green bg

  // Border
  static const Color border = Color(0xFF2A3040);             // Default
  static const Color borderLight = Color(0xFF1E2535);        // Subtle
  static const Color borderGlow = Color(0x40B8FF57);         // Green glow

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0x1A22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningBg = Color(0x1AFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0x1AEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0x1A3B82F6);

  // Overlay
  static const Color overlay = Color(0xCC0A0F1E);            // 80% dark overlay
}

// ============================================================
// GRADIENT SYSTEM
// ============================================================
class AppGradients {
  // Background gradient — main dark base
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0F1E),
      Color(0xFF0D1320),
      Color(0xFF111827),
    ],
  );

  // Header gradient
  static const LinearGradient header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF111827),
      Color(0xFF0D1320),
    ],
  );

  // Card subtle gradient
  static const LinearGradient cardSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E2535),
      Color(0xFF1A1F2E),
    ],
  );

  // Neon green gradient (for buttons, accents)
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB8FF57),
      Color(0xFF8CD43C),
    ],
  );

  // Splash screen gradient
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0F1E),
      Color(0xFF0F1A12),
      Color(0xFF0A0F1E),
    ],
  );
}

// ============================================================
// GLASS DECORATION SYSTEM
// ============================================================
class AppGlass {
  /// Standard glass card decoration
  static BoxDecoration card({
    double opacity = 0.06,
    double borderOpacity = 0.08,
    double radius = 20,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: glowColor?.withValues(alpha: borderOpacity) ??
            Colors.white.withValues(alpha: borderOpacity),
        width: 1,
      ),
    );
  }

  /// Elevated dark card (more opaque, like the reference)
  static BoxDecoration elevatedCard({
    double radius = 20,
    bool withGlow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      gradient: AppGradients.cardSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: withGlow
            ? (glowColor ?? AppColors.primary).withValues(alpha: 0.15)
            : AppColors.border.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: withGlow
          ? [
              BoxShadow(
                color: (glowColor ?? AppColors.primary).withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  /// Input field glass decoration
  static BoxDecoration input({bool focused = false}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: focused
            ? AppColors.primary.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.06),
        width: focused ? 1.5 : 1,
      ),
    );
  }

  /// Bottom navigation bar glass
  static BoxDecoration navbar() {
    return BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.95),
      border: const Border(
        top: BorderSide(color: AppColors.borderLight, width: 0.5),
      ),
    );
  }
}

// ============================================================
// SPACING SYSTEM
// ============================================================
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

// ============================================================
// RADIUS SYSTEM
// ============================================================
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;
}

// ============================================================
// SHADOW SYSTEM
// ============================================================
class AppShadows {
  static List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowColored(Color color, {double intensity = 0.15}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}

// ============================================================
// THEME DATA — Dark Glassmorphism
// ============================================================
class AppTheme {
  static ThemeData get darkGlassTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySurface,
        secondary: AppColors.primaryLight,
        error: AppColors.error,
        surface: AppColors.surface,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        displayMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        bodySmall: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 12),
        labelLarge: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.base),
          borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        backgroundColor: AppColors.surface,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Colors.white.withValues(alpha: 0.04),
        ),
      ),
    );
  }

  // Keep backward compatibility
  static ThemeData get lightTheme => darkGlassTheme;
}
