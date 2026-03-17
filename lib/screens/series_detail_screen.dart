import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({super.key});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // MATCHES, TABLE, SQUADS, NEWS
      initialIndex: 1, // Default to TABLE tab
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: TabBarView(
              children: [
                _buildMatchesTab(),
                _buildTableTab(),
                _buildSquadsTab(),
                _buildNewsTab(),
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Big Bash League 2025-26',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
                ],
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 10),
              tabs: [
                Tab(text: 'MATCHES'),
                Tab(text: 'TABLE'),
                Tab(text: 'SQUADS'),
                Tab(text: 'NEWS'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- MATCHES TAB ---
  Widget _buildMatchesTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildMatchListItem('38th Match • Adelaide', 'MLR', '99 (16.5)', 'ADS', '78-2 (10.0)', 'Adelaide Strikers need 22 runs in 60 balls', isLive: true),
        _buildMatchListItem('39th Match • Perth', 'Perth Scorchers', '', 'Melbourne Stars', '', '2:45 PM'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text('SUN, 18 JAN 2026', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5)),
        ),
        _buildMatchListItem('40th Match • Brisbane', 'Brisbane Heat', '', 'Sydney Sixers', '', '1:45 PM'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text('TUE, 20 JAN 2026', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5)),
        ),
        _buildMatchListItem('Qualifier • TBC', 'TBC', '', 'TBC', '', '2:00 PM'),
      ],
    );
  }

  Widget _buildMatchListItem(String title, String team1, String score1, String team2, String score2, String status, {bool isLive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.normal)),
              const Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 24, height: 24, color: Colors.grey.shade200), // Placeholder for logo
              const SizedBox(width: 12),
              Expanded(child: Text(team1, style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textPrimary))),
              Text(score1, style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 24, height: 24, color: Colors.grey.shade200), // Placeholder for logo
              const SizedBox(width: 12),
              Expanded(child: Text(team2, style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textPrimary))),
              Text(score2, style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(status, style: TextStyle(color: isLive ? Colors.red : Colors.orange, fontWeight: FontWeight.normal, fontSize: 13)),
        ],
      ),
    );
  }

  // --- TABLE TAB --- (CricHeroes-style: points table + NRR / qualification)
  Widget _buildTableTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.calculate_outlined, size: 18, color: AppColors.primaryElectric),
                const SizedBox(width: 8),
                Text(
                  'Smart NRR • Qualification margins shown in table',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                _buildTableRow('1', 'HBH (Q)', '10', '6', '3', '1', '13', '+0.331'),
                _buildTableRow('2', 'PRS (Q)', '9', '6', '3', '0', '12', '+1.319'),
                _buildTableRow('3', 'MLS (Q)', '9', '6', '3', '0', '12', '+1.031'),
                _buildTableRow('4', 'SYS', '9', '5', '3', '1', '11', '+0.566'),
                _buildTableRow('5', 'BRH', '9', '5', '4', '0', '10', '-0.375'),
                _buildTableRow('6', 'ADS (E)', '9', '3', '6', '0', '6', '-0.625'),
                _buildTableRow('7', 'MLR (E)', '9', '3', '6', '0', '6', '-0.910'),
                _buildTableRow('8', 'SYT (E)', '10', '2', '8', '0', '4', '-1.212'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 30, child: Text('', textAlign: TextAlign.center)),
          Expanded(child: Text('Team', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 25, child: Text('P', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 25, child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 25, child: Text('L', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 25, child: Text('NR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 30, child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 50, child: Text('NRR', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11, color: AppColors.textSecondary))),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildTableRow(String rank, String team, String p, String w, String l, String nr, String pts, String nrr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(rank, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.normal))),
          Expanded(
            child: Row(
              children: [
                Container(width: 20, height: 20, color: Colors.grey.shade200), // Logo
                const SizedBox(width: 8),
                Text(team, style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.primaryElectric, fontSize: 13)),
              ],
            ),
          ),
          SizedBox(width: 25, child: Text(p, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          SizedBox(width: 25, child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          SizedBox(width: 25, child: Text(l, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          SizedBox(width: 25, child: Text(nr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          SizedBox(width: 30, child: Text(pts, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: AppColors.textPrimary))),
          SizedBox(width: 50, child: Text(nrr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black38),
        ],
      ),
    );
  }

  // --- NEWS TAB ---
  Widget _buildNewsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _buildNewsItem(
          'Smith ton nullifies Warner\'s as Sixers do the double over Thunder',
          'David Warner scored his second century of the BBL 2025/26 season, and for the second time finished on the losing side',
          '20 hrs ago',
        ),
        _buildNewsItem(
          'What Nayar\'s experience in women\'s cricket exposes about pathways',
          'Limited quality game time through the pathway leads to different pace of maturing as cricketers for women',
          '20 hrs ago',
        ),
        _buildNewsItem(
          'BBL to introduce designated player rule from 2026-27 season',
          'The rule has given the teams an option to name a \'designated batter\' during the bat flip with the player not eligible to bowl or field',
          '1 day ago',
        ),
        _buildNewsItem(
          'Finn Allen ton books Scorchers\' place in BBL Finals',
          'As a result of the 50-run loss, Melbourne Renegades are now out of contention for a place in the final four',
          '1 day ago',
        ),
      ],
    );
  }

  Widget _buildNewsItem(String title, String snippet, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 100, height: 70, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
            ],
          ),
          const SizedBox(height: 12),
          Text(snippet, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // --- SQUADS TAB ---
  Widget _buildSquadsTab() {
    final teams = [
      'Hobart Hurricanes',
      'Sydney Sixers',
      'Sydney Thunder',
      'Melbourne Stars',
      'Perth Scorchers',
      'Melbourne Renegades',
      'Brisbane Heat',
      'Adelaide Strikers',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('T20', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary, fontSize: 13, letterSpacing: 0.5)),
        ),
        ...teams.map((team) => _buildTeamListItem(team)),
      ],
    );
  }

  Widget _buildTeamListItem(String teamName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: ListTile(
        title: Text(teamName, style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.textPrimary)),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/team-squad',
            arguments: {'teamName': teamName},
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(child: Text('$title content', style: const TextStyle(color: Colors.black54)));
  }
}

