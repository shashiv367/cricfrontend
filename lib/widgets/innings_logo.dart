import 'package:flutter/material.dart';

class InningsLogo extends StatelessWidget {
  final double height;
  final Color color;

  const InningsLogo({
    super.key,
    this.height = 30,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Styled Cricket Ball Icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: height * 0.8,
                height: height * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color, width: 1.5),
                ),
              ),
              Icon(
                Icons.sports_cricket,
                size: height * 0.6,
                color: color,
              ),
            ],
          ),
          const SizedBox(width: 8),
          // "INNINGS" Text
          Text(
            'INNINGS',
            style: TextStyle(
              color: color,
              fontSize: height * 0.6,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
