import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Transparent glass-style background from match detail screen: gradient base
/// plus soft splatters, bat/ball silhouettes, and floating bubbles. Use app-wide.
class GlassMatchBackground extends StatelessWidget {
  final Widget? child;

  const GlassMatchBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF3F4F6), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: BallAndBatPainter(),
            size: Size.infinite,
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

/// Painter: indigo splatters, bat/ball silhouettes, floating bubbles (from live_detail_screen).
class BallAndBatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 1. Indigo Splatters
    final splatterPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    final topSplatterGradient = LinearGradient(
      colors: [
        AppColors.primaryElectric.withOpacity(0.18),
        AppColors.primaryElectric.withOpacity(0.1),
        Colors.transparent,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    splatterPaint.shader = topSplatterGradient.createShader(Rect.fromLTWH(0, -50, size.width, 350));
    final mainSplatterPath = Path();
    mainSplatterPath.moveTo(-50, -50);
    mainSplatterPath.lineTo(size.width + 50, -50);
    mainSplatterPath.lineTo(size.width + 50, 200);
    mainSplatterPath.quadraticBezierTo(size.width * 0.7, 300, size.width * 0.4, 220);
    mainSplatterPath.quadraticBezierTo(size.width * 0.2, 350, -50, 250);
    mainSplatterPath.close();
    canvas.drawPath(mainSplatterPath, splatterPaint);

    final dropPaint = Paint()..color = AppColors.primaryElectric.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.2, 320), 40, dropPaint);
    canvas.drawCircle(Offset(size.width * 0.75, 280), 60, dropPaint);
    canvas.drawCircle(Offset(size.width * 0.1, 450), 25, dropPaint..color = AppColors.primaryElectric.withOpacity(0.05));
    canvas.drawCircle(Offset(size.width * 0.85, 520), 35, dropPaint);

    // 2. Cricket Bat silhouette
    final batPaint = Paint()
      ..color = AppColors.primaryElectric.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final batPath = Path();
    batPath.moveTo(25, 50);
    batPath.lineTo(35, 50);
    batPath.lineTo(35, 150);
    batPath.lineTo(25, 150);
    batPath.close();
    batPath.moveTo(15, 150);
    batPath.lineTo(45, 150);
    batPath.lineTo(48, 550);
    batPath.quadraticBezierTo(30, 580, 12, 550);
    batPath.close();
    canvas.save();
    canvas.translate(10, 50);
    canvas.rotate(-0.05);
    canvas.drawPath(batPath, batPaint);
    canvas.restore();

    // 3. Cricket Ball
    final ballGradient = RadialGradient(
      colors: [
        AppColors.accentSunset.withOpacity(0.15),
        AppColors.accentSunset.withOpacity(0.05),
      ],
    );
    paint.shader = ballGradient.createShader(Rect.fromCircle(center: const Offset(40, 650), radius: 40));
    canvas.drawCircle(const Offset(40, 650), 40, paint);
    final seamPaint = Paint()
      ..color = AppColors.accentSunset.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawArc(Rect.fromCircle(center: const Offset(40, 650), radius: 40), -1.0, 2.0, false, seamPaint);

    // 4. Bubbles
    final bubblePaint = Paint()..style = PaintingStyle.fill;
    final randOffsets = [
      const Offset(0.2, 0.1), const Offset(0.8, 0.2),
      const Offset(0.1, 0.4), const Offset(0.9, 0.5),
      const Offset(0.3, 0.7), const Offset(0.7, 0.8),
      const Offset(0.5, 0.9), const Offset(0.85, 0.15),
    ];
    final randSizes = [20.0, 40.0, 15.0, 30.0, 25.0, 45.0, 20.0, 35.0];
    final bubbleColors = [
      AppColors.primaryElectric,
      AppColors.accentSunset,
      const Color(0xFF10B981),
      const Color(0xFF7C3AED),
      AppColors.primaryElectric,
      AppColors.accentSunset,
      AppColors.primaryElectric,
      const Color(0xFF0EA5E9),
    ];
    for (int i = 0; i < randOffsets.length; i++) {
      final center = Offset(size.width * randOffsets[i].dx, size.height * randOffsets[i].dy);
      final radius = randSizes[i];
      final color = bubbleColors[i % bubbleColors.length];
      bubblePaint.shader = RadialGradient(
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, bubblePaint);
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(center + Offset(-radius * 0.3, -radius * 0.3), radius * 0.2, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
