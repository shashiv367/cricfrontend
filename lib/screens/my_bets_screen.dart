import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/past_bet_item.dart';

class MyBetsScreen extends StatefulWidget {
  const MyBetsScreen({super.key});

  @override
  State<MyBetsScreen> createState() => _MyBetsScreenState();
}

class _MyBetsScreenState extends State<MyBetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bets'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryPurple,
            labelColor: AppColors.primaryPurple,
            unselectedLabelColor: AppColors.textLight,
            tabs: const [
              Tab(text: 'Placed Bets'),
              Tab(text: 'Past Bets'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlacedBets(),
                _buildPastBets(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacedBets() {
    return const Center(
      child: Text('No placed bets yet'),
    );
  }

  Widget _buildPastBets() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        PastBetItem(
          date: '22 Apr 17:20',
          team1: 'Liverpool',
          team2: 'Chelsea',
          score1: 2,
          score2: 0,
          result: 'Home will win',
          isWin: true,
        ),
        const SizedBox(height: 12),
        PastBetItem(
          date: '15 Apr 14:00',
          team1: 'Tottenham',
          team2: 'Manchester City',
          score1: 0,
          score2: 1,
          result: 'Guest will win',
          isWin: false,
        ),
        const SizedBox(height: 12),
        PastBetItem(
          date: '3 Apr 10:30',
          team1: 'Chelsea',
          team2: 'Manchester United',
          score1: 0,
          score2: 0,
          result: 'Draw',
          isWin: true,
        ),
        const SizedBox(height: 12),
        PastBetItem(
          date: '28 Mar 20:00',
          team1: 'Tottenham',
          team2: 'Chelsea',
          score1: 1,
          score2: 2,
          result: 'Guest will win',
          isWin: true,
        ),
      ],
    );
  }
}










