import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SportCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SportCategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}










