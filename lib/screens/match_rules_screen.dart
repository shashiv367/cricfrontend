import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/supabase_client.dart';
import '../services/api_service.dart';

/// Full-screen Match rules (WD, NB, WW): wagon wheel, wide/no ball rules,
/// ignore rules, Connect to LED board. Done shows Save changes confirmation.
class MatchRulesScreen extends StatefulWidget {
  final String? matchId;
  final int? currentOvers;

  const MatchRulesScreen({super.key, this.matchId, this.currentOvers});

  @override
  State<MatchRulesScreen> createState() => _MatchRulesScreenState();
}

class _MatchRulesScreenState extends State<MatchRulesScreen> {
  // Wagon wheel
  bool _wwDotBall = false;
  bool _ww1s2s3s = false;
  bool _wwThisMatch = false;
  bool _shotSelection = false;

  // Wide / no ball
  bool _countWideLegal = false;
  int _wideRuns = 1;
  bool _countNoBallLegal = false;
  int _noBallRuns = 1;

  // Ignore rules: which rules to ignore (A/B/C/D) and for which overs
  final Set<String> _ignoreRules = {};
  final TextEditingController _ignoreOversController = TextEditingController();

  @override
  void dispose() {
    _ignoreOversController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: const Text('Match rules(wd, nb, ww)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Wagon wheel'),
                  _toggleRow('Show wagon wheel for dot ball', _wwDotBall, (v) => setState(() => _wwDotBall = v)),
                  _toggleRow('Show wagon wheel for 1s, 2s, & 3s', _ww1s2s3s, (v) => setState(() => _ww1s2s3s = v)),
                  _toggleRow('Wagon wheel for this match', _wwThisMatch, (v) => setState(() => _wwThisMatch = v)),
                  _toggleRow('Shot selection', _shotSelection, (v) => setState(() => _shotSelection = v)),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      '*ww and shot selection won\'t be disabled for boundaries and wickets.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Wide/no ball rules'),
                  _toggleWithLabel('A', 'Count wide as a legal delivery', _countWideLegal, (v) => setState(() => _countWideLegal = v)),
                  _stepperRow('B', 'Wide runs', _wideRuns, (v) => setState(() => _wideRuns = v.clamp(0, 10))),
                  _toggleWithLabel('C', 'Count no ball as a legal delivery', _countNoBallLegal, (v) => setState(() => _countNoBallLegal = v)),
                  _stepperRow('D', 'No ball runs', _noBallRuns, (v) => setState(() => _noBallRuns = v.clamp(0, 10))),
                  const SizedBox(height: 24),
                  _sectionTitle('Ignore rules'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['A', 'B', 'C', 'D'].map((letter) {
                      final selected = _ignoreRules.contains(letter);
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _ignoreRules.remove(letter);
                              } else {
                                _ignoreRules.add(letter);
                              }
                            });
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: selected ? AppColors.primaryTeal : Colors.grey[200],
                            child: Text(
                              letter,
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('For overs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _ignoreOversController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '-',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.divider)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connect to LED board – coming soon')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Connect to LED board', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))]),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _wwDotBall = _ww1s2s3s = _wwThisMatch = _shotSelection = false;
                        _countWideLegal = _countNoBallLegal = false;
                        _wideRuns = _noBallRuns = 1;
                        _ignoreRules.clear();
                        _ignoreOversController.clear();
                      });
                    },
                    child: const Text('Reset', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _onDone,
                    child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primaryTeal),
        ],
      ),
    );
  }

  Widget _toggleWithLabel(String letter, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: AppColors.backgroundLight, child: Text(letter, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primaryTeal),
        ],
      ),
    );
  }

  Widget _stepperRow(String letter, String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: AppColors.backgroundLight, child: Text(letter, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                onPressed: () => onChanged(value - 1),
                color: AppColors.primaryTeal,
              ),
              SizedBox(width: 28, child: Center(child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)))),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 22),
                onPressed: () => onChanged(value + 1),
                color: AppColors.primaryTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onDone() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('Save changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Are you sure you want to apply the new match settings?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        final matchId = widget.matchId;
        final session = supabase.auth.currentSession;
        final token = session?.accessToken;
        if (matchId != null && token != null) {
          try {
            await ApiService.updateMatchConfig(
              token: token,
              matchId: matchId,
              wwDotBall: _wwDotBall,
              ww1s2s3s: _ww1s2s3s,
              wwForMatch: _wwThisMatch,
              wwShotSelection: _shotSelection,
              wideLegal: _countWideLegal,
              wideRuns: _wideRuns,
              noballLegal: _countNoBallLegal,
              noballRuns: _noBallRuns,
              ignoreRules: _ignoreRules.isEmpty ? null : _ignoreRules.join(','),
              ignoreOvers: _ignoreOversController.text.trim().isEmpty ? null : _ignoreOversController.text.trim(),
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Match settings saved'), backgroundColor: AppColors.accentGreen),
              );
            }
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to save match settings'), backgroundColor: AppColors.accentRed),
              );
            }
          }
        }
        if (mounted) Navigator.of(context).pop();
      }
    });
  }
}
