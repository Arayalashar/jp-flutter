import 'package:flutter/material.dart';
import 'dart:math';

/// Animated dark background with floating gradient orbs
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? orbColors;
  final int orbCount;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.orbColors,
    this.orbCount = 3,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.orbColors ??
        [
          const Color(0xFF1A3A2A),  // Dark emerald
          const Color(0xFF0F2A1F),  // Deeper green
          const Color(0xFF162035),  // Navy tint
        ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0F1E),
            Color(0xFF0D1320),
            Color(0xFF111827),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbPainter(
              progress: _controller.value,
              colors: colors,
              orbCount: widget.orbCount,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final int orbCount;

  _OrbPainter({
    required this.progress,
    required this.colors,
    required this.orbCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent positions
    
    for (int i = 0; i < orbCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final radius = 80.0 + random.nextDouble() * 120;
      
      // Gentle circular motion
      final angle = progress * 2 * pi + (i * pi / orbCount);
      final drift = 30.0 + random.nextDouble() * 20;
      final x = baseX + cos(angle) * drift;
      final y = baseY + sin(angle * 0.7) * drift;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i % colors.length].withValues(alpha: 0.15),
            colors[i % colors.length].withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
