import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'match_rules_screen.dart';
import 'change_playing_squad_screen.dart';
import 'dart:developer' as developer;

class LiveDetailScreen extends StatefulWidget {
  final String? matchIdFromArgs;
  const LiveDetailScreen({super.key, this.matchIdFromArgs});

  @override
  State<LiveDetailScreen> createState() => _LiveDetailScreenState();
}

class _LiveDetailScreenState extends State<LiveDetailScreen> {
  int _expandedInnings = 1; // 0 for first, 1 for second, -1 for none
  Map<String, dynamic>? _match;
  bool _loading = true;
  String? _matchId;
  int _initialTabIndex = 1; // Default to LIVE tab
  int? _selectedBallIndex; // For over timeline selection
  String? _initialStrikerName;
  String? _initialNonStrikerName;
  String? _initialBowlerName;

  Timer? _pollTimer;

  // Current on-field selections (for updating playerStats + wicket handling).
  String? _battingTeamId;
  String? _fieldingTeamId;
  String? _strikerPlayerStatId;
  String? _nonStrikerPlayerStatId;
  String? _bowlerPlayerStatId;

  String? _lastBattingTeamId;
  bool _isModalOpen = false;

  @override
  void initState() {
    super.initState();
    // Poll so the LIVE page updates in real-time even if scoring is done elsewhere.
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      if (_matchId == null) return;
      // Avoid interrupting an in-progress load (non-silent).
      if (_loading) return;
      // Avoid UI crashes while a dialog/bottom sheet is open.
      if (_isModalOpen) return;
      // Only refresh while match is not completed.
      final status = _match?['status']?.toString().toLowerCase() ?? '';
      if (status.contains('completed') || status.contains('finished')) return;
      await _loadMatchDetails(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_matchId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _matchId = widget.matchIdFromArgs ?? args?['matchId'];
      final initialTab = args?['initialTabIndex'];
      if (initialTab is int) {
        _initialTabIndex = initialTab.clamp(0, 6);
      } else if (initialTab is String) {
        _initialTabIndex = int.tryParse(initialTab)?.clamp(0, 6) ?? 1;
      }

      _initialStrikerName ??= args?['initialStrikerName'] as String?;
      _initialNonStrikerName ??= args?['initialNonStrikerName'] as String?;
      _initialBowlerName ??= args?['initialBowlerName'] as String?;
      
      if (_matchId != null) {
        _loadMatchDetails();
      } else {
        setState(() => _loading = false);
      }
    }
  }

