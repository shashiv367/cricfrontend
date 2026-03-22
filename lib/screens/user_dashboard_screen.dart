import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'dart:developer' as developer;
import 'dart:async';

class UserDashboardScreen extends StatefulWidget {
  final String? searchQuery;
  const UserDashboardScreen({super.key, this.searchQuery});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> with SingleTickerProviderStateMixin {
  String get _effectiveQuery => widget.searchQuery ?? '';
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;
  late TabController _feedTabController;
  int _feedTabIndex = 0;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _feedTabController = TabController(length: 2, vsync: this);
    _feedTabController.addListener(() {
      if (_feedTabController.indexIsChanging) setState(() => _feedTabIndex = _feedTabController.index);
    });
    _loadMatches();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      // Lightweight refresh while user is on dashboard so scores update after scoring.
      _loadMatches(silent: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _feedTabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      final response = await ApiService.listMatches(token: token);
      if (mounted) {
        setState(() {
          _matches = List<Map<String, dynamic>>.from(response['matches'] ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading matches: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: AppColors.primaryElectric,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // CricHeroes-style: For you / Club tabs (below app bar)
            Container(
              color: Colors.transparent,
              child: TabBar(
                controller: _feedTabController,
                onTap: (i) => setState(() => _feedTabIndex = i),
                indicatorColor: AppColors.primaryElectric,
                indicatorWeight: 3,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'For you'),
                  Tab(text: 'Club'),
                ],
              ),
            ),
            if (_effectiveQuery.isNotEmpty) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Search results for "$_effectiveQuery"',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryElectric),
                ),
              ),
            // 1. Matches of your contacts (CricHeroes-style heading)
            _buildSectionHeader('Matches of your contacts', showViewAll: true),
            _buildHighFidelityMatchList(),
            const SizedBox(height: 16),
            // 2. Ad banner placeholder (CricHeroes-style)
            _buildAdBannerPlaceholder(),
            const SizedBox(height: 16),
            // 3. Popular cricketers
            _buildSectionHeader('Popular cricketers', actionText: 'Find Cricketers'),
            _buildPopularCricketersSection(),
            const SizedBox(height: 16),
            // 4. Cricket Feed
            _buildSectionHeader('Cricket Feed', showViewAll: false),
            _buildCricketFeedSection(),
            const SizedBox(height: 16),
            // 5. From your tournaments
            _buildSectionHeader('From your tournaments', actionText: 'Find Cricketers'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/coming-soon', arguments: {'title': 'Create Tournament'}),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Create tournament'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryElectric,
                  side: BorderSide(color: AppColors.primaryElectric),
                ),
              ),
            ),
            _buildTournamentsSection(),
            const SizedBox(height: 40),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplifiedTopBar() {
    return Container(
      color: AppColors.scaffoldSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryElectric.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'For you',
              style: TextStyle(
                color: AppColors.primaryElectric,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showViewAll = false, String? actionText}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
          ),
          InkWell(
            onTap: showViewAll ? () => Navigator.pushNamed(context, '/all-matches') : null,
            child: Text(
              actionText ?? (showViewAll ? 'View All' : ''),
              style: const TextStyle(color: AppColors.primaryTeal, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCricketFeedSection() {
    final feedItems = [
      {'icon': Icons.play_circle_outline, 'label': 'Videos', 'sub': 'Cricket clips'},
      {'icon': Icons.newspaper, 'label': 'News', 'sub': 'Latest updates'},
      {'icon': Icons.quiz_outlined, 'label': 'Quizzes', 'sub': 'Test your knowledge'},
      {'icon': Icons.poll_outlined, 'label': 'Polls', 'sub': 'Have your say'},
      {'icon': Icons.auto_stories_outlined, 'label': 'Stories', 'sub': 'Friends\' matches'},
    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: feedItems.length,
        itemBuilder: (context, index) {
          final item = feedItems[index] as Map<String, dynamic>;
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: AppColors.primaryElectric,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item['sub'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdBannerPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sports_cricket_rounded, color: AppColors.primaryElectric.withOpacity(0.9), size: 28),
                const SizedBox(height: 8),
                Text(
                  'World-class score overlays for grassroots matches.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Use score overlay →'),
                ),
              ],
            ),
          ),
          const Icon(Icons.laptop_mac, color: Colors.white24, size: 64),
        ],
      ),
    );
  }

  Widget _buildPopularCricketersSection() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryElectric.withOpacity(0.15),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Center(child: Icon(Icons.person, size: 48, color: AppColors.primaryElectric)),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryTeal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Cricketer ${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighFidelityMatchList() {
    final filteredMatches = _matches.where((m) {
      if (m == null) return false;
      if (_effectiveQuery.isEmpty) return true;
      final q = _effectiveQuery.toLowerCase();
      
      String t1 = '';
      if (m['team_a'] is Map) {
        t1 = (m['team_a']['name'] ?? '').toString().toLowerCase();
      } else {
        t1 = (m['team_a_name'] ?? m['team_a'] ?? '').toString().toLowerCase();
      }

      String t2 = '';
      if (m['team_b'] is Map) {
        t2 = (m['team_b']['name'] ?? '').toString().toLowerCase();
      } else {
        t2 = (m['team_b_name'] ?? m['team_b'] ?? '').toString().toLowerCase();
      }

      return t1.contains(q) || t2.contains(q);
    }).toList();

    return SizedBox(
      height: 245,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredMatches.isEmpty ? 2 : filteredMatches.length,
        itemBuilder: (context, index) {
          if (filteredMatches.isEmpty) return _buildPlaceholderMatchCard();
          return _buildActualMatchCard(filteredMatches[index]);
        },
      ),
    );
  }

  Widget _buildPlaceholderMatchCard() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/live-detail',
          arguments: {'matchId': 'placeholder', 'initialTabIndex': 0},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // no static placeholder content – use real matches only
          const Spacer(),
          // Footer Links (CricHeroes-style: Insights, Squads)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundCardAlt,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Insights', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(width: 16),
                Text('Squads', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTeamRow(String name, String score, String overs, bool isWinner) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isWinner ? Colors.black : Colors.grey[400],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              score,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isWinner ? Colors.black : Colors.grey[400],
              ),
            ),
            Text(overs, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildActualMatchCard(Map<String, dynamic> match) {
    // Basic mapping from API to high-fidelity card
    return InkWell(
      onTap: () {
        final matchId = match['id']?.toString() ?? match['match_id']?.toString();
        if (matchId != null) {
          Navigator.pushNamed(
            context,
            '/live-detail',
            arguments: {'matchId': matchId, 'initialTabIndex': 0},
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('Tournament Match', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryElectric, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Live', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTeamRow(
                    match['team_a'] is Map ? (match['team_a']['name'] ?? 'Team A') : (match['team_a_name'] ?? 'Team A'), 
                    '${match['score'] is Map ? (match['score']['team_a_score'] ?? 0) : (match['score_a'] ?? 0)}/${match['score'] is Map ? (match['score']['team_a_wkts'] ?? 0) : (match['wickets_a'] ?? 0)}', 
                    '(Ov ${match['score'] is Map ? (match['score']['team_a_overs'] ?? 0) : (match['overs_a'] ?? 0)})', 
                    true
                  ),
                  const SizedBox(height: 12),
                  _buildTeamRow(
                    match['team_b'] is Map ? (match['team_b']['name'] ?? 'Team B') : (match['team_b_name'] ?? 'Team B'), 
                    '${match['score'] is Map ? (match['score']['team_b_score'] ?? 0) : (match['score_b'] ?? 0)}/${match['score'] is Map ? (match['score']['team_b_wkts'] ?? 0) : (match['wickets_b'] ?? 0)}', 
                    '(Ov ${match['score'] is Map ? (match['score']['team_b_overs'] ?? 0) : (match['overs_b'] ?? 0)})', 
                    false
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('View Scorecard', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMidnightBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 165, // Increased from 140 to prevent overflow
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.primaryElectric.withOpacity(0.05), Colors.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sports_cricket, color: AppColors.primaryElectric, size: 14),
                      const SizedBox(width: 4),
                      const Text('Innings PRO', style: TextStyle(color: AppColors.primaryElectric, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Premium theme, now part of your basic plan', style: TextStyle(color: Color(0xFF666666), fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text('Midnight Fire.', style: TextStyle(color: AppColors.primaryElectric, fontWeight: FontWeight.w900, fontSize: 22)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Try now →', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: 10,
                  child: Icon(Icons.laptop, color: Colors.grey[200], size: 140),
                ),
                Center(child: Icon(Icons.sports_cricket, color: AppColors.primaryElectric.withOpacity(0.1), size: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsSection() {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          width: 145,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: index % 2 == 0 ? const Color(0xFF1E293B) : const Color(0xFF334155),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -10, bottom: -10,
                          child: Icon(Icons.sports_cricket, color: Colors.white10, size: 80),
                        ),
                        const Center(child: Icon(Icons.person_pin, size: 50, color: Colors.white24)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      index == 0 ? 'Manas Kumar' : 'Jashwath',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
                    ),
                    const Text('R:0  W:0', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryTeal),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Follow', style: TextStyle(color: AppColors.primaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
