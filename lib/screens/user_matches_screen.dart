import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/match_card.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'user_match_scoreboard_screen.dart';

class UserMatchesScreen extends StatefulWidget {
  const UserMatchesScreen({super.key});

  @override
  State<UserMatchesScreen> createState() => _UserMatchesScreenState();
}

class _UserMatchesScreenState extends State<UserMatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listMatches(
        token: token,
        status: _filterStatus == 'all' ? null : _filterStatus,
      );
      setState(() {
        _matches = List<Map<String, dynamic>>.from(response['matches'] ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load matches: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _filterChip('All', 'all', _filterStatus == 'all'),
                const SizedBox(width: 8),
                _filterChip('Live', 'live', _filterStatus == 'live'),
                const SizedBox(width: 8),
                _filterChip('Completed', 'completed', _filterStatus == 'completed'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _matches.isEmpty
                    ? Center(
                        child: Text(
                          'No matches found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMatches,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _matches.length,
                          itemBuilder: (context, index) {
                            final match = _matches[index];
                            final teamA = match['team_a'] is Map ? (match['team_a']['name'] ?? 'Team A') : (match['team_a_name'] ?? 'Team A');
                            final teamB = match['team_b'] is Map ? (match['team_b']['name'] ?? 'Team B') : (match['team_b_name'] ?? 'Team B');
                            final status = match['status'] ?? 'live';
                            final location = match['location'] is Map ? match['location']['name'] : null;
                            final score = match['score'] is Map ? match['score'] : (match['score'] is List && (match['score'] as List).isNotEmpty ? match['score'][0] : null);

                            final score1 = score?['team_a_score'] ?? 0;
                            final score2 = score?['team_b_score'] ?? 0;
                            final overs1 = score?['team_a_overs'] ?? 0.0;
                            final overs2 = score?['team_b_overs'] ?? 0.0;
                            final wkts1 = score?['team_a_wkts'] ?? 0;
                            final wkts2 = score?['team_b_wkts'] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: MatchCard(
                                team1: teamA,
                                team2: teamB,
                                score1: score1,
                                score2: score2,
                                isLive: status == 'live',
                                overs1: overs1.toStringAsFixed(1),
                                overs2: overs2.toStringAsFixed(1),
                                matchStatus: location != null ? '📍 $location' : 'Match',
                                subtitle: status == 'live'
                                    ? '$teamA ${score1}/${wkts1} ($overs1 ov) vs $teamB ${score2}/${wkts2} ($overs2 ov)'
                                    : 'Match ${status}',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserMatchScoreboardScreen(matchId: match['id'].toString()),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
        _loadMatches();
      },
    );
  }
}