  void _showMatchSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _matchSettingsSection(ctx),
                  const SizedBox(height: 12),
                  _playersSettingsSection(ctx),
                  const SizedBox(height: 12),
                  _scorerSettingsSection(ctx),
                  const SizedBox(height: 12),
                  _settingsGroup('Other Options', [
                    'Scoring help',
                  ]),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Help/FAQs',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Show',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.phone_in_talk_outlined, color: AppColors.accentRed),
                      SizedBox(width: 8),
                      Text(
                        '+91 8141665555',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _matchSettingsSection(BuildContext sheetContext) {
    final teamA = _getTeamName(_match?['team_a'] ?? _match?['team_a_details'], 'Team A');
    final teamB = _getTeamName(_match?['team_b'] ?? _match?['team_b_details'], 'Team B');

    void closeAnd(VoidCallback action) {
      Navigator.of(sheetContext).pop();
      action();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Match Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Icon(Icons.keyboard_arrow_up, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        _settingsItem('Edit scorecard', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit scorecard – coming soon'))))),
        _settingsItem('Change match overs', () => closeAnd(_showChangeMatchOversDialog)),
        _settingsItem('Match rules (WD, NB, WW)', () => closeAnd(() => _openMatchRulesScreen())),
        _settingsItem('Revise target (DLS/VJD)', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revise target (DLS/VJD) – coming soon'))))),
        _settingsItem('Add bonus runs', () => closeAnd(() => _showBonusRunsDialog(teamA, teamB))),
        _settingsItem('Give penalty runs', () => closeAnd(() => _showPenaltyRunsDialog(teamA, teamB))),
        _settingsItem('End / declare innings', () => closeAnd(_showEndInningsDialog)),
        _settingsItem('End match', () => closeAnd(_endMatchOnServer)),
      ],
    );
  }

  Widget _settingsItem(String label, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4), alignment: Alignment.centerLeft),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
    );
  }

  Widget _playersSettingsSection(BuildContext sheetContext) {
    final teamA = _getTeamName(_match?['team_a'] ?? _match?['team_a_details'], 'Team A');
    final teamB = _getTeamName(_match?['team_b'] ?? _match?['team_b_details'], 'Team B');
    void closeAnd(VoidCallback action) {
      Navigator.of(sheetContext).pop();
      action();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Players Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Icon(Icons.keyboard_arrow_up, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        _settingsItem('Change playing squad', () => closeAnd(() => _openChangePlayingSquadScreen(teamA, teamB))),
        _settingsItem('Change bowler', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change bowler – coming soon'))))),
        _settingsItem('Replace batters', () => closeAnd(_showReplaceBattersDialog)),
        _settingsItem('Retired hurt (batter)', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retired hurt – coming soon'))))),
      ],
    );
  }

  Widget _scorerSettingsSection(BuildContext sheetContext) {
    void closeAnd(VoidCallback action) {
      Navigator.of(sheetContext).pop();
      action();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Scorer Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Icon(Icons.keyboard_arrow_up, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        _settingsItem('Change scorer', () => closeAnd(_showChangeScorerSheet)),
        _settingsItem('Add match officials/streamer', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add match officials – coming soon'))))),
        _settingsItem('Select power play overs', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select power play – coming soon'))))),
        _settingsItem('Set match breaks (lunch, drinks, etc.)', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Set match breaks – coming soon'))))),
        _settingsItem('Add scorer notes', () => closeAnd(() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add scorer notes – coming soon'))))),
      ],
    );
  }

  void _openChangePlayingSquadScreen(String teamA, String teamB) {
    final playerStats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    final squadA = playerStats.where((p) => p['team_id'] == _match?['team_a']?['id']).map((p) => p['player_name']?.toString() ?? 'Unknown').toSet().toList();
    final squadB = playerStats.where((p) => p['team_id'] == _match?['team_b']?['id']).map((p) => p['player_name']?.toString() ?? 'Unknown').toSet().toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangePlayingSquadScreen(
          matchId: _matchId,
          teamAName: teamA,
          teamBName: teamB,
          teamASquad: squadA.isEmpty ? null : squadA,
          teamBSquad: squadB.isEmpty ? null : squadB,
        ),
      ),
    );
  }

  void _showReplaceBattersDialog() {
    _showReplaceBattersDialogInternal();
  }

  Future<void> _showReplaceBattersDialogInternal({String? preselectName}) async {
    if (!mounted) return;
    final batters = _getCurrentBatterNames();
    if (batters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No batters to replace')),
      );
      return;
    }

    final wasModalOpen = _isModalOpen;
    _isModalOpen = true;
    try {
      String? selected = preselectName;
      final picked = await showDialog<String?>(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            title: const Text(
              'Whom do you want to change?',
              style: TextStyle(
                color: AppColors.accentRed,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: batters.take(2).map((name) {
                final isSelected = selected == name;
                return GestureDetector(
                  onTap: () => setDialogState(() => selected = name),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: isSelected
                            ? AppColors.primaryTeal.withOpacity(0.2)
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.sports_cricket,
                          size: 36,
                          color: isSelected
                              ? AppColors.primaryTeal
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(selected);
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
      );

      if (!mounted || picked == null) return;
      // Give Flutter a moment to finish deactivating the previous dialog route.
      // This prevents some rare Navigator/widget-tree assertions when showing
      // a 2nd dialog immediately after closing the first.
      await Future<void>.delayed(Duration.zero);

      final strikerName = _findPlayerStatById(_strikerPlayerStatId)?['player_name']?.toString();
      final nonStrikerName = _findPlayerStatById(_nonStrikerPlayerStatId)?['player_name']?.toString();

      final replacingStriker = strikerName != null && picked == strikerName;
      final replacingNonStriker = nonStrikerName != null && picked == nonStrikerName;

      // If we can't match selection to striker/non-striker, default to striker.
      final replaceStriker = replacingStriker || (!replacingStriker && !replacingNonStriker);

      if (_battingTeamId == null) return;

      if (replaceStriker && _strikerPlayerStatId == null) return;
      if (!replaceStriker && _nonStrikerPlayerStatId == null) return;

      final pickedNew = await _pickPlayerStatIdDialog(
        title: 'Select new batter',
        teamId: _battingTeamId!,
        initialId: null,
        excludeId: replaceStriker ? _strikerPlayerStatId : _nonStrikerPlayerStatId,
        excludeId2: replaceStriker ? _nonStrikerPlayerStatId : _strikerPlayerStatId,
      );

      if (!mounted || pickedNew == null) return;

      setState(() {
        if (replaceStriker) {
          _strikerPlayerStatId = pickedNew;
        } else {
          _nonStrikerPlayerStatId = pickedNew;
        }
      });
    } finally {
      if (!wasModalOpen) {
        _isModalOpen = false;
      }
    }
  }

  List<String> _getCurrentBatterNames() {
    final playerStats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    final batters = playerStats.where((p) => (p['balls'] ?? 0) > 0).map((p) => p['player_name']?.toString() ?? 'Unknown').toList();
    if (batters.length >= 2) return batters.take(2).toList();
    if (_initialStrikerName != null || _initialNonStrikerName != null) {
      return [if (_initialStrikerName != null) _initialStrikerName!, if (_initialNonStrikerName != null) _initialNonStrikerName!];
    }
    return ['Ganesh', 'Hehe'];
  }

  void _showSelectOutTypeSheet({VoidCallback? onOutTypeSelected}) {
    const outTypes = [
      'Bowled', 'Caught', 'Caught Behind', 'Caught & bowled',
      'Run out', 'LBW', 'Stumped', 'Retired hurt',
    ];
    const outTypesExtended = [
      'Run out (mankaded)', 'Hit wicket', 'Absent Hurt', 'Retired out',
      'Hit the ball twice', 'Obstr. The field', 'Timed out', 'Retired',
    ];
    bool showMore = false;
    _isModalOpen = true;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final list = showMore ? [...outTypes, ...outTypesExtended] : outTypes;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select out type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: list.map((label) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onOutTypeSelected?.call();
                        _onQuickScoreAction('W');
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: (MediaQuery.of(ctx).size.width - 56) / 4,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off_outlined, size: 24, color: AppColors.textSecondary),
                            const SizedBox(height: 4),
                            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setModalState(() => showMore = !showMore),
                  child: Text(showMore ? 'Show less' : 'Show more', style: const TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() {
      _isModalOpen = false;
    });
  }

  void _showChangeScorerSheet() {
    int selectedIndex = 0; // 0=QR code, 1=Teams, 2=Officials, 3=Search
    _isModalOpen = true;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final String? inviteCode = _match?['invite_code']?.toString() ?? _match?['inviteCode']?.toString();
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Change scorer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accentRed)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _scorerOption(ctx, setModalState, 0, selectedIndex, 'QR code', () => setModalState(() => selectedIndex = 0))),
                    Expanded(child: _scorerOption(ctx, setModalState, 1, selectedIndex, 'Teams', () => setModalState(() => selectedIndex = 1))),
                    Expanded(child: _scorerOption(ctx, setModalState, 2, selectedIndex, 'Officials', () => setModalState(() => selectedIndex = 2))),
                    Expanded(child: _scorerOption(ctx, setModalState, 3, selectedIndex, 'Search', () => setModalState(() => selectedIndex = 3))),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Ask the new scorer to scan below QR code.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.accentRed, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: (inviteCode != null && inviteCode.trim().isNotEmpty)
                          ? QrImageView(
                              data: inviteCode.trim(),
                              size: 160,
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.accentRed,
                            )
                          : const Icon(Icons.qr_code_2, size: 120, color: AppColors.accentRed),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).whenComplete(() => _isModalOpen = false);
  }

  Widget _scorerOption(BuildContext ctx, StateSetter setModalState, int index, int selectedIndex, String label, VoidCallback onTap) {
    return RadioListTile<int>(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: index,
      groupValue: selectedIndex,
      onChanged: (_) => onTap(),
      activeColor: AppColors.primaryTeal,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _settingsGroup(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const Icon(Icons.keyboard_arrow_up, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map(
          (label) => TextButton(
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 4), alignment: Alignment.centerLeft),
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$label – coming soon')));
            },
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ),
      ],
    );
  }

  void _showChangeMatchOversDialog() {
    final existingOvers = (_match?['overs'] ?? 20) as int;
    final controller = TextEditingController(text: '$existingOvers');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        title: const Text('Change match overs', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Overs',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '*you cannot change match overs in second innings.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
            onPressed: () {
              final text = controller.text.trim();
              final newOvers = int.tryParse(text);
              Navigator.of(ctx).pop();
              if (newOvers == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number of overs'), backgroundColor: AppColors.accentRed),
                );
                return;
              }
              _updateOversOnServer(newOvers);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  void _openMatchRulesScreen() {
    final overs = _match?['overs'] as int?;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchRulesScreen(matchId: _matchId, currentOvers: overs),
      ),
    );
  }

  void _showBonusRunsDialog(String battingTeam, String bowlingTeam) {
    String? selected;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: const Text('Bonus runs', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select team which is awarded bonus', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: Text('$battingTeam (Batting)'),
                value: 'batting',
                groupValue: selected,
                onChanged: (v) => setDialogState(() => selected = v),
                activeColor: AppColors.primaryTeal,
              ),
              RadioListTile<String>(
                title: Text('$bowlingTeam (Bowling)'),
                value: 'bowling',
                groupValue: selected,
                onChanged: (v) => setDialogState(() => selected = v),
                activeColor: AppColors.primaryTeal,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(ctx).pop();
                _updateBonusOrPenaltyOnServer(isBonus: true, team: selected);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPenaltyRunsDialog(String battingTeam, String bowlingTeam) {
    String? selected;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: const Text('Penalty runs', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select team which is facing penalty', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: Text('$battingTeam (Batting)'),
                value: 'batting',
                groupValue: selected,
                onChanged: (v) => setDialogState(() => selected = v),
                activeColor: AppColors.primaryTeal,
              ),
              RadioListTile<String>(
                title: Text('$bowlingTeam (Bowling)'),
                value: 'bowling',
                groupValue: selected,
                onChanged: (v) => setDialogState(() => selected = v),
                activeColor: AppColors.primaryTeal,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(ctx).pop();
                _updateBonusOrPenaltyOnServer(isBonus: false, team: selected);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndInningsDialog() {
    String? selected; // 'all_out' | 'declare' | 'penalty'
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: const Text('End innings', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _endInningsOption(isSelected: selected == 'all_out', onTap: () => setDialogState(() => selected = 'all_out'), icon: Icons.people_outline, label: 'All out'),
                _endInningsOption(isSelected: selected == 'declare', onTap: () => setDialogState(() => selected = 'declare'), label: 'Declare innings', textLabel: 'dec'),
                _endInningsOption(isSelected: selected == 'penalty', onTap: () => setDialogState(() => selected = 'penalty'), icon: Icons.gavel, label: 'Penalty'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(ctx).pop();
                if (selected == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select an option'), backgroundColor: AppColors.accentRed),
                  );
                } else {
                  _endInningsOnServer(selected!);
                }
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _endInningsOption({
    required bool isSelected,
    required VoidCallback onTap,
    required String label,
    IconData? icon,
    String? textLabel,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTeal.withOpacity(0.2) : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? AppColors.primaryTeal : AppColors.divider, width: 2),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 28, color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary)
                  : Text(textLabel ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(width: 80, child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Future<void> _updateOversOnServer(int newOvers) async {
    if (_matchId == null) return;
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in again'), backgroundColor: AppColors.accentRed),
        );
        return;
      }
      await ApiService.updateMatchConfig(
        token: token,
        matchId: _matchId!,
        overs: newOvers,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Match overs updated to $newOvers'), backgroundColor: AppColors.accentGreen),
        );
        _loadMatchDetails(silent: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update overs: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _updateBonusOrPenaltyOnServer({required bool isBonus, required String? team}) async {
    if (_matchId == null || team == null) return;
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in again'), backgroundColor: AppColors.accentRed),
        );
        return;
      }
      await ApiService.updateMatchConfig(
        token: token,
        matchId: _matchId!,
        bonusTeam: isBonus ? team : null,
        penaltyTeam: !isBonus ? team : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isBonus ? 'Bonus runs applied' : 'Penalty runs applied'),
            backgroundColor: isBonus ? AppColors.accentGreen : AppColors.accentRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update match: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _endInningsOnServer(String action) async {
    if (_matchId == null) return;
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in again'), backgroundColor: AppColors.accentRed),
        );
        return;
      }
      // For now, simply mark match as completed when innings ends.
      await ApiService.updateMatchStatus(token: token, matchId: _matchId!, status: 'completed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Innings ended'), backgroundColor: AppColors.accentGreen),
        );
        _loadMatchDetails(silent: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end innings: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _endMatchOnServer() async {
    if (_matchId == null) return;
    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in again'), backgroundColor: AppColors.accentRed),
          );
        }
        return;
      }

      await ApiService.updateMatchStatus(
        token: token,
        matchId: _matchId!,
        status: 'completed',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match ended'), backgroundColor: AppColors.accentGreen),
        );
        _loadMatchDetails(silent: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end match: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _loadMatchDetails({bool silent = false}) async {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    if (!silent) {
      if (!_isModalOpen && mounted) {
        setState(() => _loading = true);
      } else {
        // Avoid rebuilding widgets while dialogs/sheets are open.
        _loading = true;
      }
    } else {
      // Refresh in background without showing full-screen loader.
      if (mounted) _loading = false;
    }

    try {
      final session = supabase.auth.currentSession;
      final token = session?.accessToken;
      
      final response = await ApiService.getMatchScoreboard(token: token, matchId: _matchId!)
          .timeout(const Duration(seconds: 30));
      
      if (mounted) {
        final shouldUpdateUi = !_isModalOpen;
        if (shouldUpdateUi) {
          setState(() {
            _match = response['match'];
          
            // Data normalization: Ensure playerStats exists if team stats are present
            if (_match != null) {
            // Normalize score
            final rawScore = _match!['score'];
            if (rawScore == null || rawScore is! Map) {
              _match!['score'] = {
                'team_a_score': 0,
                'team_a_wkts': 0,
                'team_a_overs': 0.0,
                'team_b_score': 0,
                'team_b_wkts': 0,
                'team_b_overs': 0.0,
              };
            }

            // Normalize playerStats
            final rawPlayerStats = _match!['playerStats'];
            if (rawPlayerStats == null || rawPlayerStats is! List) {
              final rawA = _match!['team_a_stats'];
              final rawB = _match!['team_b_stats'];

              final aStats = (rawA is List)
                  ? rawA.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
                  : <Map<String, dynamic>>[];
              final bStats = (rawB is List)
                  ? rawB.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
                  : <Map<String, dynamic>>[];

              _match!['playerStats'] = [...aStats, ...bStats];
            }

            // Normalize commentary (used for current over/ball)
            final rawCommentary = _match!['commentary'];
            if (rawCommentary == null || rawCommentary is! List) {
              _match!['commentary'] = <dynamic>[];
            }
            }
            
            _syncCurrentPlayers();
            _loading = false;
          });
        } else {
          // Update data only (no setState) when modal is open.
          _match = response['match'];
          if (_match != null) {
            final rawScore = _match!['score'];
            if (rawScore == null || rawScore is! Map) {
              _match!['score'] = {
                'team_a_score': 0,
                'team_a_wkts': 0,
                'team_a_overs': 0.0,
                'team_b_score': 0,
                'team_b_wkts': 0,
                'team_b_overs': 0.0,
              };
            }

            final rawPlayerStats = _match!['playerStats'];
            if (rawPlayerStats == null || rawPlayerStats is! List) {
              final rawA = _match!['team_a_stats'];
              final rawB = _match!['team_b_stats'];

              final aStats = (rawA is List)
                  ? rawA.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
                  : <Map<String, dynamic>>[];
              final bStats = (rawB is List)
                  ? rawB.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
                  : <Map<String, dynamic>>[];

              _match!['playerStats'] = [...aStats, ...bStats];
            }

            final rawCommentary = _match!['commentary'];
            if (rawCommentary == null || rawCommentary is! List) {
              _match!['commentary'] = <dynamic>[];
            }
          }
          _syncCurrentPlayers();
          _loading = false;
        }
      }
    } catch (e) {
      developer.log('Error loading match details: $e');
      if (mounted) {
        setState(() {
          _match = null;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _match == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryElectric),
              const SizedBox(height: 24),
              Text('Fetching Match Details...', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    if (_match == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Match Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Match not found or failed to load', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _loadMatchDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 7,
      initialIndex: _initialTabIndex,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildInfoTab(),
                      _buildLiveTab(),
                      _buildScorecardTab(),
                      _buildOversTab(), // COMMS tab content
                      _buildSquadsTab(),
                      _buildAnalysisTab(),
                      _buildHighlightsTab(), // GALLERY tab content
                    ],
                  ),
                ),
              ],
            ),
            if (_loading)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(0.04),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryElectric),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTeamName(dynamic teamData, String fallback) {
    if (teamData is Map) {
      return teamData['name']?.toString() ?? fallback;
    } else if (teamData is List && teamData.isNotEmpty) {
      final first = teamData[0];
      if (first is Map) return first['name']?.toString() ?? fallback;
    }
    return fallback;
  }

  String? _toId(dynamic v) => v?.toString().trim().isEmpty == true ? null : v?.toString();

  Map<String, dynamic>? _findPlayerStatById(String? playerStatId) {
    if (playerStatId == null || playerStatId.trim().isEmpty) return null;
    final stats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    for (final p in stats) {
      if (_toId(p['id']) == playerStatId) return p;
    }
    return null;
  }

  Map<String, dynamic>? _findPlayerStatByTeamAndName({
    required String? teamId,
    required String? playerName,
  }) {
    if (teamId == null || playerName == null || playerName.trim().isEmpty) return null;
    final stats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    final targetName = playerName.trim().toLowerCase();
    for (final p in stats) {
      if (_toId(p['team_id']) == teamId && (p['player_name']?.toString().trim().toLowerCase() == targetName)) {
        return p;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _playersForTeam(String teamId) {
    final stats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    return stats.where((p) => _toId(p['team_id']) == teamId).toList();
  }

  void _syncCurrentPlayers() {
    final teamAId = _toId(_match?['team_a']?['id']) ?? _toId(_match?['team_a_details']?['id']);
    final teamBId = _toId(_match?['team_b']?['id']) ?? _toId(_match?['team_b_details']?['id']);
    if (teamAId == null || teamBId == null) return;

    final score = (_match?['score'] is Map) ? (_match?['score'] as Map<String, dynamic>) : <String, dynamic>{};
    final teamAWkts = _parseInt(score['team_a_wkts'], 0);
    final teamBWkts = _parseInt(score['team_b_wkts'], 0);
    final teamAOvers = _parseDouble(score['team_a_overs'], 0.0);
    final teamBOvers = _parseDouble(score['team_b_overs'], 0.0);

    // If one side is already all out (10 wkts), the other side is batting.
    if (teamAWkts >= 10) {
      _battingTeamId = teamBId;
      _fieldingTeamId = teamAId;
    } else if (teamBWkts >= 10) {
      _battingTeamId = teamAId;
      _fieldingTeamId = teamBId;
    } else {
      final battingIsB = teamBOvers > teamAOvers;
      _battingTeamId = battingIsB ? teamBId : teamAId;
      _fieldingTeamId = battingIsB ? teamAId : teamBId;
    }

    final bool inningsSwitched = _lastBattingTeamId != null &&
        _battingTeamId != null &&
        _battingTeamId != _lastBattingTeamId;

    final String? initStrikerName = inningsSwitched ? null : _initialStrikerName;
    final String? initNonStrikerName = inningsSwitched ? null : _initialNonStrikerName;
    final String? initBowlerName = inningsSwitched ? null : _initialBowlerName;

    final battingPlayers = _playersForTeam(_battingTeamId ?? '').toList();
    final fieldingPlayers = _playersForTeam(_fieldingTeamId ?? '').toList();

    // Striker & non-striker: prefer already-selected IDs if still valid.
    final existingStriker = _findPlayerStatById(_strikerPlayerStatId);
    final existingNonStriker = _findPlayerStatById(_nonStrikerPlayerStatId);
    final existingBowler = _findPlayerStatById(_bowlerPlayerStatId);

    Map<String, dynamic>? striker = existingStriker != null && _toId(existingStriker['team_id']) == _battingTeamId
        ? existingStriker
        : _findPlayerStatByTeamAndName(teamId: _battingTeamId, playerName: initStrikerName) ??
            (battingPlayers.isNotEmpty ? battingPlayers.first : null);

    Map<String, dynamic>? nonStriker = existingNonStriker != null && _toId(existingNonStriker['team_id']) == _battingTeamId
        ? existingNonStriker
        : _findPlayerStatByTeamAndName(teamId: _battingTeamId, playerName: initNonStrikerName) ??
            (battingPlayers.length > 1 ? battingPlayers[1] : null) ??
            (battingPlayers.isNotEmpty ? battingPlayers.first : null);

    Map<String, dynamic>? bowler = existingBowler != null && _toId(existingBowler['team_id']) == _fieldingTeamId
        ? existingBowler
        : _findPlayerStatByTeamAndName(teamId: _fieldingTeamId, playerName: initBowlerName) ??
            (fieldingPlayers.isNotEmpty ? fieldingPlayers.first : null);

    _strikerPlayerStatId = _toId(striker?['id']);
    _nonStrikerPlayerStatId = _toId(nonStriker?['id']);
    _bowlerPlayerStatId = _toId(bowler?['id']);

    _lastBattingTeamId = _battingTeamId;
  }

  Future<String?> _pickPlayerStatIdDialog({
    required String title,
    required String teamId,
    String? initialId,
    String? excludeId,
    String? excludeId2,
  }) async {
    // Support nested modal dialogs (e.g. wicket -> replace batters -> select new batter).
    // In that case `_isModalOpen` is already true, and we must not set it back to false
    // while the outer dialog flow is still running.
    final wasModalOpen = _isModalOpen;
    final allPlayers = _playersForTeam(teamId);
    if (allPlayers.isEmpty) return null;

    final eligiblePlayers = allPlayers.where((p) {
      final id = _toId(p['id']);
      if (id == null) return false;
      if (excludeId != null && id == excludeId) return false;
      if (excludeId2 != null && id == excludeId2) return false;
      return true;
    }).toList();

    if (eligiblePlayers.isEmpty) return null;

    String? selectedId = initialId ?? _toId(eligiblePlayers.first['id']);

    _isModalOpen = true;
    try {
      return await showDialog<String>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              child: StatefulBuilder(
                builder: (ctx2, setStateDialog) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: eligiblePlayers.length,
                    itemBuilder: (ctx2, i) {
                      final p = eligiblePlayers[i];
                      final id = _toId(p['id']);
                      final name = p['player_name']?.toString() ?? 'Unknown';
                      final selected = id != null && id == selectedId;
                      return RadioListTile<String>(
                        value: id ?? '',
                        groupValue: selectedId,
                        onChanged: (v) {
                          if (v == null || v.trim().isEmpty) return;
                          setStateDialog(() => selectedId = v);
                        },
                        title: Text(name),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(selectedId),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      if (!wasModalOpen) {
        _isModalOpen = false;
      }
    }
  }

  void _onSelectStriker() async {
    final teamId = _battingTeamId;
    if (teamId == null) return;
    final picked = await _pickPlayerStatIdDialog(
      title: 'Select striker',
      teamId: teamId,
      initialId: _strikerPlayerStatId,
      excludeId: _nonStrikerPlayerStatId,
      excludeId2: null,
    );
    if (!mounted || picked == null) return;
    setState(() => _strikerPlayerStatId = picked);
  }

  void _onSelectNonStriker() async {
    final teamId = _battingTeamId;
    if (teamId == null) return;
    final picked = await _pickPlayerStatIdDialog(
      title: 'Select non-striker',
      teamId: teamId,
      initialId: _nonStrikerPlayerStatId,
      excludeId: _strikerPlayerStatId,
      excludeId2: null,
    );
    if (!mounted || picked == null) return;
    setState(() => _nonStrikerPlayerStatId = picked);
  }

  void _onSelectBowler() async {
    final teamId = _fieldingTeamId;
    if (teamId == null) return;
    final picked = await _pickPlayerStatIdDialog(
      title: 'Select bowler',
      teamId: teamId,
      initialId: _bowlerPlayerStatId,
      excludeId: null,
      excludeId2: null,
    );
    if (!mounted || picked == null) return;
    setState(() => _bowlerPlayerStatId = picked);
  }

  Future<void> _replaceBatterAfterWicket() async {
    // Backward-compatible: keep this method, but the wicket flow now uses
    // `_showReplaceBattersDialogInternal` so the UI matches the user's expectation.
    if (_battingTeamId == null || _strikerPlayerStatId == null) return;

    await _showReplaceBattersDialogInternal(
      preselectName: _findPlayerStatById(_strikerPlayerStatId)?['player_name']?.toString(),
    );
  }

  Future<void> _replaceBowlerAfterOver() async {
    if (_fieldingTeamId == null || _bowlerPlayerStatId == null) return;

    final picked = await _pickPlayerStatIdDialog(
      title: 'Select new bowler',
      teamId: _fieldingTeamId!,
      initialId: null,
      excludeId: _bowlerPlayerStatId,
      excludeId2: null,
    );

    if (!mounted) return;
    if (picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other bowler available')),
      );
      return;
    }

    setState(() => _bowlerPlayerStatId = picked);
  }

  Widget _buildAppBar(BuildContext context) {
    final teamA = _getTeamName(_match?['team_a'] ?? _match?['team_a_details'], 'Team A');
    final teamB = _getTeamName(_match?['team_b'] ?? _match?['team_b_details'], 'Team B');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryElectric, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '$teamA v $teamB',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      _loadMatchDetails();
                    },
                  ),
                  IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: _showMatchSettingsSheet,
                  ),
                ],
              ),
            ),
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              dividerColor: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 10),
              tabs: [
                Tab(text: 'INFO'),
                Tab(text: 'LIVE'),
                Tab(text: 'SCORECARD'),
                Tab(text: 'COMMS'),
                Tab(text: 'SQUADS'),
                Tab(text: 'ANALYSIS'),
                Tab(text: 'GALLERY'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- INFO TAB ---
  Widget _buildInfoTab() {
    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection('INFO', {
              'Series': 'Tournament Match',
              'Match Status': _match?['status']?.toUpperCase() ?? 'SCHEDULED',
              'Date': _match?['start_date'] != null ? DateTime.parse(_match!['start_date']).toLocal().toString().split(' ')[0] : 'TBA',
              'Venue': _match?['venue_details']?['name'] ?? 'TBA',
              'Overs': (_match?['overs'] ?? 20).toString(),
            }),
            _buildInfoSection('TEAMS', {
              'Team A': _getTeamName(_match?['team_a'] ?? _match?['team_a_details'], 'TBA'),
              'Team B': _getTeamName(_match?['team_b'] ?? _match?['team_b_details'], 'TBA'),
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
        ),
        ...data.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 100, child: Text(e.key, style: const TextStyle(color: AppColors.textSecondary))),
              Expanded(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
            ],
          ),
        )),
        const Divider(height: 1),
      ],
    );
  }

  // --- LIVE TAB ---
  Widget _buildLiveTab() {
    final statusRaw = _match?['status'];
    final status = statusRaw?.toString().toLowerCase() ?? '';
    final bool isCompleted = status.contains('completed') || status.contains('finished');
    const double keypadHeight = 230;

    return Material(
      color: AppColors.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 12),
          _buildModernScoreHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: isCompleted ? 24 : (keypadHeight + 24)),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted) ...[
                    _buildBatterBowlerCards(),
                    const SizedBox(height: 16),
                    _buildOverTimelineAndCommentary(),
                  ] else ...[
                    _buildPostMatchSummary(),
                    const SizedBox(height: 16),
                    _buildOverTimelineAndCommentary(),
                  ],
                ],
              ),
            ),
          ),
          if (!isCompleted) SizedBox(height: keypadHeight, child: _buildScoringKeypad()),
          if (!isCompleted) const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 4.1 Score header – modern two-tone card
  Widget _buildModernScoreHeader() {
    final score = _match?['score'];
    final status = _match?['status'];
    final teamAName = _getTeamName(_match?['team_a'] ?? _match?['team_a_details'], 'Team A');
    final teamBName = _getTeamName(_match?['team_b'] ?? _match?['team_b_details'], 'Team B');

    final teamAScore = _parseInt(score?['team_a_score'], 0);
    final teamAWkts = _parseInt(score?['team_a_wkts'], 0);
    final teamAOvers = _parseDouble(score?['team_a_overs'], 0.0);

    final teamBScore = _parseInt(score?['team_b_score'], 0);
    final teamBWkts = _parseInt(score?['team_b_wkts'], 0);
    final teamBOvers = _parseDouble(score?['team_b_overs'], 0.0);

    // Decide who is currently batting.
    // If someone is all-out (10 wkts), the other team is batting next.
    final bool isTeamBBatting = teamAWkts >= 10
        ? true
        : (teamBWkts >= 10 ? false : teamBOvers > teamAOvers);
    final battingName = isTeamBBatting ? teamBName : teamAName;
    final battingScore = isTeamBBatting ? teamBScore : teamAScore;
    final battingWkts = isTeamBBatting ? teamBWkts : teamAWkts;
    final battingOvers = isTeamBBatting ? teamBOvers : teamAOvers;
    final targetScore = isTeamBBatting ? (teamAScore + 1) : null;

    final totalOvers = (_match?['overs'] ?? 20) * 1;
    final totalBalls = totalOvers * 6;
    final ballsBowled = _oversToBalls(battingOvers);
    final ballsLeft = (totalBalls - ballsBowled).clamp(0, totalBalls);

    String? chaseText;
    if (targetScore != null) {
      final runsNeeded = (targetScore - battingScore).clamp(0, 9999);
      if (runsNeeded > 0 && ballsLeft > 0) {
        chaseText = 'Need $runsNeeded from $ballsLeft balls';
      } else if (runsNeeded <= 0) {
        chaseText = 'Chase completed';
      } else {
        chaseText = 'Target $targetScore';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Left: batting team & big score – light purple
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      AppColors.primaryElectric,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      battingName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$battingScore',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '/$battingWkts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${battingOvers.toStringAsFixed(1)})',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (chaseText != null)
                      Text(
                        chaseText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Right: status chip & meta – white with divider
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(
                      color: Colors.white.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: _buildStatusChip(status),
                    ),
                    const Spacer(),
                    Text(
                      _match?['tournament_name']?.toString() ?? 'Friendly Match',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _match?['venue_details']?['name']?.toString() ?? 'Venue TBA',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _parseInt(dynamic v, int def) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }

  double _parseDouble(dynamic v, double def) {
    if (v == null) return def;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? def;
  }

  int _oversToBalls(double overs) {
    final whole = overs.floor();
    final fraction = ((overs - whole) * 10).round(); // 0.0 → 0, 0.1 → 1 ball ...
    final balls = fraction.clamp(0, 5);
    return whole * 6 + balls;
  }

  Widget _buildStatusChip(dynamic statusRaw) {
    final status = (statusRaw?.toString().toLowerCase() ?? 'scheduled').trim();
    String label = status.isEmpty ? 'SCHEDULED' : status.toUpperCase();
    Color bg = Colors.grey;

    if (status.contains('live')) {
      label = 'LIVE';
      bg = Colors.red;
    } else if (status.contains('completed') || status.contains('finished')) {
      label = 'COMPLETED';
      bg = Colors.grey.shade600;
    } else if (status.contains('rain')) {
      label = 'RAIN DELAY';
      bg = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // 4.2 Quick controls strip – scoring buttons (Wrap so horizontal scroll doesn't block tab swipe)
  Widget _buildQuickControlsStrip() {
    final controls = [
      '+1',
      '+2',
      '+3',
      '4',
      '6',
      'W',
      'NB',
      'WD',
      '0.1 over',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controls.map((label) {
          final isPrimary = label == '4' || label == '6' || label == 'W';
          return _quickControlButton(
            label,
            isPrimary: isPrimary,
            onTap: label == 'W' ? () => _showSelectOutTypeSheet() : null,
          );
        }).toList(),
      ),
    );
  }

  // Keypad-style scoring UI (numbers + WD/NB/BYE/LB + OUT).
  // This is used on the LIVE tab so the scorer sees the same layout as the
  // screenshot-based flow.
  Widget _buildScoringKeypad() {
    Color cellBorderColor = Colors.black12;
    const TextStyle baseTextStyle = TextStyle(
      color: Colors.black87,
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );

    Widget cell(
      String label, {
        required VoidCallback onTap,
        bool isPrimary = false,
        bool isDanger = false,
      }) {
      final Color bg = isDanger
          ? AppColors.accentRed.withOpacity(0.12)
          : (isPrimary ? AppColors.primaryElectric.withOpacity(0.12) : Colors.white);
      final Color fg = isDanger
          ? AppColors.accentRed
          : (isPrimary ? AppColors.primaryElectric : Colors.black87);

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: cellBorderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: baseTextStyle.copyWith(color: fg),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: run / ball buttons
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: cell('0', onTap: () => _onQuickScoreAction('0.1 over'))),
                      Expanded(child: cell('1', onTap: () => _onQuickScoreAction('+1'))),
                      Expanded(child: cell('2', onTap: () => _onQuickScoreAction('+2'))),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: cell('3', onTap: () => _onQuickScoreAction('+3'))),
                      Expanded(child: cell('4', onTap: () => _onQuickScoreAction('4'))),
                      Expanded(child: cell('6', onTap: () => _onQuickScoreAction('6'))),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: cell('WD', onTap: () => _onQuickScoreAction('WD'), isPrimary: true)),
                      Expanded(child: cell('NB', onTap: () => _onQuickScoreAction('NB'), isPrimary: true)),
                      Expanded(child: cell('BYE', onTap: () => _onQuickScoreAction('BYE'))),
                      Expanded(child: cell('LB', onTap: () => _onQuickScoreAction('LB'))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Right: undo / out
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: cell(
                  'UNDO',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Undo not available in Live scoring yet')),
                    );
                  },
                  isPrimary: true,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: cell(
                  'OUT',
                  onTap: () => _showSelectOutTypeSheet(),
                  isDanger: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onQuickScoreAction(String label) async {
    if (_matchId == null || _match == null) return;
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) return;

    final score = _match!['score'] as Map<String, dynamic>?;
    if (score == null) return;

    int teamAScore = (score['team_a_score'] ?? 0) as int;
    int teamAWkts = (score['team_a_wkts'] ?? 0) as int;
    double teamAOvers = (score['team_a_overs'] ?? 0.0).toDouble();
    int teamBScore = (score['team_b_score'] ?? 0) as int;
    int teamBWkts = (score['team_b_wkts'] ?? 0) as int;
    double teamBOvers = (score['team_b_overs'] ?? 0.0).toDouble();
    final bool battingIsB;
    // Determine current batting team:
    // - If one side is all-out (10 wkts), the other side must be batting next.
    // - Otherwise, use which team has faced more balls (heuristic: higher overs).
    if (teamAWkts >= 10) {
      battingIsB = true;
    } else if (teamBWkts >= 10) {
      battingIsB = false;
    } else {
      battingIsB = teamBOvers > teamAOvers;
    }

    // Set current on-field selections so wicket replacement uses correct team players.
    final computedTeamAId = _toId(_match?['team_a']?['id']) ?? _toId(_match?['team_a_details']?['id']);
    final computedTeamBId = _toId(_match?['team_b']?['id']) ?? _toId(_match?['team_b_details']?['id']);
    if (computedTeamAId != null && computedTeamBId != null) {
      _battingTeamId = battingIsB ? computedTeamBId : computedTeamAId;
      _fieldingTeamId = battingIsB ? computedTeamAId : computedTeamBId;
    }

    int battingScore;
    int battingWkts;
    double battingOvers;
    if (battingIsB) {
      battingScore = teamBScore;
      battingWkts = teamBWkts;
      battingOvers = teamBOvers;
    } else {
      battingScore = teamAScore;
      battingWkts = teamAWkts;
      battingOvers = teamAOvers;
    }

    int runsToAdd = 0;
    bool addWicket = false;
    bool addBall = true;
    String eventType = label;
    final int prevOverInt = battingOvers.floor();
    bool overCompleted = false;
    // Read match rule settings (saved via MatchRulesScreen into `matches` table).
    // If columns are missing, we fall back to cricket defaults.
    final wideLegal = _match?['wide_legal'] == true;
    final noballLegal = _match?['noball_legal'] == true;
    final wideRunsCfg = _parseInt(_match?['wide_runs'], 1).clamp(0, 10);
    final noBallRunsCfg = _parseInt(_match?['noball_runs'], 1).clamp(0, 10);

    if (label == '+1') { runsToAdd = 1; eventType = '1'; }
    else if (label == '+2') { runsToAdd = 2; eventType = '2'; }
    else if (label == '+3') { runsToAdd = 3; eventType = '3'; }
    else if (label == '4') { runsToAdd = 4; eventType = '4'; }
    else if (label == '6') { runsToAdd = 6; eventType = '6'; }
    else if (label == 'W') { addWicket = true; runsToAdd = 0; eventType = 'W'; }
    else if (label == 'BYE') { runsToAdd = 1; addBall = true; addWicket = false; eventType = 'BYE'; }
    else if (label == 'LB') { runsToAdd = 1; addBall = true; addWicket = false; eventType = 'LB'; }
    else if (label == 'NB') {
      runsToAdd = noBallRunsCfg;
      addBall = noballLegal; // Count NB as legal ball only if enabled
      eventType = 'NB';
    } else if (label == 'WD') {
      runsToAdd = wideRunsCfg;
      addBall = wideLegal; // Count WD as legal ball only if enabled
      eventType = 'WD';
    }
    else if (label == '0.1 over') { runsToAdd = 0; eventType = '0'; }

    if (addWicket) battingWkts = (battingWkts + 1).clamp(0, 10);
    battingScore += runsToAdd;
    if (addBall) {
      battingOvers += 0.1;
      if (battingOvers - battingOvers.truncate() > 0.59) battingOvers = battingOvers.truncate() + 1.0;
      overCompleted = battingOvers.floor() > prevOverInt;
    }

    if (!battingIsB) {
      teamAScore = battingScore;
      teamAWkts = battingWkts;
      teamAOvers = battingOvers;
    } else {
      teamBScore = battingScore;
      teamBWkts = battingWkts;
      teamBOvers = battingOvers;
    }

    try {
      await ApiService.updateMatchScore(
        token: token,
        matchId: _matchId!,
        teamAScore: teamAScore,
        teamAWkts: teamAWkts,
        teamAOvers: teamAOvers,
        teamBScore: teamBScore,
        teamBWkts: teamBWkts,
        teamBOvers: teamBOvers,
      );
      final oversForComm = addBall ? battingOvers : (battingOvers - 0.1).clamp(0.0, 999.0);
      final overNum = oversForComm.floor();
      final ballNum = ((oversForComm - overNum) * 10).round().clamp(0, 6);
      await ApiService.addCommentary(
        token: token,
        matchId: _matchId!,
        overNumber: overNum,
        ballNumber: ballNum,
        eventType: eventType,
        commentaryText: '${eventType}${runsToAdd > 0 ? " – $runsToAdd run${runsToAdd > 1 ? "s" : ""}" : addWicket ? " – Wicket" : ""}.',
        runs: runsToAdd,
        isWicket: addWicket,
      );

      // Update player stats in real-time (match_player_stats).
      // This is what makes bowler runs/wickets update on SCORECARD + LIVE cards.
      final striker = _findPlayerStatById(_strikerPlayerStatId);
      final nonStriker = _findPlayerStatById(_nonStrikerPlayerStatId);
      final bowler = _findPlayerStatById(_bowlerPlayerStatId);

      // Batter update (runs/balls/fours/sixes/wickets)
      if (_strikerPlayerStatId != null && striker != null) {
        final currentRuns = (striker['runs'] ?? 0) as int;
        final currentBalls = (striker['balls'] ?? 0) as int;
        final currentFours = (striker['fours'] ?? 0) as int;
        final currentSixes = (striker['sixes'] ?? 0) as int;
        final currentWkts = (striker['wickets'] ?? 0) as int;

        final nextRuns = currentRuns + runsToAdd;
        final nextBalls = currentBalls + (addBall ? 1 : 0);

        int nextFours = currentFours;
        int nextSixes = currentSixes;
        if (label == '4') nextFours = currentFours + 1;
        if (label == '6') nextSixes = currentSixes + 1;

        final nextWkts = currentWkts + (addWicket ? 1 : 0);

        await ApiService.updatePlayerStats(
          token: token,
          matchId: _matchId!,
          playerStatId: _strikerPlayerStatId!,
          runs: nextRuns,
          balls: nextBalls,
          fours: nextFours,
          sixes: nextSixes,
          wickets: nextWkts,
        );
      }

      // Bowler update (runs/overs/wickets)
      if (_bowlerPlayerStatId != null && bowler != null) {
        final currentRuns = (bowler['runs'] ?? 0) as int;
        final currentWkts = (bowler['wickets'] ?? 0) as int;
        final currentOvers = _parseDouble(bowler['overs'], 0.0);

        final nextRuns = currentRuns + runsToAdd;
        final nextOvers = currentOvers + (addBall ? 0.1 : 0.0);
        final nextWkts = currentWkts + (addWicket ? 1 : 0);

        await ApiService.updatePlayerStats(
          token: token,
          matchId: _matchId!,
          playerStatId: _bowlerPlayerStatId!,
          runs: nextRuns,
          overs: nextOvers,
          wickets: nextWkts,
        );
      }

      // Strike swap after odd runs (skip wicket-only events).
      if (!addWicket && runsToAdd > 0 && runsToAdd % 2 == 1) {
        setState(() {
          final tmp = _strikerPlayerStatId;
          _strikerPlayerStatId = _nonStrikerPlayerStatId;
          _nonStrikerPlayerStatId = tmp;
        });
      }

      // After wicket (unless innings is complete), ask for new batter.
      if (addWicket && battingWkts < 10) {
        await _replaceBatterAfterWicket();
      }

      // At end of each completed over, ask for a new bowler.
      if (overCompleted && battingWkts < 10) {
        await _replaceBowlerAfterOver();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              addWicket && battingWkts >= 10 ? 'Innings complete' : 'Score updated',
            ),
            backgroundColor: addWicket && battingWkts >= 10
                ? AppColors.accentYellow
                : AppColors.accentGreen,
            duration: const Duration(seconds: 1),
          ),
        );
        _loadMatchDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Widget _quickControlButton(String label, {required bool isPrimary, VoidCallback? onTap}) {
    final Color primaryColor = label == 'W' ? AppColors.accentSunset : AppColors.primaryElectric;

    return Material(
      color: isPrimary ? primaryColor : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: isPrimary ? Colors.transparent : AppColors.primaryElectric.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap ?? () => _onQuickScoreAction(label),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isPrimary ? Colors.white : AppColors.primaryElectric,
            ),
          ),
        ),
      ),
    );
  }

  // 4.3 Batter & bowler cards
  Widget _buildBatterBowlerCards() {
    final rawPlayerStats = _match?['playerStats'];
    final playerStats = (rawPlayerStats is List)
        ? rawPlayerStats
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    // For Live tab, show current batters and bowlers based on our selected IDs.
    // This ensures the cards are correct even before balls/overs start incrementing.
    final battingPlayers = _battingTeamId == null ? <Map<String, dynamic>>[] : _playersForTeam(_battingTeamId!);
    final fieldingPlayers = _fieldingTeamId == null ? <Map<String, dynamic>>[] : _playersForTeam(_fieldingTeamId!);

    Map<String, dynamic>? striker = _findPlayerStatById(_strikerPlayerStatId) ??
        _findPlayerStatByTeamAndName(teamId: _battingTeamId, playerName: _initialStrikerName) ??
        (battingPlayers.isNotEmpty ? battingPlayers.first : null);

    Map<String, dynamic>? nonStriker = _findPlayerStatById(_nonStrikerPlayerStatId) ??
        _findPlayerStatByTeamAndName(teamId: _battingTeamId, playerName: _initialNonStrikerName) ??
        (battingPlayers.length > 1 ? battingPlayers[1] : (battingPlayers.isNotEmpty ? battingPlayers.first : null));

    Map<String, dynamic>? bowler = _findPlayerStatById(_bowlerPlayerStatId) ??
        _findPlayerStatByTeamAndName(teamId: _fieldingTeamId, playerName: _initialBowlerName) ??
        (fieldingPlayers.isNotEmpty ? fieldingPlayers.first : null);
    final rawCommentary = _match?['commentary'];
    final commentary = (rawCommentary is List)
        ? rawCommentary
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    // Current over from latest ball
    int? currentOver;
    int? currentBall;
    if (commentary.isNotEmpty) {
      final latest = commentary.reduce((a, b) {
        final aOver = (a['over_number'] as num?)?.toInt() ?? 0;
        final bOver = (b['over_number'] as num?)?.toInt() ?? 0;
        final aBall = (a['ball_number'] as num?)?.toInt() ?? 0;
        final bBall = (b['ball_number'] as num?)?.toInt() ?? 0;
        if (aOver != bOver) return aOver > bOver ? a : b;
        return aBall >= bBall ? a : b;
      });
      currentOver = (latest['over_number'] as num?)?.toInt();
      currentBall = (latest['ball_number'] as num?)?.toInt();
    }

    // Placeholder cards when no batters/bowlers yet so Live tab is never empty
    final strikerFallback = <String, dynamic>{'player_name': _initialStrikerName ?? 'Striker', 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0};
    final nonStrikerFallback = <String, dynamic>{'player_name': _initialNonStrikerName ?? 'Non-striker', 'runs': 0, 'balls': 0, 'fours': 0, 'sixes': 0};
    final bowlerFallback = <String, dynamic>{'player_name': _initialBowlerName ?? 'Bowler', 'wickets': 0, 'overs': 0, 'runs': 0};

    final showBatters = <Map<String, dynamic>>[
      (striker ?? strikerFallback) as Map<String, dynamic>,
      (nonStriker ?? nonStrikerFallback) as Map<String, dynamic>,
    ];
    final showBowlers = <Map<String, dynamic>>[
      (bowler ?? bowlerFallback) as Map<String, dynamic>,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _batterCard(
                  label: 'STRIKER',
                  player: showBatters[0] as Map<String, dynamic>,
                  onStrike: true,
                  onTap: _onSelectStriker,
                ),
              ),
              if (showBatters.length > 1) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _batterCard(
                    label: 'NON-STRIKER',
                    player: showBatters[1] as Map<String, dynamic>,
                    onStrike: false,
                    onTap: _onSelectNonStriker,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _bowlerCard(
            bowler: showBowlers.first as Map<String, dynamic>,
            overLabel: (currentOver != null && currentBall != null)
                ? 'Over $currentOver.$currentBall'
                : (fieldingPlayers.isEmpty ? 'Yet to bowl' : 'Current spell'),
            onTap: _onSelectBowler,
          ),
        ],
      ),
    );
  }

  Widget _batterCard({
    required String label,
    required Map<String, dynamic> player,
    required bool onStrike,
    VoidCallback? onTap,
  }) {
    final name = player['player_name']?.toString() ?? 'Unknown';
    final runs = (player['runs'] ?? 0) as int;
    final balls = (player['balls'] ?? 0) as int;
    final fours = (player['fours'] ?? 0) as int;
    final sixes = (player['sixes'] ?? 0) as int;
    final sr = _getStrikeRate(player);

    final content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryElectric.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryElectric,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$runs ($balls)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'SR $sr',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _smallBadge(label),
              const SizedBox(width: 6),
              if (onStrike) _smallBadge('On strike'),
              const Spacer(),
              Text(
                '4s $fours · 6s $sixes',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }

  Widget _bowlerCard({
    required Map<String, dynamic> bowler,
    required String overLabel,
    VoidCallback? onTap,
  }) {
    final name = bowler['player_name']?.toString() ?? 'Unknown';
    final overs = (bowler['overs'] ?? 0).toString();
    final wickets = (bowler['wickets'] ?? 0).toString();
    final runs = (bowler['runs'] ?? 0).toString();
    final eco = _getEconomy(bowler);

    final content = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accentSunset.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.accentSunset,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$wickets-$runs ($overs)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Eco $eco',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _smallBadge(overLabel),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: content,
    );
  }

  Widget _smallBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  String _getStrikeRate(Map<String, dynamic> p) {
    if (p['strike_rate'] != null) return p['strike_rate'].toString();
    final runs = p['runs'] ?? 0;
    final balls = p['balls'] ?? 0;
    if (balls == 0) return '0.00';
    return (runs / balls * 100).toStringAsFixed(2);
  }

  String _getEconomy(Map<String, dynamic> p) {
    if (p['economy'] != null) return p['economy'].toString();
    final runs = p['runs'] ?? 0;
    final overs = p['overs'] ?? 0;
    if (overs == 0) return '0.00';
    return (runs / overs).toStringAsFixed(2);
  }

  // Shared mini-table header & row for scorecard tab
  Widget _buildMiniHeader(List<String> labels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              labels[0],
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          ...labels.skip(1).map(
                (l) => Expanded(
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Post‑match summary (hero + key performers + CTAs)
  Widget _buildPostMatchSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSummaryCard(),
          const SizedBox(height: 16),
          _buildKeyPerformersRow(),
          const SizedBox(height: 16),
          _buildPostMatchCtas(),
        ],
      ),
    );
  }

  Widget _buildHeroSummaryCard() {
    final score = _match?['score'] ?? {};
    final teamAName = _match?['team_a']?['name'] ?? 'Team A';
    final teamBName = _match?['team_b']?['name'] ?? 'Team B';
    final teamAScore = (score['team_a_score'] ?? 0) as int;
    final teamAWkts = (score['team_a_wkts'] ?? 0) as int;
    final teamAOvers = (score['team_a_overs'] ?? 0.0) * 1.0;
    final teamBScore = (score['team_b_score'] ?? 0) as int;
    final teamBWkts = (score['team_b_wkts'] ?? 0) as int;
    final teamBOvers = (score['team_b_overs'] ?? 0.0) * 1.0;

    String title;
    if (teamAScore > teamBScore) {
      final margin = teamAScore - teamBScore;
      title = '$teamAName won by $margin runs';
    } else if (teamBScore > teamAScore) {
      final wicketsLeft = (10 - teamBWkts).clamp(1, 10);
      title = '$teamBName won by $wicketsLeft wickets';
    } else {
      title = 'Match tied';
    }

    final overs = (_match?['overs'] ?? 20) as int;
    final format = overs == 20 ? 'T20' : '${overs}-over match';
    final venue = _match?['venue_details']?['name']?.toString() ?? 'Venue TBA';

    String dateText = 'Date TBA';
    final rawDate = _match?['start_date'];
    if (rawDate is String) {
      try {
        final dt = DateTime.parse(rawDate).toLocal();
        dateText = '${dt.day.toString().padLeft(2, '0')} '
            '${_monthShort(dt.month)} ${dt.year}';
      } catch (_) {}
    }

    final subline = '$format · $venue · $dateText';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subline,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _finalScoreColumn(
                  teamAName,
                  '$teamAScore/$teamAWkts',
                  teamAOvers,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.divider,
              ),
              Expanded(
                child: _finalScoreColumn(
                  teamBName,
                  '$teamBScore/$teamBWkts',
                  teamBOvers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _finalScoreColumn(String team, String score, double overs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score ($overs)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  Widget _buildKeyPerformersRow() {
    final stats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);

    Map<String, dynamic>? bestBatter;
    Map<String, dynamic>? bestBowler;
    Map<String, dynamic>? gameChanger;

    if (stats.isNotEmpty) {
      final batters = [...stats]..retainWhere((p) => (p['balls'] ?? 0) > 0);
      batters.sort((a, b) => ((b['runs'] ?? 0) as int).compareTo((a['runs'] ?? 0) as int));
      if (batters.isNotEmpty) bestBatter = batters.first;

      final bowlers = [...stats]..retainWhere((p) => (p['overs'] ?? 0) > 0);
      bowlers.sort((a, b) {
        final wDiff = ((b['wickets'] ?? 0) as int).compareTo((a['wickets'] ?? 0) as int);
        if (wDiff != 0) return wDiff;
        final ecoA = double.tryParse(_getEconomy(a)) ?? 99;
        final ecoB = double.tryParse(_getEconomy(b)) ?? 99;
        return ecoA.compareTo(ecoB);
      });
      if (bowlers.isNotEmpty) bestBowler = bowlers.first;

      final impactList = [...stats];
      impactList.sort((a, b) {
        final impactA = (a['runs'] ?? 0) + (a['wickets'] ?? 0) * 20;
        final impactB = (b['runs'] ?? 0) + (b['wickets'] ?? 0) * 20;
        return impactB.compareTo(impactA);
      });
      gameChanger = impactList.first;
    }

    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _mvpCard(
            title: 'BATTER OF THE MATCH',
            player: bestBatter,
            fallbackLabel: 'To be decided',
            statBuilder: (p) {
              final runs = p['runs'] ?? 0;
              final balls = p['balls'] ?? 0;
              final fours = p['fours'] ?? 0;
              final sixes = p['sixes'] ?? 0;
              return '$runs ($balls) · 4s $fours · 6s $sixes';
            },
          ),
          _mvpCard(
            title: 'BOWLER OF THE MATCH',
            player: bestBowler,
            fallbackLabel: 'To be decided',
            statBuilder: (p) {
              final wickets = p['wickets'] ?? 0;
              final runs = p['runs'] ?? 0;
              final overs = p['overs'] ?? 0;
              final eco = _getEconomy(p);
              return '$wickets-$runs ($overs ov) · Eco $eco';
            },
          ),
          _mvpCard(
            title: 'GAME-CHANGER',
            player: gameChanger,
            fallbackLabel: 'To be decided',
            statBuilder: (p) {
              final runs = p['runs'] ?? 0;
              final wickets = p['wickets'] ?? 0;
              return '$runs runs · $wickets wickets';
            },
          ),
        ],
      ),
    );
  }

  Widget _mvpCard({
    required String title,
    required Map<String, dynamic>? player,
    required String fallbackLabel,
    required String Function(Map<String, dynamic>) statBuilder,
  }) {
    final name = player?['player_name']?.toString() ?? fallbackLabel;
    final hasPlayer = player != null;
    final statsText = hasPlayer ? statBuilder(player) : 'Awaiting nomination';

    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryElectric.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.primaryElectric,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statsText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostMatchCtas() {
    final score = _match?['score'] ?? {};
    final teamAName = _match?['team_a']?['name'] ?? 'Team A';
    final teamBName = _match?['team_b']?['name'] ?? 'Team B';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryElectric),
                  foregroundColor: AppColors.primaryElectric,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create-match',
                    arguments: {
                      'teamA': teamAName,
                      'teamB': teamBName,
                    },
                  );
                },
                child: const Text(
                  'Start new match\nwith same teams',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryElectric),
              foregroundColor: AppColors.primaryElectric,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              final controller = DefaultTabController.of(context);
              controller.animateTo(2); // SCORECARD tab
            },
            child: const Text(
              'View detailed scorecard',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniRow(List<String> values, {bool isStriker = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              values[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isStriker ? AppColors.primaryElectric : AppColors.textPrimary,
              ),
            ),
          ),
          ...values.skip(1).map(
                (v) => Expanded(
              child: Text(
                v,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4.4 Over timeline & commentary
  Widget _buildOverTimelineAndCommentary() {
    final rawCommentary = _match?['commentary'];
    final commentary = (rawCommentary is List)
        ? rawCommentary
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];
    if (commentary.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No commentary available yet.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Determine current over (latest over_number)
    int currentOver = 0;
    for (final c in commentary) {
      final overNum = (c['over_number'] as num?)?.toInt() ?? 0;
      if (overNum > currentOver) currentOver = overNum;
    }

    final currentOverBalls = commentary
        .where((c) => (c['over_number'] as num?)?.toInt() == currentOver)
        .toList()
      ..sort((a, b) {
        final aBall = (a['ball_number'] as num?)?.toInt() ?? 0;
        final bBall = (b['ball_number'] as num?)?.toInt() ?? 0;
        return aBall.compareTo(bBall);
      });

    if (currentOverBalls.isEmpty) {
      return _buildCommentaryHighlights(); // Fallback to simple list
    }

    final selectedIndexLocal = (_selectedBallIndex != null && _selectedBallIndex! < currentOverBalls.length)
        ? _selectedBallIndex!
        : currentOverBalls.length - 1;
    final selectedBall = currentOverBalls[selectedIndexLocal];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Over $currentOver',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(currentOverBalls.length, (index) {
                final ball = currentOverBalls[index];
                final event = ball['event_type']?.toString();
                final runs = (ball['runs'] as num?)?.toInt();
                final label = (event != null && event.isNotEmpty)
                    ? event
                    : (runs != null ? runs.toString() : '0');
                final isSelected = index == selectedIndexLocal;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedBallIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryElectric : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryElectric : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            selectedBall['commentary_text']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Full commentary timeline
        _buildCommentaryHighlights(),
      ],
    );
  }

  Widget _buildCommentaryHighlights() {
    final commentary = List<Map<String, dynamic>>.from(_match?['commentary'] ?? []);
    if (commentary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ...commentary.map((c) => _commentaryItem(
              '${c['over_number']}.${c['ball_number']}',
              c['event_type'] ?? '',
              c['commentary_text'] ?? '',
            )),
      ],
    );
  }

  Widget _commentaryItem(String over, String event, String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(over, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (event.isNotEmpty) ...[
                const SizedBox(height: 4),
                _eventBadge(event),
              ],
            ],
          ),
          const SizedBox(width: 16),
           Expanded(child: Text(text, style: const TextStyle(height: 1.4, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _eventBadge(String event) {
    Color bg = Colors.grey;
    if (event == 'W') bg = AppColors.accentSunset;
    if (event == '4') bg = AppColors.primaryElectric;
    if (event == '6') bg = Colors.purple;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(child: Text(event, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
    );
  }

  // --- SCORECARD TAB ---
  Widget _buildScorecardTab() {
    final score = _match?['score'];
    final teamA = _getTeamName(_match?['team_a'], 'Team A');
    final teamB = _getTeamName(_match?['team_b'], 'Team B');
    
    final teamAScore = '${score?['team_a_score'] ?? 0}-${score?['team_a_wkts'] ?? 0} (${score?['team_a_overs'] ?? 0})';
    final teamBScore = '${score?['team_b_score'] ?? 0}-${score?['team_b_wkts'] ?? 0} (${score?['team_b_overs'] ?? 0})';

    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _inningsSection(teamA, teamAScore, 0),
            if (_expandedInnings == 0) _buildInningsContent(0),
            _inningsSection(teamB, teamBScore, 1),
            if (_expandedInnings == 1) _buildInningsContent(1),
          ],
        ),
      ),
    );
  }

  Widget _inningsSection(String team, String score, int index) {
    bool isExpanded = _expandedInnings == index;
    return InkWell(
      onTap: () {
        setState(() {
          if (_expandedInnings == index) {
            _expandedInnings = -1; // Collapse if already open
          } else {
            _expandedInnings = index; // Expand if closed
          }
        });
      },
      child: Container(
        color: isExpanded ? AppColors.primaryElectric.withOpacity(0.9) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(team, style: TextStyle(color: isExpanded ? Colors.white : Colors.black, fontWeight: FontWeight.normal)),
             Row(
               children: [
                 Text(score, style: TextStyle(color: isExpanded ? Colors.white : Colors.black, fontWeight: FontWeight.normal)),
                 Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: isExpanded ? Colors.white : AppColors.textSecondary),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildInningsContent(int inningsIndex) {
    final teamAId = _match?['team_a']?['id'];
    final teamBId = _match?['team_b']?['id'];
    final targetId = inningsIndex == 0 ? teamAId : teamBId;

    final playerStats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    final inningsBatters = playerStats.where((p) => p['team_id'] == targetId && (p['balls'] ?? 0) > 0).toList();
    final inningsBowlers = playerStats.where((p) => p['team_id'] != targetId && (p['overs'] ?? 0) > 0).toList();

    return Column(
      children: [
        _buildMiniHeader(['Batter', 'R', 'B', '4s', '6s', 'SR']),
        ...inningsBatters.map((p) => _battingRow(
          p['player_name'] ?? 'Unknown',
          p['is_out'] == true ? (p['dismissal_text'] ?? 'out') : 'not out',
          (p['runs'] ?? 0).toString(),
          (p['balls'] ?? 0).toString(),
          (p['fours'] ?? 0).toString(),
          (p['sixes'] ?? 0).toString(),
          _getStrikeRate(p)
        )),
        const Divider(height: 1),
        _buildMiniHeader(['Bowler', 'O', 'M', 'R', 'W', 'ER']),
        ...inningsBowlers.map((p) => _bowlingRow(
          p['player_name'] ?? 'Unknown',
          (p['overs'] ?? 0).toString(),
          '0',
          (p['runs'] ?? 0).toString(),
          (p['wickets'] ?? 0).toString(),
          _getEconomy(p)
        )),
      ],
    );
  }

  Widget _didNotBatSection(String players) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Did not bat', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black)),
          const SizedBox(height: 8),
          Text(players, style: const TextStyle(color: Colors.black, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _battingRow(String name, String desc, String r, String b, String f, String s, String sr) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal)),
                Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              ],
            ),
          ),
          Expanded(child: Text(r, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black))),
          Expanded(child: Text(b, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
          Expanded(child: Text(f, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
          Expanded(child: Text(s, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
          Expanded(child: Text(sr, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
        ],
      ),
    );
  }

  Widget _bowlingRow(String name, String o, String m, String r, String w, String er) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal))),
          Expanded(child: Text(o, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
          Expanded(child: Text(m, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
          Expanded(child: Text(r, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
          Expanded(child: Text(w, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black))),
          Expanded(child: Text(er, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black))),
        ],
      ),
    );
  }

  Widget _buildExtraTotal(String extras, String total) {
    return Column(
      children: [
        _infoRow('Extras', extras),
        _infoRow('Total', total, isBold: true),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black))),
        ],
      ),
    );
  }

  // --- SQUADS TAB ---
  Widget _buildSquadsTab() {
    final teamA = _match?['team_a']?['name'] ?? 'Team A';
    final teamB = _match?['team_b']?['name'] ?? 'Team B';
    final teamAId = _match?['team_a']?['id'];
    final teamBId = _match?['team_b']?['id'];
    
    final playerStats = List<Map<String, dynamic>>.from(_match?['playerStats'] ?? []);
    final squadA = playerStats.where((p) => p['team_id'] == teamAId).toList();
    final squadB = playerStats.where((p) => p['team_id'] == teamBId).toList();

    final maxLen = squadA.length > squadB.length ? squadA.length : squadB.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.withOpacity(0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(Icons.shield, size: 20, color: AppColors.primaryElectric), const SizedBox(width: 8), Text(teamA, style: const TextStyle(fontWeight: FontWeight.bold))]),
              Row(children: [Text(teamB, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), const Icon(Icons.shield, size: 20, color: AppColors.accentSunset)]),
            ],
          ),
        ),
        _buildSquadTitle('Squad Players'),
        Expanded(
          child: ListView.builder(
            itemCount: maxLen,
            itemBuilder: (context, index) {
              final pA = index < squadA.length ? squadA[index] : null;
              final pB = index < squadB.length ? squadB[index] : null;
              return _squadRow(
                pA?['player_name'] ?? (pA != null ? 'Player' : ''),
                pA != null ? 'Team A' : '',
                pB?['player_name'] ?? (pB != null ? 'Player' : ''),
                pB != null ? 'Team B' : '',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSquadTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.withOpacity(0.02),
      child: Center(child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))),
    );
  }

  Widget _squadTotalRow(String title) {
    return _buildSquadTitle(title);
  }

  Widget _squadRow(String p1, String r1, String p2, String r2) {
    return Row(
      children: [
        Expanded(child: _playerItem(p1, r1, false)),
        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.1)),
        Expanded(child: _playerItem(p2, r2, true)),
      ],
    );
  }

  Widget _playerItem(String name, String role, bool right) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: right ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!right) ...[const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person, size: 20, color: Colors.white)), const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(role, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          if (right) ...[const SizedBox(width: 12), const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person, size: 20, color: Colors.white))],
        ],
      ),
    );
  }

  // --- OVERS TAB ---
  Widget _buildOversTab() {
    final commentary = List<Map<String, dynamic>>.from(_match?['commentary'] ?? []);
    if (commentary.isEmpty) {
      return const Center(child: Text('No overs data yet.'));
    }

    // Group by over number
    final Map<int, List<Map<String, dynamic>>> oversGroups = {};
    for (var ball in commentary) {
      final overNum = (ball['over_number'] as num?)?.toInt() ?? 0;
      oversGroups.putIfAbsent(overNum, () => []).add(ball);
    }

    final sortedOverNums = oversGroups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      itemCount: sortedOverNums.length,
      itemBuilder: (context, index) {
        final overNum = sortedOverNums[index];
        final balls = oversGroups[overNum]!;
        final ballEvents = balls.map((b) => b['event_type']?.toString() ?? '0').toList();
        final runs = balls.fold<int>(0, (sum, b) => sum + (((b['runs'] as num?)?.toInt()) ?? 0));
        
        return _overDetailCard(
          'Ov $overNum',
          'Details for over $overNum',
          '$runs runs',
          ballEvents,
        );
      },
    );
  }

  Widget _overDetailCard(String over, String desc, String runs, List<String> balls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(over, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(runs, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.black87, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: balls.map((b) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _eventBadge(b),
                )).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // --- HIGHLIGHTS TAB ---
  Widget _buildHighlightsTab() {
    final commentary = List<Map<String, dynamic>>.from(_match?['commentary'] ?? []);
    final highlights = commentary.where((c) {
      final event = c['event_type']?.toString();
      return event == 'W' || event == '4' || event == '6';
    }).toList();

    if (highlights.isEmpty) {
      return const Center(child: Text('No major highlights yet.'));
    }

    return ListView.builder(
      itemCount: highlights.length,
      itemBuilder: (context, index) {
        final c = highlights[index];
        return _commentaryItem(
          '${c['over_number']}.${c['ball_number']}',
          c['event_type'] ?? '',
          c['commentary_text'] ?? '',
        );
      },
    );
  }

  // --- ANALYSIS TAB ---
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildAnalysisHeader('3D WAGON WHEEL'),
          const SizedBox(height: 16),
          _buildWagonWheel(),
          const SizedBox(height: 40),
          _buildAnalysisHeader('3D RUN RATE TRANSITION'),
          const SizedBox(height: 16),
          _buildRunRateChart(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAnalysisHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryElectric,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWagonWheel() {
    return Container(
      height: 320,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _WagonWheelPainter(),
      ),
    );
  }

  Widget _buildRunRateChart() {
    return Container(
      height: 240,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryElectric.withOpacity(0.05),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryElectric.withOpacity(0.1)),
      ),
      child: CustomPaint(
        painter: _RunRatePainter(),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  const _PillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundCard),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _WagonWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Grass Background (3D styled)
    final fieldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withOpacity(0.1),
          const Color(0xFF059669).withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, fieldPaint);
    
    // Boundary line
    final boundaryPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, boundaryPaint);

    // Pitch (3D styled)
    final pitchPaint = Paint()..color = const Color(0xFFFDE68A).withOpacity(0.8);
    final pitchRect = Rect.fromCenter(center: center, width: 24, height: 60);
    canvas.drawRRect(RRect.fromRectAndRadius(pitchRect, const Radius.circular(4)), pitchPaint);

    // Shots (3D styled strokes)
    final shotPaint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final List<Map<String, dynamic>> shots = [
      {'angle': 0.5, 'dist': 0.8, 'type': '4', 'color': Colors.blue},
      {'angle': 1.2, 'dist': 0.95, 'type': '6', 'color': Colors.purple},
      {'angle': -0.8, 'dist': 0.6, 'type': '1', 'color': Colors.grey},
      {'angle': 3.5, 'dist': 0.85, 'type': '4', 'color': Colors.blue},
      {'angle': -2.5, 'dist': 0.7, 'type': '2', 'color': Colors.orange},
    ];

    for (var shot in shots) {
      final angle = shot['angle'] as double;
      final dist = shot['dist'] as double;
      final color = shot['color'] as Color;
      
      final endPoint = Offset(
        center.dx + radius * dist * (angle).clamp(-1, 1), 
        center.dy + radius * dist * (1 - angle.abs()).clamp(-1, 1),
      );

      // Shadow for 3D depth
      shotPaint.color = Colors.black.withOpacity(0.1);
      canvas.drawLine(center + const Offset(2, 2), endPoint + const Offset(2, 2), shotPaint);

      // Actual shot line
      shotPaint.color = color.withOpacity(0.8);
      canvas.drawLine(center, endPoint, shotPaint);

      // Hit point
      canvas.drawCircle(endPoint, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RunRatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final List<double> values = [4, 6, 5, 8, 7, 9, 6, 11, 8, 10];
    
    final stepX = size.width / (values.length - 1);
    final maxY = 15.0;

    path.moveTo(0, size.height - (values[0] / maxY) * size.height);

    for (int i = 1; i < values.length; i++) {
        final x = i * stepX;
        final y = size.height - (values[i] / maxY) * size.height;
        path.lineTo(x, y);
    }

    // 3D Depth Shadow Path
    final shadowPath = path.shift(const Offset(0, 10));
    
    final shadowPaint = Paint()
      ..color = AppColors.primaryElectric.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawPath(shadowPath, shadowPaint);

    // Main Run Rate Line
    paint.shader = LinearGradient(
      colors: [AppColors.primaryElectric, AppColors.accentSunset],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, paint);

    // Area under the curve (3D-ish gradient)
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primaryElectric.withOpacity(0.15),
          Colors.white.withOpacity(0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
