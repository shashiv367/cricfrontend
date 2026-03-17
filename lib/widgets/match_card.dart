import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MatchCard extends StatelessWidget {
  final String team1;
  final String team2;
  final int score1;
  final int score2;
  final bool isLive;
  final String? overs1;
  final String? overs2;
  final String? matchStatus;         // e.g. "22 Apr 17:20"
  final String? subtitle;            // e.g. "Home will win"
  final Color? subtitleColor;        // e.g. AppColors.accentGreen
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.team1,
    required this.team2,
    required this.score1,
    required this.score2,
    required this.isLive,
    this.overs1,
    this.overs2,
    this.matchStatus,
    this.subtitle,
    this.subtitleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Date / Match Status (Top Center)
            if (matchStatus != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  matchStatus!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Team 1
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(team1),
                      const SizedBox(height: 8),
                      Text(
                        team1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Score
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        '$score1 - $score2',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isLive)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentRed,
                            borderRadius: BorderRadius.circular(4),
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
                      if (!isLive && overs1 != null) ...[
                         const SizedBox(height: 4),
                         Text(
                           "FT", // Full Time / Finished
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.textSecondary,
                            ),
                         ),
                      ]
                    ],
                  ),
                ),

                // Team 2
                Expanded(
                  child: Column(
                    children: [
                      _buildTeamLogo(team2),
                      const SizedBox(height: 8),
                      Text(
                        team2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Prediction Pill / Subtitle (Bottom Center)
            if (subtitle != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: subtitleColor ?? AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String teamName) {
    // Placeholder logic for logos based on team name
    // In a real app, this would be an Image.network or Asset
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
