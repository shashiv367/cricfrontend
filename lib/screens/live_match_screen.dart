import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LiveMatchScreen extends StatefulWidget {
  const LiveMatchScreen({super.key});

  @override
  State<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends State<LiveMatchScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: TabBarView(
              children: [
                _buildLiveTab(),
                _buildUpcomingTab(),
                _buildRecentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryElectric, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  Text(
                    'Matches',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'LIVE'),
                Tab(text: 'UPCOMING'),
                Tab(text: 'RECENT'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildSeriesHeader('LEAGUE'),
        _buildSeriesCard('BIG BASH LEAGUE 2025-26'),
        _buildMatchItem(
          '38th Match • Adelaide',
          'MLR', '99 (16.5)',
          'ADS', '100-2 (11.5)',
          'Adelaide Strikers won by 8 wkts',
          isLive: false,
        ),
        _buildSeriesCard('BANGLADESH PREMIER LEAGUE 2025-26'),
        _buildMatchItem(
          '27th Match • Dhaka',
          'RGR', '168-2 (18.3)',
          'DHCP', '',
          'Dhaka Capitals opt to bowl',
          isLive: true,
        ),
        _buildSeriesHeader('DOMESTIC'),
        _buildSeriesCard('ICC UNDER 19 WORLD CUP 2026'),
        _buildMatchItem(
          '7th Match, Group A • Bulawayo',
          'INDU19', '63-3 (12.5)',
          'TBC', '',
          'Match in progress',
          isLive: true,
        ),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildSeriesHeader('INTERNATIONAL'),
        _buildSeriesCard('NEW ZEALAND TOUR OF INDIA, 2026'),
        _buildMatchItem(
          '3rd ODI • Indore',
          'India', '',
          'New Zealand', '',
          'Tomorrow • 1:30 PM',
        ),
        _buildSeriesHeader('LEAGUE'),
        _buildSeriesCard('SA20, 2025-26'),
        _buildMatchItem(
          '27th Match • Durban',
          'Durbans Super Giants', '',
          'Paarl Royals', '',
          'Today • 4:30 PM',
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildSeriesHeader('INTERNATIONAL'),
        _buildSeriesCard('NEW ZEALAND TOUR OF INDIA, 2026'),
        _buildMatchItem(
          '2nd ODI • Rajkot',
          'IND', '284-7 (50)',
          'NZ', '286-3 (47.3)',
          'New Zealand won by 7 wkts',
          isDone: true,
        ),
      ],
    );
  }

  Widget _buildSeriesHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.black, // Changed from AppColors.textSecondary as requested
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSeriesCard(String seriesName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade100.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              seriesName,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildMatchItem(
    String info,
    String team1, String score1,
    String team2, String score2,
    String status,
    {bool isLive = false, bool isDone = false}
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/live-detail'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(info, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(width: 20, height: 20, color: Colors.grey.shade200), // Logo
                const SizedBox(width: 8),
                Expanded(child: Text(team1, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Text(score1, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 20, height: 20, color: Colors.grey.shade200), // Logo
                const SizedBox(width: 8),
                Expanded(child: Text(team2, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                Text(score2, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              status,
              style: TextStyle(
                color: isLive ? Colors.red : (isDone ? AppColors.primaryElectric : Colors.orange),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
