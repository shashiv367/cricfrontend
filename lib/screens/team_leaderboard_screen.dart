import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Team Leaderboard: app bar, tabs (Leather ball / Tennis ball / Box cricket),
/// criteria text, team list with logo/checkmark/since/score, challenge cards.
/// Uses DefaultPageBackground and app color palette.
class TeamLeaderboardScreen extends StatefulWidget {
  const TeamLeaderboardScreen({super.key});

  @override
  State<TeamLeaderboardScreen> createState() => _TeamLeaderboardScreenState();
}

class _TeamLeaderboardScreenState extends State<TeamLeaderboardScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  static const List<String> _tabs = ['Leather ball', 'Tennis ball', 'Box cricket'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _tabController;
    if (controller == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryElectric)),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Team Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: 280,
              child: TabBar(
                controller: controller,
                isScrollable: false,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: _tabs.map((s) => Tab(text: s)).toList(),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: const [
          _TeamLeaderboardPage(sportIndex: 0),
          _TeamLeaderboardPage(sportIndex: 1),
          _TeamLeaderboardPage(sportIndex: 2),
        ],
      ),
    );
  }
}

class _TeamLeaderboardPage extends StatefulWidget {
  final int sportIndex;

  const _TeamLeaderboardPage({required this.sportIndex});

  @override
  State<_TeamLeaderboardPage> createState() => _TeamLeaderboardPageState();
}

class _TeamLeaderboardPageState extends State<_TeamLeaderboardPage> {
  bool _showChallenges = true;

  static const String _criteria = 'Most Matches Played in Hyderabad (Telangana) (2026, All Overs)';

  List<Map<String, dynamic>> _getTeams(int sportIndex) {
    const teams = [
      {'name': 'Crick Players', 'since': '26-Jan-2021', 'score': 45},
      {'name': 'Titans', 'since': '15-Mar-2020', 'score': 30},
      {'name': 'Men In Blue', 'since': '08-Sep-2022', 'score': 25},
      {'name': 'Team Kanyaraasi', 'since': '12-Nov-2021', 'score': 22},
      {'name': 'Team Warriors', 'since': '20-May-2023', 'score': 20},
      {'name': 'Alpha Assassin', 'since': '03-Jul-2020', 'score': 18},
      {'name': 'Cricbuddies XI', 'since': '24-Jul-2025', 'score': 29},
      {'name': 'Yellamma Banda Tigers', 'since': '11-Feb-2024', 'score': 27},
      {'name': 'Victory Kings', 'since': '23-Oct-2020', 'score': 15},
      {'name': 'StarRiders Initiators', 'since': '02-Jan-2026', 'score': 14},
      {'name': 'DRK XI', 'since': '19-Aug-2023', 'score': 13},
      {'name': 'ROYALS CRICKET CLUB XI', 'since': '30-Apr-2022', 'score': 12},
    ];
    return teams;
  }

  @override
  Widget build(BuildContext context) {
    final teams = _getTeams(widget.sportIndex);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _criteria,
            style: const TextStyle(
              color: AppColors.primaryTeal,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        ...teams.asMap().entries.map((e) => _buildTeamRow(
          rank: e.key + 1,
          name: e.value['name'] as String,
          since: e.value['since'] as String,
          score: e.value['score'] as int,
        )),
        if (_showChallenges) _buildChallengesSection(),
      ],
    );
  }

  Widget _buildTeamRow({required int rank, required String name, required String since, required int score}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Text(
            rank.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.backgroundCardAlt,
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Since $since',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gps_fixed, color: AppColors.primaryElectric, size: 20),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Ready to challenge yourself?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showChallenges = false),
                child: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildChallengeCard('5 CATCHES', '5 catches'),
                _buildChallengeCard('1 5W-HAUL', 'One 5-wicket haul'),
                _buildChallengeCard('2 RUN OUTS', '2 run outs'),
                _buildChallengeCard('2 3W-HAULS', 'Two 3-wicket hauls'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: const Text('Explore', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(String badgeText, String title) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryElectric.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    badgeText.length > 10 ? '${badgeText.substring(0, 8)}..' : badgeText,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          Row(
            children: [
              const Text('Limited Overs', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 4),
              Icon(Icons.sports_cricket, size: 12, color: AppColors.primaryElectric),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: Text('Join', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
