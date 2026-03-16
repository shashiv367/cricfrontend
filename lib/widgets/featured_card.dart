import 'package:flutter/material.dart';

class FeaturedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Color color;

  const FeaturedCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


