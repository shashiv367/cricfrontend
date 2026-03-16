import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rankings = [
      {'team': 'India', 'matches': 20, 'wins': 15, 'points': 120, 'nrr': '+1.45'},
      {'team': 'Australia', 'matches': 20, 'wins': 13, 'points': 110, 'nrr': '+1.12'},
      {'team': 'England', 'matches': 19, 'wins': 12, 'points': 105, 'nrr': '+0.98'},
      {'team': 'New Zealand', 'matches': 18, 'wins': 11, 'points': 99, 'nrr': '+0.85'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ICC Ranking Men\'s'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Test',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ODI',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    'T20',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Team',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'M',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'W',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    'NRR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: rankings.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final r = rankings[index];
                  return Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor:
                                  AppColors.primaryPurple.withOpacity(0.1),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              r['team'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r['matches'].toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r['wins'].toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r['points'].toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r['nrr'].toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


