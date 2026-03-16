import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TeamDetailScreen extends StatelessWidget {
  final String teamName;
  final List<String> players;

  const TeamDetailScreen({
    super.key,
    required this.teamName,
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamName),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return Card(
            color: AppColors.backgroundCard,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.backgroundCardAlt,
                child: Text(
                  player.isNotEmpty ? player[0] : '?',
                  style: const TextStyle(color: AppColors.primaryBlue),
                ),
              ),
              title: Text(
                player,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.person_outline, color: AppColors.textSecondary),
            ),
          );
        },
      ),
    );
  }
}










