import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/supabase_client.dart';
import '../utils/app_colors.dart';
import 'select_innings_player_screen.dart';

class MatchScoringScreen extends StatefulWidget {
  final String matchId;
  final String matchTitle;
  final String battingSide; // 'A' or 'B'
  final String? strikerName;
  final String? nonStrikerName;
  final String? bowlerName;
  final String? battingTeamName;
  final String? bowlingTeamName;
  final List<String>? battingSquad;
  final List<String>? bowlingSquad;

  const MatchScoringScreen({
    super.key,
    required this.matchId,
    required this.matchTitle,
    required this.battingSide,
    this.strikerName,
    this.nonStrikerName,
    this.bowlerName,
    this.battingTeamName,
    this.bowlingTeamName,
    this.battingSquad,
    this.bowlingSquad,
  });

  @override
  State<MatchScoringScreen> createState() => _MatchScoringScreenState();
}

class _MatchScoringScreenState extends State<MatchScoringScreen> {
  int _runs = 0;
  int _wkts = 0;
  int _balls = 0; // 0..5 within current over
  int _overs = 0;
  bool _inningsComplete = false;
  late String _battingSideLocal; // mutable so we can swap after innings complete
  late String _battingTeamNameLocal;
  late String _bowlingTeamNameLocal;

  final List<_ScoreState> _history = [];
  Timer? _pushDebounce;
  bool _pushing = false;

  late String _striker;
  late String _nonStriker;
  late String _bowler;
  late List<String> _battingSquadLocal;
  late List<String> _bowlingSquadLocal;

  bool _shortcutsExpanded = false;

  @override
  void initState() {
    super.initState();
    _battingSideLocal = widget.battingSide.toUpperCase();
    _battingTeamNameLocal = widget.battingTeamName ?? 'Batting team';
    _bowlingTeamNameLocal = widget.bowlingTeamName ?? 'Bowling team';
    _striker = (widget.strikerName ?? 'Hehe').trim().isEmpty ? 'Hehe' : widget.strikerName!.trim();
    _nonStriker = (widget.nonStrikerName ?? 'Broo').trim().isEmpty ? 'Broo' : widget.nonStrikerName!.trim();
    _bowler = (widget.bowlerName ?? 'Bowler').trim().isEmpty ? 'Bowler' : widget.bowlerName!.trim();

    // Prefer passed-in squads; otherwise fall back to the currently known players.
    final defaultBattingSquad = <String>{};
    if (widget.strikerName != null && widget.strikerName!.trim().isNotEmpty) defaultBattingSquad.add(widget.strikerName!.trim());
    if (widget.nonStrikerName != null && widget.nonStrikerName!.trim().isNotEmpty) defaultBattingSquad.add(widget.nonStrikerName!.trim());

    final defaultBowlingSquad = <String>{};
    if (widget.bowlerName != null && widget.bowlerName!.trim().isNotEmpty) defaultBowlingSquad.add(widget.bowlerName!.trim());

    _battingSquadLocal = widget.battingSquad != null && widget.battingSquad!.isNotEmpty
        ? List<String>.from(widget.battingSquad!)
        : defaultBattingSquad.toList();

    _bowlingSquadLocal = widget.bowlingSquad != null && widget.bowlingSquad!.isNotEmpty
        ? List<String>.from(widget.bowlingSquad!)
        : defaultBowlingSquad.toList();

    if (_battingSquadLocal.isEmpty) _battingSquadLocal = [_striker, _nonStriker];
    if (_bowlingSquadLocal.isEmpty) _bowlingSquadLocal = [_bowler];

    _history.add(_ScoreState(_runs, _wkts, _overs, _balls));
  }

  @override
  void dispose() {
    _pushDebounce?.cancel();
    super.dispose();
  }

  String get _overText => '($_overs/6)';

  double get _oversAsDouble => _overs + (_balls / 6.0);

  String get _ballsText => '($_balls/6)';

  String get _oversPretty => '$_overs.${_balls.clamp(0, 5)}';

  void _recordHistory() {
    _history.add(_ScoreState(_runs, _wkts, _overs, _balls));
    if (_history.length > 200) _history.removeAt(0);
  }

  void _schedulePush() {
    _pushDebounce?.cancel();
    _pushDebounce = Timer(const Duration(milliseconds: 400), _pushScoreToBackend);
  }

