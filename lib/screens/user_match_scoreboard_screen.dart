import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:ui';
import 'dart:math' as math;
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class UserMatchScoreboardScreen extends StatefulWidget {
  final String matchId;

  const UserMatchScoreboardScreen({super.key, required this.matchId});

  @override
  State<UserMatchScoreboardScreen> createState() => _UserMatchScoreboardScreenState();
}

class _UserMatchScoreboardScreenState extends State<UserMatchScoreboardScreen> {
  Map<String, dynamic>? _match;
  bool _loading = true;

  RealtimeChannel? _scoreChannel;

  @override
  void initState() {
    super.initState();
    _loadMatch();
    _subscribeToScore();
  }

  void _subscribeToScore() {
    _scoreChannel = supabase
        .channel('public:match_score')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'match_score',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'match_id',
            value: widget.matchId,
          ),
          callback: (payload) {
            developer.log('Real-time score update: ${payload.newRecord}');
            _loadMatch(); // Reload data when score changes
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _scoreChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMatch() async {
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getMatchScoreboard(token: token, matchId: widget.matchId);
      setState(() {
        _match = response['match'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load scoreboard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.lavenderBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentPurple),
        ),
      );
    }

    if (_match == null) {
      return Scaffold(
        backgroundColor: AppColors.lavenderBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Scoreboard', style: TextStyle(color: AppColors.textPrimary)),
        ),
        body: const Center(child: Text('Match not found')),
      );
    }

    final teamA = _match!['team_a'] is Map ? _match!['team_a']['name'] : 'Team A';
    final teamB = _match!['team_b'] is Map ? _match!['team_b']['name'] : 'Team B';
    final score = _match!['score'] is Map ? _match!['score'] : null;
    final teamAStats = List<Map<String, dynamic>>.from(_match!['team_a_stats'] ?? []);
    final teamBStats = List<Map<String, dynamic>>.from(_match!['team_b_stats'] ?? []);

    return Scaffold(
      backgroundColor: AppColors.lavenderBg,
      body: Stack(
        children: [
          // Global Wave Background for Hero
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: CustomPaint(
              painter: _WavePatternPainter(),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildInningsAppBar(teamA, teamB),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (score != null) ...[
                      _scoreCard(teamA, score, true),
                      const SizedBox(height: 16),
                      _scoreCard(teamB, score, false),
                      const SizedBox(height: 32),
                    ],
                    _buildPremiumHeader('$teamA - Batting'),
                    const SizedBox(height: 16),
                    _playerStatsTable(teamAStats),
                    const SizedBox(height: 32),
                    _buildPremiumHeader('$teamB - Batting'),
                    const SizedBox(height: 16),
                    _playerStatsTable(teamBStats),
                    const SizedBox(height: 60),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInningsAppBar(String teamA, String teamB) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.lavenderBg.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.accentPurple),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppColors.accentPurple),
          onPressed: _loadMatch,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          '$teamA v $teamB',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.normal,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        background: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentPurple.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'LIVE MATCH SCOREBOARD',
                    style: TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _scoreCard(String teamName, Map<String, dynamic> score, bool isTeamA) {
    final scoreVal = isTeamA ? (score['team_a_score'] ?? 0) : (score['team_b_score'] ?? 0);
    final wkts = isTeamA ? (score['team_a_wkts'] ?? 0) : (score['team_b_wkts'] ?? 0);
    final overs = isTeamA ? (score['team_a_overs'] ?? 0.0) : (score['team_b_overs'] ?? 0.0);
    final runRate = isTeamA ? (score['team_a_run_rate'] ?? 0.0) : (score['team_b_run_rate'] ?? 0.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (isTeamA ? AppColors.accentPurple : AppColors.accentSunset).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.sports_cricket_rounded,
                            color: isTeamA ? AppColors.accentPurple : AppColors.accentSunset,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              isTeamA ? 'FIRST INNINGS' : 'SECOND INNINGS',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$scoreVal',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.normal,
                            height: 1,
                          ),
                        ),
                        Text(
                          '/$wkts',
                          style: TextStyle(
                            color: AppColors.textPrimary.withOpacity(0.4),
                            fontSize: 28,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${overs.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'OVERS',
                              style: TextStyle(
                                color: AppColors.textSecondary.withOpacity(0.5),
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RR: ${runRate.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.accentPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _playerStatsTable(List<Map<String, dynamic>> stats) {
    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: const Center(
          child: Text(
            'NO PLAYER STATISTICS TO DISPLAY',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.normal,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.05),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5))),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: _TableHeader('PLAYER')),
                    Expanded(child: _TableHeader('RUNS')),
                    Expanded(child: _TableHeader('BALLS')),
                    Expanded(child: _TableHeader('SR')),
                    Expanded(child: _TableHeader('W')),
                  ],
                ),
              ),
              ...stats.map((stat) {
                final name = stat['player_name'] ?? 'Unknown';
                final runs = stat['runs'] ?? 0;
                final balls = stat['balls'] ?? 0;
                final strikeRate = stat['strike_rate'] ?? (balls > 0 ? ((runs / balls) * 100).toStringAsFixed(1) : '0.0');
                final wickets = stat['wickets'] ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: _TableValue('$runs', isBold: true, color: AppColors.textPrimary)),
                      Expanded(child: _TableValue('$balls')),
                      Expanded(child: _TableValue('$strikeRate', color: AppColors.accentPurple)),
                      Expanded(child: _TableValue('$wickets', isBold: true, color: AppColors.accentSunset)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String label;
  const _TableHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary.withOpacity(0.6),
        fontSize: 10,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _TableValue extends StatelessWidget {
  final String value;
  final Color? color;
  final bool isBold;
  const _TableValue(this.value, {this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color ?? AppColors.textSecondary,
        fontWeight: isBold ? FontWeight.normal : FontWeight.normal,
        fontSize: 14,
      ),
    );
  }
}

class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentPurple.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      double yOffset = i * 45.0 + 80;
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += 15) {
        double y = yOffset + 
                   (15 * (i + 1) * 0.4) * 
                   math.sin((x / size.width * 2.5 * math.pi) + (i * 1.2));
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}









