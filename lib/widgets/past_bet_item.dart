import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PastBetItem extends StatelessWidget {
  final String date;
  final String team1;
  final String team2;
  final int score1;
  final int score2;
  final String result;
  final bool isWin;

  const PastBetItem({
    super.key,
    required this.date,
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.result,
    required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        color: AppColors.primaryPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        team1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$score1 - $score2',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        team2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        color: AppColors.primaryPurple,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isWin
                  ? AppColors.successGreen.withOpacity(0.1)
                  : AppColors.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              result,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: isWin ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}










