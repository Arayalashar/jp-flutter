import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Reusable glassmorphism card with subtle dark glass effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double opacity;
  final double borderOpacity;
  final double radius;
  final bool withGlow;
  final Color? glowColor;
  final bool useBlur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.opacity = 0.06,
    this.borderOpacity = 0.08,
    this.radius = 20,
    this.withGlow = false,
    this.glowColor,
    this.useBlur = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: withGlow
          ? AppGlass.elevatedCard(
              radius: radius,
              withGlow: true,
              glowColor: glowColor,
            )
          : AppGlass.elevatedCard(radius: radius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.02),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );

    if (useBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: card,
        ),
      );
    }

    return card;
  }
}
