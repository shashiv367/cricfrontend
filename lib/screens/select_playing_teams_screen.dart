import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'select_team_screen.dart';
import 'select_squad_screen.dart';
import '../services/supabase_client.dart';

class SelectPlayingTeamsScreen extends StatefulWidget {
  const SelectPlayingTeamsScreen({super.key});

  @override
  State<SelectPlayingTeamsScreen> createState() => _SelectPlayingTeamsScreenState();
}

class _SelectPlayingTeamsScreenState extends State<SelectPlayingTeamsScreen> {
  String? _teamAName;
  String? _teamBName;
  String? _teamAId;
  String? _teamBId;
  SquadSelectionResult? _teamASquad;
  SquadSelectionResult? _teamBSquad;
  bool _teamAAddMyself = false;
  bool _teamBAddMyself = false;

  Set<String> _normalizedPlayerSet(List<String> players) {
    return players.map((p) => p.trim().toLowerCase()).where((p) => p.isNotEmpty).toSet();
  }

  bool get _isLoggedIn => supabase.auth.currentUser != null && supabase.auth.currentSession?.accessToken != null;

  Future<bool> _showLoginRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Login Required',
          style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        ),
        content: const Text(
          'You need to login to start a match and manage scores',
          style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryElectric,
              foregroundColor: Colors.white,
            ),
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<bool> _requireLogin() async {
    if (_isLoggedIn) return true;
    final shouldLogin = await _showLoginRequiredDialog();
    if (!mounted) return false;
    if (shouldLogin) {
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Guard this route in case it was opened without auth.
      _requireLogin();
    });
  }

  Future<void> _selectTeam(bool isTeamA) async {
    if (!await _requireLogin()) return;

    final selected = await Navigator.push<TeamSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectTeamScreen(
          title: 'Select team ${isTeamA ? 'a' : 'b'}',
          currentSelection: isTeamA ? _teamAName : _teamBName,
        ),
      ),
    );
    if (selected == null || !mounted) return;

    // Prevent same team name on both sides (case/space-insensitive).
    final picked = selected.teamName.trim().toLowerCase();
    final other = (isTeamA ? _teamBName : _teamAName)?.trim().toLowerCase();
    if (other != null && other.isNotEmpty && picked == other) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Team A and Team B cannot be the same team'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // After selecting a team, go to squad selection & role assignment
    final blocked = isTeamA
        ? (_teamBSquad?.players.toSet() ?? <String>{})
        : (_teamASquad?.players.toSet() ?? <String>{});

    final squad = await Navigator.push<SquadSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectSquadScreen(
          teamName: selected.teamName,
          teamId: selected.teamId,
          addMyself: selected.addMyself,
          blockedPlayers: blocked,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      if (isTeamA) {
        _teamAName = selected.teamName;
        _teamAId = selected.teamId;
        _teamASquad = squad;
        _teamAAddMyself = selected.addMyself;
      } else {
        _teamBName = selected.teamName;
        _teamBId = selected.teamId;
        _teamBSquad = squad;
        _teamBAddMyself = selected.addMyself;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Select playing teams', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Scoring a match on CricHeroes is free.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _buildTeamBlock(isTeamA: true),
              const SizedBox(height: 24),
              _buildVsDivider(),
              const SizedBox(height: 24),
              _buildTeamBlock(isTeamA: false),
              if (_teamAName != null && _teamBName != null) ...[
                const SizedBox(height: 32),
                Material(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: _handleContinueToMatch,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Text('Continue to match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamBlock({required bool isTeamA}) {
    final name = isTeamA ? _teamAName : _teamBName;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _selectTeam(isTeamA),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: AppColors.primaryTeal,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => _selectTeam(isTeamA),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              child: Text(
                name != null ? name : 'Select team ${isTeamA ? 'a' : 'b'}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVsDivider() {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(52, 52),
            painter: _DiamondVsPainter(),
          ),
          Text('vs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _handleContinueToMatch() {
    _handleContinueToMatchAsync();
  }

  Future<void> _handleContinueToMatchAsync() async {
    if (!await _requireLogin()) return;

    // Require at least two players in each squad before proceeding,
    // similar to CricHeroes UX.
    if (_teamASquad == null || (_teamASquad!.players.length) < 2) {
      if (!mounted) return;
      final name = _teamAName ?? 'Team A';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select minimum two-player-squad in team $name'),
        ),
      );
      return;
    }

    if (_teamBSquad == null || (_teamBSquad!.players.length) < 2) {
      if (!mounted) return;
      final name = _teamBName ?? 'Team B';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select minimum two-player-squad in team $name'),
        ),
      );
      return;
    }

    final a = _normalizedPlayerSet(_teamASquad!.players);
    final b = _normalizedPlayerSet(_teamBSquad!.players);
    final dup = a.intersection(b);
    if (dup.isNotEmpty) {
      final sample = dup.take(3).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Same player cannot be in both teams: $sample'),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/create-match',
      arguments: {
        'teamA': _teamAName,
        'teamB': _teamBName,
        'teamASquad': _teamASquad,
        'teamBSquad': _teamBSquad,
      },
    );
  }
}

class _DiamondVsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(center.dx, center.dy - 24)
      ..lineTo(center.dx + 24, center.dy)
      ..lineTo(center.dx, center.dy + 24)
      ..lineTo(center.dx - 24, center.dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
