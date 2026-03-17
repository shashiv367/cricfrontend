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
    return const Center(
      child: Text('No past bets yet'),
    );
  }
}










