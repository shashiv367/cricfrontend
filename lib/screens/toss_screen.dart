import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../services/supabase_client.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

class TossScreen extends StatefulWidget {
  const TossScreen({super.key});

  @override
  State<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> {
  String? _matchId;
  String? _teamA;
  String? _teamB;
  List<String>? _teamASquad;
  List<String>? _teamBSquad;

  String? _tossWinner; // 'A' or 'B'
  String? _decision; // 'Bat' or 'Bowl'
  bool _coinFlipped = false;
  bool _isHeads = true;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _matchId ??= args?['matchId'] as String?;
    _teamA ??= args?['teamA'] as String? ?? 'Team A';
    _teamB ??= args?['teamB'] as String? ?? 'Team B';
    _teamASquad ??= (args?['teamASquad'] as List?)?.cast<String>();
    _teamBSquad ??= (args?['teamBSquad'] as List?)?.cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    final teamA = _teamA ?? 'Team A';
    final teamB = _teamB ?? 'Team B';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: const Text('Toss'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Who won the toss?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _teamTossCard(teamA, true)),
                  const SizedBox(width: 12),
                  Expanded(child: _teamTossCard(teamB, false)),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Winner of the toss elected to?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _decisionCard('Bat')),
                  const SizedBox(width: 12),
                  Expanded(child: _decisionCard('Bowl')),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _coinFlipped ? (_isHeads ? "It's heads!" : "It's tails!") : 'Tap the coin to flip',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _flipCoin,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Colors.white70, Colors.grey],
                        center: Alignment(-0.3, -0.4),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isHeads ? 'HEADS' : 'TAILS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Need help?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (_tossWinner == null || _decision == null || _matchId == null || _saving)
                          ? null
                          : _saveTossAndStartMatch,
                      child: const Text(
                        "Let's play",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamTossCard(String name, bool isA) {
    final bool selected = _tossWinner == (isA ? 'A' : 'B');
    return GestureDetector(
      onTap: () {
        setState(() {
          _tossWinner = isA ? 'A' : 'B';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryTeal : AppColors.divider,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected ? AppColors.primaryTeal : AppColors.primaryElectric,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decisionCard(String label) {
    final bool selected = _decision == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _decision = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryTeal : AppColors.divider,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primaryTeal : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _flipCoin() {
    setState(() {
      _coinFlipped = true;
      _isHeads = !_isHeads;
    });
  }

  Future<void> _saveTossAndStartMatch() async {
    if (_matchId == null || _tossWinner == null || _decision == null) return;
    try {
      setState(() {
        _saving = true;
      });

      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in again to continue.')),
          );
        }
        return;
      }

      await ApiService.updateMatchToss(
        token: token,
        matchId: _matchId!,
        tossWinnerSide: _tossWinner!,
        tossDecision: _decision!,
      );

      if (!mounted) return;

      developer.log('✅ Toss saved for match $_matchId: winner=$_tossWinner, decision=$_decision');

      // Work out which side bats first based on toss
      final winnerSide = _tossWinner!; // 'A' or 'B'
      final decision = _decision!; // 'Bat' or 'Bowl'
      final bool isTeamABattingFirst =
          (winnerSide == 'A' && decision == 'Bat') || (winnerSide == 'B' && decision == 'Bowl') ? true : false;

      Navigator.pushReplacementNamed(
        context,
        '/start-innings',
        arguments: {
          'matchId': _matchId,
          'teamA': _teamA,
          'teamB': _teamB,
          'teamASquad': _teamASquad,
          'teamBSquad': _teamBSquad,
          'battingSide': isTeamABattingFirst ? 'A' : 'B',
          'bowlingSide': isTeamABattingFirst ? 'B' : 'A',
        },
      );
    } catch (e) {
      developer.log('❌ Failed to save toss: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save toss: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}

