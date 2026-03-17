import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      {'name': 'Virat Kohli', 'team': 'India', 'role': 'Batsman', 'runs': 12000},
      {'name': 'Jasprit Bumrah', 'team': 'India', 'role': 'Bowler', 'wickets': 250},
      {'name': 'Steve Smith', 'team': 'Australia', 'role': 'Batsman', 'runs': 9500},
      {'name': 'Ben Stokes', 'team': 'England', 'role': 'All-rounder', 'runs': 5500},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Players'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primaryPurple,
                ),
              ),
              title: Text(
                player['name'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Text(
                '${player['team']} • ${player['role']}',
                style: const TextStyle(
                  color: AppColors.textLight,
                ),
              ),
              trailing: Text(
                player.containsKey('runs')
                    ? '${player['runs']} runs'
                    : '${player['wickets']} wkts',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  color: AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}










