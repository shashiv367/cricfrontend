import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FeaturedMatchCard extends StatelessWidget {
  final String league;
  final String team1;
  final String team2;
  final int score1;
  final int score2;
  final String time;
  final String question;

  const FeaturedMatchCard({
    super.key,
    required this.league,
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.time,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: League Name + Live Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const SizedBox(width: 40), // spacer to center title roughly
               Text(
                 league,
                 style: const TextStyle(
                   color: AppColors.textPrimary,
                   fontSize: 14,
                   fontWeight: FontWeight.normal,
                 ),
               ),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: AppColors.accentRed,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Text(
                   'LIVE',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 10,
                     fontWeight: FontWeight.normal,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 20),

          // Scores Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTeamColumn(team1),
              Column(
                children: [
                  const Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$score1 - $score2',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              _buildTeamColumn(team2),
            ],
          ),

          const SizedBox(height: 20),

          // Time Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.45, // Demo value
                  backgroundColor: AppColors.backgroundLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                  minHeight: 6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // Question
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: _buildPredictionButton(
                  'No',
                  Colors.white,
                  AppColors.accentRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPredictionButton(
                  'Yes',
                  Colors.white,
                  AppColors.accentGreen,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTeamColumn(String name) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
             shape: BoxShape.circle,
             border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0] : '?',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionButton(String label, Color textColor, Color color) {
    // For outline style:
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
