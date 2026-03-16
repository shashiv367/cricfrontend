import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'umpire_dashboard_screen.dart';

class UmpireMatchDetailScreen extends StatefulWidget {
  final String matchId;

  const UmpireMatchDetailScreen({super.key, required this.matchId});

  @override
  State<UmpireMatchDetailScreen> createState() => _UmpireMatchDetailScreenState();
}

class _UmpireMatchDetailScreenState extends State<UmpireMatchDetailScreen> {
  Map<String, dynamic>? _match;
  bool _loading = true;
  bool _saving = false;
  
  // Batting/Bowling selection
  String? _battingTeamId; // null means not selected yet
  Set<String> _selectedBowlers = {}; // Set of player stat IDs who will bowl
  
  // Score Controllers
  final _teamAScoreController = TextEditingController();
  final _teamAWktsController = TextEditingController();
  final _teamAOversController = TextEditingController();
  final _teamBScoreController = TextEditingController();
  final _teamBWktsController = TextEditingController();
  final _teamBOversController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMatch();
  }

  @override
  void dispose() {
    _teamAScoreController.dispose();
    _teamAWktsController.dispose();
    _teamAOversController.dispose();
    _teamBScoreController.dispose();
    _teamBWktsController.dispose();
    _teamBOversController.dispose();
    super.dispose();
  }

  Future<void> _loadMatch() async {
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getMatchDetails(token: token, matchId: widget.matchId);
      final match = response['match'];
      
      setState(() {
        _match = match;
        final score = match['score'] as Map<String, dynamic>?;
        if (score != null) {
          _teamAScoreController.text = (score['team_a_score'] ?? 0).toString();
          _teamAWktsController.text = (score['team_a_wkts'] ?? 0).toString();
          _teamAOversController.text = (score['team_a_overs'] ?? 0.0).toString();
          _teamBScoreController.text = (score['team_b_score'] ?? 0).toString();
          _teamBWktsController.text = (score['team_b_wkts'] ?? 0).toString();
          _teamBOversController.text = (score['team_b_overs'] ?? 0.0).toString();
        }
      });
      
      // Check if overs are complete and switch teams if needed
      _checkAndSwitchTeams();
      
      // Show batting/bowling selection dialog if not selected
      if (mounted && _battingTeamId == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBattingBowlingSelectionDialog();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load match: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _areBothTeamsOversComplete() {
    if (_match == null) return false;

    final score = _match!['score'] as Map<String, dynamic>?;
    if (score == null) return false;

    final matchOvers = (_match!['overs'] as num?)?.toDouble() ?? 20.0;
    final teamAOvers = (score['team_a_overs'] as num?)?.toDouble() ?? 0.0;
    final teamBOvers = (score['team_b_overs'] as num?)?.toDouble() ?? 0.0;

    // Check if both teams have completed their overs
    return teamAOvers >= matchOvers && teamBOvers >= matchOvers;
  }

  void _checkAndSwitchTeams() {
    if (_match == null || _battingTeamId == null) return;

    final teamA = _match!['team_a'] is Map ? _match!['team_a'] : null;
    final teamB = _match!['team_b'] is Map ? _match!['team_b'] : null;
    final teamAId = teamA?['id'] as String?;
    final teamBId = teamB?['id'] as String?;
    final teamAName = teamA?['name'] ?? 'Team A';
    final teamBName = teamB?['name'] ?? 'Team B';
    final matchOvers = (_match!['overs'] as num?)?.toDouble() ?? 20.0;
    
    if (teamAId == null || teamBId == null) return;

    final score = _match!['score'] as Map<String, dynamic>?;
    if (score == null) return;

    final isTeamABatting = _battingTeamId == teamAId;
    final battingOvers = isTeamABatting 
        ? (score['team_a_overs'] as num?)?.toDouble() ?? 0.0
        : (score['team_b_overs'] as num?)?.toDouble() ?? 0.0;

    // Check if batting team has completed their overs
    if (battingOvers >= matchOvers) {
      // Switch teams
      final newBattingTeamId = isTeamABatting ? teamBId : teamAId;
      final newBattingTeamName = isTeamABatting ? teamBName : teamAName;
      final previousBattingTeamName = isTeamABatting ? teamAName : teamBName;

      setState(() {
        _battingTeamId = newBattingTeamId;
        _selectedBowlers.clear(); // Clear bowler selection for new bowling team
      });

      // Show notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$previousBattingTeamName completed their overs! $newBattingTeamName is now batting.',
            ),
            backgroundColor: AppColors.primaryBlue,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _completeMatch() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Complete Match',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to mark this match as complete? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete Match'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      await ApiService.updateMatchStatus(
        token: token,
        matchId: widget.matchId,
        status: 'completed',
      );

      if (mounted) {
        // Navigate back to umpire dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UmpireDashboardScreen()),
          (route) => false,
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match marked as complete!'),
            backgroundColor: AppColors.accentGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete match: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showBattingBowlingSelectionDialog() {
    if (_match == null) return;
    
    final teamA = _match!['team_a'] is Map ? _match!['team_a'] : null;
    final teamB = _match!['team_b'] is Map ? _match!['team_b'] : null;
    final teamAId = teamA?['id'] as String?;
    final teamBId = teamB?['id'] as String?;
    final teamAName = teamA?['name'] ?? 'Team A';
    final teamBName = teamB?['name'] ?? 'Team B';
    
    if (teamAId == null || teamBId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Select Batting & Bowling Teams',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Which team will bat first?',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _teamSelectionOption(
              teamName: teamAName,
              teamId: teamAId,
              onTap: () {
                setState(() {
                  _battingTeamId = teamAId;
                });
                Navigator.pop(context);
              },
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 12),
            _teamSelectionOption(
              teamName: teamBName,
              teamId: teamBId,
              onTap: () {
                setState(() {
                  _battingTeamId = teamBId;
                });
                Navigator.pop(context);
              },
              color: AppColors.accentRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamSelectionOption({
    required String teamName,
    required String teamId,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sports_cricket_rounded, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _updateScore() async {
    setState(() => _saving = true);
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      await ApiService.updateMatchScore(
        token: token,
        matchId: widget.matchId,
        teamAScore: int.tryParse(_teamAScoreController.text),
        teamAWkts: int.tryParse(_teamAWktsController.text),
        teamAOvers: double.tryParse(_teamAOversController.text),
        teamBScore: int.tryParse(_teamBScoreController.text),
        teamBWkts: int.tryParse(_teamBWktsController.text),
        teamBOvers: double.tryParse(_teamBOversController.text),
      );

      // Reload match data
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await ApiService.getMatchDetails(token: token, matchId: widget.matchId);
        final match = response['match'];
        
        setState(() {
          _match = match;
          final score = match['score'] as Map<String, dynamic>?;
          if (score != null) {
            _teamAScoreController.text = (score['team_a_score'] ?? 0).toString();
            _teamAWktsController.text = (score['team_a_wkts'] ?? 0).toString();
            _teamAOversController.text = (score['team_a_overs'] ?? 0.0).toString();
            _teamBScoreController.text = (score['team_b_score'] ?? 0).toString();
            _teamBWktsController.text = (score['team_b_wkts'] ?? 0).toString();
            _teamBOversController.text = (score['team_b_overs'] ?? 0.0).toString();
          }
        });
      }

      // Check and switch teams if overs are complete
      final teamA = _match!['team_a'] is Map ? _match!['team_a'] : null;
      final teamB = _match!['team_b'] is Map ? _match!['team_b'] : null;
      final teamAId = teamA?['id'] as String?;
      final teamBId = teamB?['id'] as String?;
      final teamAName = teamA?['name'] ?? 'Team A';
      final teamBName = teamB?['name'] ?? 'Team B';
      final matchOvers = (_match!['overs'] as num?)?.toDouble() ?? 20.0;
      
      if (teamAId != null && teamBId != null && _battingTeamId != null) {
        final score = _match!['score'] as Map<String, dynamic>?;
        if (score != null) {
          final isTeamABatting = _battingTeamId == teamAId;
          final battingOvers = isTeamABatting 
              ? (score['team_a_overs'] as num?)?.toDouble() ?? 0.0
              : (score['team_b_overs'] as num?)?.toDouble() ?? 0.0;

          // Check if batting team has completed their overs
          if (battingOvers >= matchOvers) {
            // Switch teams
            final newBattingTeamId = isTeamABatting ? teamBId : teamAId;
            final newBattingTeamName = isTeamABatting ? teamBName : teamAName;
            final previousBattingTeamName = isTeamABatting ? teamAName : teamBName;

            setState(() {
              _battingTeamId = newBattingTeamId;
              _selectedBowlers.clear(); // Clear bowler selection for new bowling team
            });

            // Show notification
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '$previousBattingTeamName completed their overs! $newBattingTeamName is now batting.',
                  ),
                  backgroundColor: AppColors.primaryBlue,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            // Show success message only if teams didn't switch
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Score updated successfully'),
                  backgroundColor: AppColors.accentGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score updated successfully'),
            backgroundColor: AppColors.accentGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update score: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundCard,
          elevation: 0,
          title: const Text(
            'Match Details',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    if (_match == null || _battingTeamId == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundCard,
          elevation: 0,
          title: const Text(
            'Match Details',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: const Center(
          child: Text(
            'Match not found',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final teamAId = _getDataId(_match?['team_a']);
    final teamBId = _getDataId(_match?['team_b']);
    final teamAName = _getDataName(_match?['team_a'], 'Team A');
    final teamBName = _getDataName(_match?['team_b'], 'Team B');
    final locationName = _getDataName(_match?['location'], 'Unknown');
    final overs = _match!['overs'] ?? 20;
    final status = _match!['status'] ?? 'live';
    final playerStats = List<Map<String, dynamic>>.from(_match!['playerStats'] ?? []);
    
    final statusColor = status == 'live'
        ? AppColors.accentRed
        : status == 'completed'
            ? AppColors.accentGreen
            : AppColors.textSecondary;

    // Determine batting and bowling teams
    final isTeamABatting = _battingTeamId == teamAId;
    final battingTeamId = _battingTeamId!;
    final bowlingTeamId = isTeamABatting ? teamBId : teamAId;
    final battingTeamName = isTeamABatting ? teamAName : teamBName;
    final bowlingTeamName = isTeamABatting ? teamBName : teamAName;
    final battingColor = isTeamABatting ? AppColors.primaryBlue : AppColors.accentRed;
    final bowlingColor = isTeamABatting ? AppColors.accentRed : AppColors.primaryBlue;

    // Get score controllers for batting and bowling teams
    final battingScoreController = isTeamABatting ? _teamAScoreController : _teamBScoreController;
    final battingWktsController = isTeamABatting ? _teamAWktsController : _teamBWktsController;
    final battingOversController = isTeamABatting ? _teamAOversController : _teamBOversController;

    // Filter players by team
    final battingPlayers = playerStats.where((stat) {
      final statTeamId = stat['team_id'] as String?;
      return statTeamId == battingTeamId;
    }).toList();

    final bowlingPlayers = playerStats.where((stat) {
      final statTeamId = stat['team_id'] as String?;
      return statTeamId == bowlingTeamId;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$teamAName vs $teamBName',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (locationName != null)
              Text(
                locationName,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _showBattingBowlingSelectionDialog,
            tooltip: 'Change Batting/Bowling',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMatch,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.15),
                    AppColors.backgroundCard,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.backgroundCardAlt),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sports_cricket_rounded,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: statusColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.timer_rounded, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '$overs overs',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Batting Section
            _battingBowlingSection(
              teamName: battingTeamName,
              color: battingColor,
              players: battingPlayers,
              scoreController: battingScoreController,
              wktsController: battingWktsController,
              oversController: battingOversController,
              isBatting: true,
            ),
            
            const SizedBox(height: 32),

            // Bowling Section
            _battingBowlingSection(
              teamName: bowlingTeamName,
              color: bowlingColor,
              players: bowlingPlayers,
              scoreController: TextEditingController(), // Bowling team doesn't update score here
              wktsController: TextEditingController(),
              oversController: TextEditingController(),
              isBatting: false,
            ),
            
            const SizedBox(height: 32),

            // --- COMMENTARY SECTION ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                   const Row(
                    children: [
                      Icon(Icons.comment_rounded, color: AppColors.primaryBlue),
                      SizedBox(width: 12),
                      Text('Match Commentary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('ADD BALL COMMENTARY'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showAddCommentaryDialog,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            
            // Save Button (only for batting team score)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _saving ? null : _updateScore,
                child: _saving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Save Score',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Match Complete Button (only when both teams have finished their overs and match is not already completed)
            if (_areBothTeamsOversComplete() && status != 'completed') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _saving ? null : _completeMatch,
                  child: _saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded, size: 20),
                            SizedBox(width: 12),
                            Text(
                              'Match Complete',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _battingBowlingSection({
    required String teamName,
    required Color color,
    required List<Map<String, dynamic>> players,
    required TextEditingController scoreController,
    required TextEditingController wktsController,
    required TextEditingController oversController,
    required bool isBatting,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                isBatting ? Icons.sports_cricket_rounded : Icons.sports_baseball_rounded,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isBatting ? 'BATTING' : 'BOWLING',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                teamName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Score Section (only for batting team)
        if (isBatting)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.backgroundCardAlt),
            ),
            child: _teamScoreInput(
              teamName: teamName,
              color: color,
              scoreController: scoreController,
              wktsController: wktsController,
              oversController: oversController,
            ),
          ),
        
        if (isBatting) const SizedBox(height: 16),
        
        // Players List
        if (players.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.backgroundCardAlt),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  color: AppColors.textMuted,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Players Added',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              if (!isBatting) ...[
                // Bowler Selection Header
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Select Bowlers',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              ...players.map((stat) => _playerStatCard(
                stat,
                color,
                isBatting: isBatting,
                isSelected: _selectedBowlers.contains(stat['id']?.toString()),
                onBowlerToggle: !isBatting
                    ? () {
                        setState(() {
                          final playerId = stat['id']?.toString();
                          if (playerId != null) {
                            if (_selectedBowlers.contains(playerId)) {
                              _selectedBowlers.remove(playerId);
                            } else {
                              _selectedBowlers.add(playerId);
                            }
                          }
                        });
                      }
                    : null,
              )),
            ],
          ),
      ],
    );
  }

  Widget _teamScoreInput({
    required String teamName,
    required Color color,
    required TextEditingController scoreController,
    required TextEditingController wktsController,
    required TextEditingController oversController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.scoreboard_rounded, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              'Score',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _scoreInputField(
                label: 'Runs',
                controller: scoreController,
                color: color,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _scoreInputField(
                label: 'Wickets',
                controller: wktsController,
                color: color,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _scoreInputField(
                label: 'Overs',
                controller: oversController,
                color: color,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _scoreInputField({
    required String label,
    required TextEditingController controller,
    required Color color,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundCardAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _playerStatCard(
    Map<String, dynamic> stat,
    Color teamColor, {
    required bool isBatting,
    bool isSelected = false,
    VoidCallback? onBowlerToggle,
  }) {
    final name = stat['player_name'] ?? 'Unknown';
    final runs = stat['runs'] ?? 0;
    final balls = stat['balls'] ?? 0;
    final fours = stat['fours'] ?? 0;
    final sixes = stat['sixes'] ?? 0;
    final wickets = stat['wickets'] ?? 0;
    final overs = stat['overs'] ?? 0.0;
    final strikeRate = balls > 0 ? ((runs / balls) * 100).toStringAsFixed(2) : '0.00';
    final economy = overs > 0 ? (runs / overs).toStringAsFixed(2) : '0.00';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? teamColor : teamColor.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Bowler Selection Checkbox (only for bowling team)
              if (!isBatting && onBowlerToggle != null) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onBowlerToggle(),
                  activeColor: teamColor,
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: teamColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: teamColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSelected && !isBatting)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: teamColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'BOWLER',
                              style: TextStyle(
                                color: teamColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'SR: $strikeRate',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Eco: $economy',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_rounded, color: teamColor),
                onPressed: () => _showUpdatePlayerStatsDialog(stat),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Runs', runs.toString(), Icons.sports_cricket_rounded),
              _statItem('Balls', balls.toString(), Icons.circle_outlined),
              _statItem('4s', fours.toString(), Icons.straighten_rounded),
              _statItem('6s', sixes.toString(), Icons.straighten_rounded),
              _statItem('Wkts', wickets.toString(), Icons.sports_baseball_rounded),
              _statItem('Overs', overs.toStringAsFixed(1), Icons.timer_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _showUpdatePlayerStatsDialog(Map<String, dynamic> stat) {
    final playerStatId = stat['id'] as String?;
    if (playerStatId == null) return;

    final runsController = TextEditingController(text: (stat['runs'] ?? 0).toString());
    final ballsController = TextEditingController(text: (stat['balls'] ?? 0).toString());
    final foursController = TextEditingController(text: (stat['fours'] ?? 0).toString());
    final sixesController = TextEditingController(text: (stat['sixes'] ?? 0).toString());
    final wicketsController = TextEditingController(text: (stat['wickets'] ?? 0).toString());
    final oversController = TextEditingController(text: (stat['overs'] ?? 0.0).toString());
    final name = stat['player_name'] ?? 'Unknown';
    bool updating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: Text(
            'Update Stats: $name',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogInputField('Runs', runsController, Icons.sports_cricket_rounded),
                const SizedBox(height: 12),
                _dialogInputField('Balls', ballsController, Icons.circle_outlined),
                const SizedBox(height: 12),
                _dialogInputField('Fours', foursController, Icons.straighten_rounded),
                const SizedBox(height: 12),
                _dialogInputField('Sixes', sixesController, Icons.straighten_rounded),
                const SizedBox(height: 12),
                _dialogInputField('Wickets', wicketsController, Icons.sports_baseball_rounded),
                const SizedBox(height: 12),
                _dialogInputField('Overs', oversController, Icons.timer_rounded),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: updating
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: updating
                  ? null
                  : () async {
                      setDialogState(() => updating = true);
                      try {
                        final token = await supabase.auth.currentSession?.accessToken;
                        if (token == null) return;

                        await ApiService.updatePlayerStats(
                          token: token,
                          matchId: widget.matchId,
                          playerStatId: playerStatId,
                          runs: int.tryParse(runsController.text),
                          balls: int.tryParse(ballsController.text),
                          fours: int.tryParse(foursController.text),
                          sixes: int.tryParse(sixesController.text),
                          wickets: int.tryParse(wicketsController.text),
                          overs: double.tryParse(oversController.text),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          await _loadMatch();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Player stats updated successfully'),
                              backgroundColor: AppColors.accentGreen,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => updating = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update stats: $e'),
                              backgroundColor: AppColors.accentRed,
                            ),
                          );
                        }
                      }
                    },
              child: updating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogInputField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: label == 'Overs'),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        filled: true,
        fillColor: AppColors.backgroundCardAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  String? _getDataId(dynamic data) {
    if (data is Map) return data['id']?.toString();
    if (data is List && data.isNotEmpty) {
      final first = data[0];
      if (first is Map) return first['id']?.toString();
    }
    return null;
  }

  String _getDataName(dynamic data, String fallback) {
    if (data is Map) return data['name']?.toString() ?? fallback;
    if (data is List && data.isNotEmpty) {
      final first = data[0];
      if (first is Map) return first['name']?.toString() ?? fallback;
    }
    return fallback;
  }

  void _showAddCommentaryDialog() {
    final overController = TextEditingController(text: _teamAOversController.text.split('.')[0]);
    final ballController = TextEditingController(text: '1');
    final textController = TextEditingController();
    String eventType = '0';
    int runs = 0;
    bool isWicket = false;
    bool adding = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text('Add Ball Commentary', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _dialogInputField('Over', overController, Icons.numbers)),
                    const SizedBox(width: 12),
                    Expanded(child: _dialogInputField('Ball', ballController, Icons.numbers)),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: eventType,
                  dropdownColor: AppColors.backgroundCard,
                  decoration: _inputDecoration('Event Type', Icons.event_note),
                  items: ['0', '1', '2', '3', '4', '6', 'W', 'WD', 'NB'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        eventType = val;
                        if (val == 'W') {
                          isWicket = true;
                          runs = 0;
                        } else if (int.tryParse(val) != null) {
                          runs = int.parse(val);
                          isWicket = false;
                        } else {
                          runs = 1; // Extra
                          isWicket = false;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _inputDecoration('Commentary Text', Icons.text_fields),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
              onPressed: adding ? null : () async {
                setDialogState(() => adding = true);
                try {
                  final token = await supabase.auth.currentSession?.accessToken;
                  if (token == null) return;

                  await ApiService.addCommentary(
                    token: token,
                    matchId: widget.matchId,
                    overNumber: int.parse(overController.text),
                    ballNumber: int.parse(ballController.text),
                    eventType: eventType,
                    commentaryText: textController.text,
                    runs: runs,
                    isWicket: isWicket,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    _loadMatch();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commentary added!'), backgroundColor: AppColors.accentGreen));
                  }
                } catch (e) {
                  setDialogState(() => adding = false);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.accentRed));
                }
              },
              child: adding ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add Ball'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.primaryBlue),
      filled: true,
      fillColor: AppColors.backgroundCardAlt,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