  Future<void> _pushScoreToBackend() async {
    if (_pushing) return;
    final session = supabase.auth.currentSession;
    final token = session?.accessToken;
    if (token == null) return;

    _pushing = true;
    try {
      final isA = _battingSideLocal == 'A';
      await ApiService.updateMatchScore(
        token: token,
        matchId: widget.matchId,
        teamAScore: isA ? _runs : null,
        teamAWkts: isA ? _wkts : null,
        teamAOvers: isA ? _oversAsDouble : null,
        teamBScore: !isA ? _runs : null,
        teamBWkts: !isA ? _wkts : null,
        teamBOvers: !isA ? _oversAsDouble : null,
      );
    } catch (e) {
      developer.log('Failed to push score: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update score: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _pushing = false;
    }
  }

  void _addRuns(int r, {bool countsBall = true}) {
    if (_inningsComplete) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Innings complete. Next innings not started yet.')),
        );
      }
      return;
    }
    bool completedOver = false;
    setState(() {
      _recordHistory();
      _runs += r;
      if (countsBall) {
        // If current ball index is 5, then the increment completes the over.
        if (_balls == 5) completedOver = true;
        _balls += 1;
        if (_balls >= 6) {
          _balls = 0;
          _overs += 1;
        }
      }
    });
    _schedulePush();

    // After each completed over, prompt for the next bowler.
    if (completedOver && _wkts < 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _replacePlayer(false, false);
      });
    }
  }

  void _undo() {
    setState(() {
      if (_history.length <= 1) return;
      _history.removeLast();
      final prev = _history.last;
      _runs = prev.runs;
      _wkts = prev.wkts;
      _overs = prev.overs;
      _balls = prev.balls;
    });
    _schedulePush();
  }

  void _out() {
    if (_inningsComplete) return;
    bool completedOver = false;
    bool hitAllOut = false;
    setState(() {
      _recordHistory();
      _wkts = (_wkts + 1).clamp(0, 10);
      // Wicket counts as a ball in this keypad UI.
      if (_balls == 5) completedOver = true;
      _balls += 1;
      if (_balls >= 6) {
        _balls = 0;
        _overs += 1;
      }

      if (_wkts >= 10) {
        _inningsComplete = true;
        hitAllOut = true;
      }
    });
    _schedulePush();

    // After wicket, prompt for the new batter.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _afterOut(completedOver: completedOver);
    });

    if (hitAllOut && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startNextInnings();
      });
    }
  }

  Future<void> _startNextInnings() async {
    // Swap batting/bowling teams and squads (batters become fielders, fielders become batters).
    final nextBattingSquad = List<String>.from(_bowlingSquadLocal);
    final nextBowlingSquad = List<String>.from(_battingSquadLocal);
    final tmpName = _battingTeamNameLocal;
    final tmpSide = _battingSideLocal;

    setState(() {
      _battingSquadLocal = nextBattingSquad;
      _bowlingSquadLocal = nextBowlingSquad;
      _battingTeamNameLocal = _bowlingTeamNameLocal;
      _bowlingTeamNameLocal = tmpName;
      _battingSideLocal = tmpSide == 'A' ? 'B' : 'A';

      // Reset innings stats for new innings.
      _runs = 0;
      _wkts = 0;
      _overs = 0;
      _balls = 0;
      _inningsComplete = false;

      _history.clear();
      _history.add(_ScoreState(_runs, _wkts, _overs, _balls));

      // Pick default players from swapped squads.
      if (_battingSquadLocal.isNotEmpty) {
        _striker = _battingSquadLocal[0];
        _nonStriker = _battingSquadLocal.length > 1 ? _battingSquadLocal[1] : _battingSquadLocal[0];
      }
      if (_bowlingSquadLocal.isNotEmpty) {
        _bowler = _bowlingSquadLocal[0];
      }
    });

    // Update backend for the new batting side with 0/0/0.
    await _pushScoreToBackend();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Next innings started: ${_battingTeamNameLocal} batting')),
    );
  }

  Future<void> _afterOut({required bool completedOver}) async {
    if (_wkts < 10) {
      await _replacePlayer(true, true);
    }
    if (completedOver && _wkts < 10) {
      await _replacePlayer(false, false);
    }
  }

  Future<void> _replacePlayer(bool isBatter, bool isStriker) async {
    if (!mounted) return;

    final Set<String> exclude = <String>{};
    final String teamName;
    final String roleLabel;
    final List<String> squad;

    if (!isBatter) {
      teamName = _bowlingTeamNameLocal;
      roleLabel = 'Bowler';
      squad = _bowlingSquadLocal;
      exclude.add(_bowler);
    } else if (isStriker) {
      teamName = _battingTeamNameLocal;
      roleLabel = 'Striker';
      squad = _battingSquadLocal;
      exclude.add(_striker);
      exclude.add(_nonStriker);
    } else {
      teamName = _battingTeamNameLocal;
      roleLabel = 'Non-striker';
      squad = _battingSquadLocal;
      exclude.add(_striker);
      exclude.add(_nonStriker);
    }

    final picked = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectInningsPlayerScreen(
          teamName: teamName,
          squad: squad,
          roleLabel: roleLabel,
          exclude: exclude,
        ),
      ),
    );

    if (!mounted || picked == null) return;

    setState(() {
      if (!isBatter) {
        if (!_bowlingSquadLocal.contains(picked)) _bowlingSquadLocal.add(picked);
        _bowler = picked;
      } else if (isStriker) {
        if (!_battingSquadLocal.contains(picked)) _battingSquadLocal.add(picked);
        _striker = picked;
      } else {
        if (!_battingSquadLocal.contains(picked)) _battingSquadLocal.add(picked);
        _nonStriker = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.matchTitle, style: const TextStyle(fontWeight: FontWeight.normal)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: Column(
        children: [
          _header(),
          _playersBar(),
          _wagonWheelStrip(),
          _keypad(),
          _shortcutsHandle(),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF1B1B1B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_runs/$_wkts',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _oversPretty,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _ballsText,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Won the toss and elected to field',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playersBar() {
    return Container(
      color: const Color(0xFF1F1F1F),
      child: Row(
        children: [
          Expanded(
            child: _playerTile(
              icon: Icons.sports_cricket,
              name: _striker,
              onReplace: () => _replacePlayer(true, true),
            ),
          ),
          Expanded(
            child: _playerTile(
              icon: Icons.sports_cricket_outlined,
              name: _nonStriker,
              onReplace: () => _replacePlayer(true, false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerTile({required IconData icon, required String name, required VoidCallback onReplace}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryTeal),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                GestureDetector(
                  onTap: onReplace,
                  child: const Text('Replace', style: TextStyle(color: AppColors.primaryTeal, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wagonWheelStrip() {
    return Container(
      color: const Color(0xFF2A2A2A),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.circle_outlined, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _bowler,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
            ),
          ),
          const Text('0-0-0-0', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _keypad() {
    final cellStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        );

    Widget btn(String label, {VoidCallback? onTap, Color? color, Color? textColor}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            label,
            style: cellStyle?.copyWith(color: textColor ?? Colors.black87),
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: btn('0', onTap: () => _addRuns(0))),
                              Expanded(child: btn('1', onTap: () => _addRuns(1))),
                              Expanded(child: btn('2', onTap: () => _addRuns(2))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: btn('3', onTap: () => _addRuns(3))),
                              Expanded(child: btn('4\nFour', onTap: () => _addRuns(4))),
                              Expanded(child: btn('6\nSix', onTap: () => _addRuns(6))),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: btn('WIDE', onTap: () => _addRuns(1, countsBall: false))),
                              Expanded(child: btn('NO\nBALL', onTap: () => _addRuns(1, countsBall: false))),
                              Expanded(child: btn('BYE', onTap: () => _addRuns(1))),
                              Expanded(child: btn('LB', onTap: () => _addRuns(1))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(child: btn('UNDO', onTap: _undo, textColor: AppColors.primaryTeal)),
                        Expanded(
                          child: btn(
                            'LBW',
                            onTap: () {
                              // LBW is a wicket on a legal delivery (counts as a ball).
                              _out();
                            },
                            textColor: Colors.black87,
                          ),
                        ),
                        Expanded(child: btn('OUT', onTap: _out, textColor: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutsHandle() {
    return Material(
      color: const Color(0xFF8E8E8E),
      child: InkWell(
        onTap: () => setState(() => _shortcutsExpanded = !_shortcutsExpanded),
        child: Container(
          height: _shortcutsExpanded ? 160 : 44,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Scoring shortcuts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
                  const SizedBox(width: 6),
                  Icon(_shortcutsExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: Colors.white),
                ],
              ),
              if (_shortcutsExpanded) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _chip('Over the wicket'),
                    _chip('Between the wicket'),
                    _chip('Round the wicket'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12)),
    );
  }
}

class _ScoreState {
  final int runs;
  final int wkts;
  final int overs;
  final int balls;

  const _ScoreState(this.runs, this.wkts, this.overs, this.balls);
}

