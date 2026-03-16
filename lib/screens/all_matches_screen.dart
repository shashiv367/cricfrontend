import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'dart:developer' as developer;
import 'user_match_scoreboard_screen.dart';

class AllMatchesScreen extends StatefulWidget {
  const AllMatchesScreen({super.key});

  @override
  State<AllMatchesScreen> createState() => _AllMatchesScreenState();
}

class _AllMatchesScreenState extends State<AllMatchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('All Matches', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'LIVE'),
            Tab(text: 'COMPLETED'),
            Tab(text: 'UPCOMING'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MatchListTab(status: 'live'),
          _MatchListTab(status: 'completed'),
          _MatchListTab(status: 'upcoming'),
        ],
      ),
    );
  }
}

class _MatchListTab extends StatefulWidget {
  final String status;
  const _MatchListTab({required this.status});

  @override
  State<_MatchListTab> createState() => _MatchListTabState();
}

class _MatchListTabState extends State<_MatchListTab> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      final response = await ApiService.listMatches(token: token, status: widget.status);
      
      if (mounted) {
        setState(() {
          _matches = List<Map<String, dynamic>>.from(response['matches'] ?? []);
          _loading = false;
        });
      }
    } catch (e) {
      developer.log('Error loading ${widget.status} matches: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryElectric));
    }

    if (_matches.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadMatches,
        color: AppColors.primaryElectric,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildEmptyState(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: AppColors.primaryElectric,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length,
        itemBuilder: (context, index) => _buildMatchCard(_matches[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No ${widget.status} matches',
            style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for more action!',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final status = match['status']?.toString().toUpperCase() ?? widget.status.toUpperCase();
    final isLive = status == 'LIVE';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match['tournament_name'] ?? 'Local Match',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive ? AppColors.primaryElectric : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isLive ? Colors.white : Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTeamRow(
                match['team_a'] is Map ? (match['team_a']['name'] ?? 'Team A') : (match['team_a_name'] ?? 'Team A'),
                '${match['score'] is Map ? (match['score']['team_a_score'] ?? 0) : (match['score_a'] ?? 0)}/${match['score'] is Map ? (match['score']['team_a_wkts'] ?? 0) : (match['wickets_a'] ?? 0)}',
                '(Ov ${match['score'] is Map ? (match['score']['team_a_overs'] ?? 0) : (match['overs_a'] ?? 0)})',
                true,
              ),
              const SizedBox(height: 16),
              _buildTeamRow(
                match['team_b'] is Map ? (match['team_b']['name'] ?? 'Team B') : (match['team_b_name'] ?? 'Team B'),
                '${match['score'] is Map ? (match['score']['team_b_score'] ?? 0) : (match['score_b'] ?? 0)}/${match['score'] is Map ? (match['score']['team_b_wkts'] ?? 0) : (match['wickets_b'] ?? 0)}',
                '(Ov ${match['score'] is Map ? (match['score']['team_b_overs'] ?? 0) : (match['overs_b'] ?? 0)})',
                false,
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                   Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[400]),
                   const SizedBox(width: 4),
                   Text(
                     match['venue'] ?? 'Stadium Ground',
                     style: TextStyle(color: Colors.grey[500], fontSize: 12),
                   ),
                   const Spacer(),
                   const Text(
                     'View Scorecard →',
                     style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                   ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(String name, String score, String overs, bool isFirst) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Center(child: Icon(Icons.sports_cricket, size: 16, color: AppColors.primaryElectric)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              score,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF333333)),
            ),
            Text(overs, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
