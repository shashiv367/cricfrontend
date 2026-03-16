import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SplatterBackground extends StatelessWidget {
  final Widget child;
  final double topOffset;

  const SplatterBackground({
    super.key, 
    required this.child,
    this.topOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Splatter/Artist Background
        Positioned.fill(
          child: Container(
            color: Colors.white, // Canvas color
            child: Stack(
              children: [
                // Top Main Splash
                Positioned(
                  top: -80 + topOffset,
                  left: -50,
                  right: -50,
                  child: Transform.rotate(
                    angle: -0.05,
                    child: Container(
                      height: 380,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryElectric,
                            AppColors.primaryElectric.withOpacity(0.9),
                            AppColors.primaryElectric.withOpacity(0.8),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Irregular splashes to create "grunge" look
                Positioned(
                  top: 250 + topOffset,
                  left: 40,
                  child: _buildInkDrop(100, AppColors.primaryElectric.withOpacity(0.3)),
                ),
                Positioned(
                  top: 280 + topOffset,
                  right: 60,
                  child: _buildInkDrop(120, AppColors.primaryElectric.withOpacity(0.4)),
                ),
                Positioned(
                  top: 320 + topOffset,
                  left: 120,
                  child: _buildInkDrop(60, AppColors.primaryElectric.withOpacity(0.2)),
                ),
                Positioned(
                  top: 200 + topOffset,
                  right: -20,
                  child: _buildInkDrop(150, AppColors.primaryElectric.withOpacity(0.15)),
                ),

                // Subtle smaller dots far below
                Positioned(
                  bottom: 200,
                  left: 80,
                  child: _buildInkDrop(20, AppColors.primaryElectric.withOpacity(0.05)),
                ),
                Positioned(
                  bottom: 250,
                  right: 120,
                  child: _buildInkDrop(15, AppColors.primaryElectric.withOpacity(0.05)),
                ),
              ],
            ),
          ),
        ),

        // The actual content
        child,
      ],
    );
  }

  Widget _buildInkDrop(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
