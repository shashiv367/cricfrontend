import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Default background for all app pages (1st image): very light base with
/// scattered semi-transparent blurred circles in light pastel purple and pink.
class DefaultPageBackground extends StatelessWidget {
  final Widget? child;

  const DefaultPageBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // White base
        Positioned.fill(
          child: Container(color: AppColors.scaffoldSurface),
        ),
        // Soft blurred glowing shapes (ethereal overlay)
        Positioned.fill(
          child: CustomPaint(
            painter: _BlurShapesPainter(),
            size: Size.infinite,
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _BlurShapesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Scattered pastel purple and pink circles (clearly visible)
    final shapes = [
      _Shape(Offset(size.width * 0.15, size.height * 0.08), size.width * 0.55, size.width * 0.4, AppColors.blurShapeLightPurple, 0.22),
      _Shape(Offset(size.width * 0.65, size.height * 0.12), size.width * 0.5, size.width * 0.35, AppColors.blurShapeLightPink, 0.18),
      _Shape(Offset(size.width * 0.02, size.height * 0.38), size.width * 0.45, size.width * 0.55, AppColors.blurShapeLightPurple, 0.16),
      _Shape(Offset(size.width * 0.58, size.height * 0.48), size.width * 0.55, size.width * 0.45, AppColors.blurShapeLightPink, 0.15),
      _Shape(Offset(size.width * 0.72, size.height * 0.72), size.width * 0.5, size.width * 0.4, AppColors.blurShapeLightPink, 0.18),
      _Shape(Offset(size.width * 0.08, size.height * 0.76), size.width * 0.4, size.width * 0.45, AppColors.blurShapeLightPurple, 0.14),
      _Shape(Offset(size.width * 0.38, size.height * 0.32), size.width * 0.35, size.width * 0.4, AppColors.blurShapeLightPurple, 0.12),
    ];
    for (final s in shapes) {
      _paintBlurShape(canvas, s);
    }
  }

  void _paintBlurShape(Canvas canvas, _Shape s) {
    final rect = Rect.fromCenter(center: s.center, width: s.w, height: s.h);
    final paint = Paint()
      ..color = s.color.withOpacity(s.opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawOval(rect, paint);
    // Softer inner glow
    final innerPaint = Paint()
      ..color = s.color.withOpacity(s.opacity * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    canvas.drawOval(rect, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Shape {
  final Offset center;
  final double w;
  final double h;
  final Color color;
  final double opacity;
  _Shape(this.center, this.w, this.h, this.color, this.opacity);
}
