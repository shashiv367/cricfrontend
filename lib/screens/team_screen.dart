import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'team_detail_screen.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teams = [
      {
        'name': 'India',
        'country': 'India',
        'ranking': 1,
        'players': [
          'Rohit Sharma', 'Virat Kohli', 'Shubman Gill', 'Hardik Pandya',
          'Jasprit Bumrah', 'Ravindra Jadeja'
        ]
      },
      {
        'name': 'Australia',
        'country': 'Australia',
        'ranking': 2,
        'players': [
          'Pat Cummins', 'David Warner', 'Steve Smith', 'Marnus Labuschagne',
          'Mitchell Starc', 'Glenn Maxwell'
        ]
      },
      {
        'name': 'England',
        'country': 'England',
        'ranking': 3,
        'players': [
          'Joe Root', 'Ben Stokes', 'Jos Buttler', 'Jofra Archer',
          'Harry Brook', 'Adil Rashid'
        ]
      },
      {
        'name': 'New Zealand',
        'country': 'New Zealand',
        'ranking': 4,
        'players': [
          'Kane Williamson', 'Devon Conway', 'Trent Boult', 'Tim Southee',
          'Daryl Mitchell', 'Mitchell Santner'
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                child: Text(
                  team['ranking'].toString(),
                  style: const TextStyle(
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                team['name'].toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Text(
                team['country'].toString(),
                style: const TextStyle(
                  color: AppColors.textLight,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamDetailScreen(
                      teamName: team['name'].toString(),
                      players: (team['players'] as List<String>),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


