import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/match_service.dart';
import '../widgets/innings_logo.dart';
import 'select_squad_screen.dart';
import 'match_officials_screen.dart';
import '../config/app_config.dart';
import '../services/supabase_client.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _matchService = MatchService();
  bool _argsApplied = false;
  bool _authChecked = false;

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

  Future<void> _ensureLoggedIn() async {
    if (_isLoggedIn) return;
    final shouldLogin = await _showLoginRequiredDialog();
    if (!mounted) return;
    if (shouldLogin) {
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
    }
  }

  int scoreA = 0;
  int scoreB = 0;
  int wicketsA = 0;
  int wicketsB = 0;
  double oversA = 0.0;
  double oversB = 0.0;
  String? matchId;
  String? teamAName;
  String? teamBName;
  bool saving = false;
  bool isPublic = true;
  String? inviteCode;
  SquadSelectionResult? _teamASquad;
  SquadSelectionResult? _teamBSquad;
  String? _groundName;
  final TextEditingController _oversController = TextEditingController(text: '20');
  final TextEditingController _oversPerBowlerController = TextEditingController(text: '2');
  DateTime _matchDateTime = DateTime.now();
  String _matchType = 'Limited Overs';
  String _ballType = 'Tennis';
  bool _wagonWheelEnabled = true;
  String _pitchType = 'TURF';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_authChecked) {
      _authChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureLoggedIn();
      });
    }

    if (!_argsApplied) {
      _argsApplied = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['teamA'] != null) _teamAController.text = args['teamA'].toString();
        if (args['teamB'] != null) _teamBController.text = args['teamB'].toString();
        if (args['teamASquad'] is SquadSelectionResult) {
          _teamASquad = args['teamASquad'] as SquadSelectionResult;
        }
        if (args['teamBSquad'] is SquadSelectionResult) {
          _teamBSquad = args['teamBSquad'] as SquadSelectionResult;
        }
        if (args['groundName'] is String) {
          _groundName = args['groundName'] as String;
        }
      }
    }
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _oversController.dispose();
    _oversPerBowlerController.dispose();
    super.dispose();
  }

  void _incrementScore(bool isA, int runs) {
    setState(() {
      if (isA) {
        scoreA += runs;
      } else {
        scoreB += runs;
      }
    });
    _pushScore();
  }

  void _incrementWicket(bool isA) {
    setState(() {
      if (isA) {
        wicketsA = (wicketsA + 1).clamp(0, 10);
      } else {
        wicketsB = (wicketsB + 1).clamp(0, 10);
      }
    });
    _pushScore();
  }

  void _incrementOver(bool isA) {
    setState(() {
      if (isA) {
        oversA += 0.1;
        if ((oversA * 10 % 10).round() > 5) oversA = (oversA.truncateToDouble() + 1);
      } else {
        oversB += 0.1;
        if ((oversB * 10 % 10).round() > 5) oversB = (oversB.truncateToDouble() + 1);
      }
    });
    _pushScore();
  }

  Future<void> _pushScore() async {
    if (matchId == null) return;
    try {
      await _matchService.updateScore(
        matchId: matchId!,
        teamAScore: scoreA,
        teamAWkts: wicketsA,
        teamAOvers: oversA,
        teamBScore: scoreB,
        teamBWkts: wicketsB,
        teamBOvers: oversB,
      );
    } catch (_) {
      // ignore for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient Header
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryElectric, AppColors.primaryPurpleDark],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: InningsLogo(height: 45),
                  ),
                ),
              ),
            ),
            backgroundColor: AppColors.primaryElectric,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('CREATE MATCH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, letterSpacing: 1.2, fontSize: 16)),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final id = await _saveMatch();
                          if (!mounted || id == null) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Match saved.'),
                              backgroundColor: AppColors.accentGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Match Info
                  _buildSectionLabel('MATCH TEAMS'),
                  const SizedBox(height: 16),
                  
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _modernInputCard(
                          controller: _teamAController,
                          label: 'TEAM A NAME',
                          icon: Icons.shield_outlined,
                          accentColor: AppColors.primaryElectric,
                        ),
                        const SizedBox(height: 16),
                        _modernInputCard(
                          controller: _teamBController,
                          label: 'TEAM B NAME',
                          icon: Icons.shield,
                          accentColor: AppColors.accentSunset,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel('MATCH DETAILS'),
                  const SizedBox(height: 12),
                  _buildMatchTypeChips(),
                  const SizedBox(height: 12),
                  _buildMatchBasicsCard(context),
                  const SizedBox(height: 24),
                  _buildSectionLabel('GROUND'),
                  const SizedBox(height: 12),
                  _buildGroundSelector(context),
                  
                  const SizedBox(height: 24),
                  _buildSectionLabel('VISIBILITY & ACCESS'),
                  const SizedBox(height: 12),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Public Match', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15)),
                          subtitle: Text(isPublic ? 'Visible to global feed' : 'Private: Invite only', style: const TextStyle(fontSize: 12)),
                          value: isPublic,
                          activeColor: AppColors.primaryElectric,
                          onChanged: (val) => setState(() => isPublic = val),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        ),
                        if (inviteCode != null) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppColors.primaryElectric.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.share, size: 18, color: AppColors.primaryElectric),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('SHARE INVITE CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: AppColors.textSecondary, letterSpacing: 1)),
                                      Text(inviteCode!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal, color: AppColors.primaryElectric, letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // Primary Action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryElectric,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.primaryElectric.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              final id = await _saveMatch();
                              if (!mounted || id == null) return;
                              Navigator.pushNamed(
                                context,
                                '/toss',
                                arguments: {
                                  'matchId': id,
                                  'teamA': teamAName ?? _teamAController.text.trim(),
                                  'teamB': teamBName ?? _teamBController.text.trim(),
                                  'teamASquad': _teamASquad?.players,
                                  'teamBSquad': _teamBSquad?.players,
                                },
                              );
                            },
                      child: saving
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                          : const Text('Next (toss)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 1.2)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Secondary Action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryElectric, width: 1.5),
                        foregroundColor: AppColors.primaryElectric,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: matchId == null ? null : _openPlayerStatsSheet,
                      child: const Text('ADD PLAYER STATS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 1)),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _modernInputCard({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: accentColor, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter name...',
              hintStyle: TextStyle(fontSize: 18, color: AppColors.textSecondary.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _proScoreCard({
    required String title,
    required int score,
    required int wickets,
    required double overs,
    required Function(int) onAddRun,
    required VoidCallback onAddWicket,
    required VoidCallback onAddOver,
    required Color accentColor,
    required bool isA,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(color: accentColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: AppColors.textPrimary, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.backgroundLight, borderRadius: BorderRadius.circular(20)),
                child: Text('${overs.toStringAsFixed(1)} OVERS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.normal, color: accentColor),
              ),
              Text(
                ' / $wickets',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _actionButton('1', () => onAddRun(1), accentColor),
                _actionButton('2', () => onAddRun(2), accentColor),
                _actionButton('4', () => onAddRun(4), accentColor, isSpecial: true),
                _actionButton('6', () => onAddRun(6), accentColor, isSpecial: true),
                _actionButton('W', onAddWicket, AppColors.accentRed, isSpecial: true),
                _actionButton('0.1+', onAddOver, Colors.grey[400]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchTypeChips() {
    final options = [
      'Limited Overs',
      'Box/Turf Cricket',
      'Pair Cricket',
      'Test Match',
      'The Hundred',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((label) {
        final bool selected = _matchType == label;
        return ChoiceChip(
          label: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
          selected: selected,
          onSelected: (_) {
            setState(() => _matchType = label);
          },
          selectedColor: AppColors.primaryTeal,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? AppColors.primaryTeal : AppColors.divider,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatchBasicsCard(BuildContext context) {
    final dt = _matchDateTime;
    final dateLabel =
        '${_weekday(dt.weekday)}, ${_monthShort(dt.month)} ${dt.day.toString().padLeft(2, '0')} ${dt.year}  ${_two(dt.hour)}:${_two(dt.minute)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overs row (No. of overs + Overs per bowler + Power play)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No. of overs',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _oversController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overs per bowler',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _oversPerBowlerController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: TextButton(
                  onPressed: _openPowerPlayConfig,
                  child: const Text(
                    'Power play >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // City / town (read-only for now)
          const Text(
            'City / town',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hyderabad (Telangana)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Date & time
          const Text(
            'Date & time',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ball type
          const Text(
            'Ball type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _ballTypeChip('Tennis'),
              _ballTypeChip('Leather'),
              _ballTypeChip('Other'),
            ],
          ),
          const SizedBox(height: 16),
          // Wagon wheel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Wagon wheel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Switch(
                value: _wagonWheelEnabled,
                activeColor: AppColors.primaryTeal,
                onChanged: (v) => setState(() => _wagonWheelEnabled = v),
              ),
            ],
          ),
          if (_wagonWheelEnabled)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Show wagon wheel for 1s, 2s & 3s',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 8),
          // Pitch type
          const Text(
            'Pitch type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pitchTypeChip('ROUGH'),
              _pitchTypeChip('CEMENT'),
              _pitchTypeChip('TURF'),
              _pitchTypeChip('ASTROTURF'),
              _pitchTypeChip('MATTING'),
            ],
          ),
          const SizedBox(height: 16),
          // Match officials
          const Text(
            'Match officials',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          children: [
                            _OfficialIcon(
                              label: 'Umpires',
                              icon: Icons.account_circle_outlined,
                              count: 1,
                              onTap: saving ? null : _openMatchOfficials,
                            ),
                            _OfficialIcon(
                              label: 'Scorers',
                              icon: Icons.receipt_long_outlined,
                              onTap: saving ? null : _openMatchOfficials,
                            ),
                            _OfficialIcon(
                              label: 'Live streamer',
                              icon: Icons.videocam_outlined,
                              onTap: saving ? null : _openMatchOfficials,
                            ),
                            _OfficialIcon(
                              label: 'Others',
                              icon: Icons.more_horiz,
                              onTap: saving ? null : _openMatchOfficials,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: saving
                            ? null
                            : () async {
                                await _openMatchOfficials();
                              },
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
        ],
      ),
    );
  }

  Widget _ballTypeChip(String label) {
    final selected = _ballType == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _ballType = label),
      selectedColor: AppColors.primaryElectric,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.primaryElectric : AppColors.divider),
    );
  }

  Widget _pitchTypeChip(String code) {
    final selected = _pitchType == code;
    return ChoiceChip(
      label: Text(
        code,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.normal,
          color: selected ? Colors.white : AppColors.textSecondary,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => _pitchType = code),
      selectedColor: AppColors.primaryElectricLight,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.primaryElectricLight : AppColors.divider),
    );
  }

  Future<void> _pickDateTime() async {
    final initialDate = _matchDateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;
    setState(() {
      _matchDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _weekday(int w) {
    switch (w) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
      default:
        return 'Sun';
    }
  }

  String _monthShort(int m) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m < 1 || m > 12) return '';
    return names[m - 1];
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  
  void _openPowerPlayConfig() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Power play',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Detailed power play configuration will be available soon.\nFor now, all overs are treated as regular overs.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionButton(String label, VoidCallback onTap, Color color, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: isSpecial ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSpecial ? Colors.white : color,
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMatchOfficials() async {
    // Ensure the match is saved before opening officials so invite sending works.
    final id = matchId ?? await _saveMatch();
    if (!mounted || id == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchOfficialsScreen(
          matchId: id,
          inviteCode: inviteCode,
        ),
      ),
    );
  }

  Future<void> _addLocationManually() async {
    final selected = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final controller = TextEditingController(text: _groundName ?? '');
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Add location', style: TextStyle(fontWeight: FontWeight.normal)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter ground / location name',
              hintStyle: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.normal)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx, name);
              },
              child: const Text('Add', style: TextStyle(fontWeight: FontWeight.normal)),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (selected != null && selected.trim().isNotEmpty) {
      setState(() => _groundName = selected.trim());
    }
  }

  Widget _buildGroundSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryElectric.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.stadium_rounded, color: AppColors.primaryElectric, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GROUND / LOCATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _groundName ?? 'Select ground',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: _groundName == null ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              final result = await Navigator.pushNamed<String>(context, '/select-ground');
              if (result != null && mounted) {
                setState(() {
                  _groundName = result;
                });
              }
            },
            child: const Text(
              'Change',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          TextButton(
            onPressed: _addLocationManually,
            child: const Text(
              'Add',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _saveMatch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return null;
    setState(() => saving = true);
    try {
      final overs = int.tryParse(_oversController.text.trim()) ?? 20;
      final resp = await _matchService.createMatch(
        teamAName: _teamAController.text.trim(),
        teamBName: _teamBController.text.trim(),
        venue: _groundName,
        overs: overs,
        isPublic: isPublic,
        startDate: _matchDateTime,
      );

      final id = resp['matchId']?.toString();
      if (id == null || id.isEmpty) throw Exception('Match id missing');
      final code = resp['inviteCode']?.toString();
      
      setState(() {
        matchId = id;
        teamAName = _teamAController.text.trim();
        teamBName = _teamBController.text.trim();
        inviteCode = (code != null && code.trim().isNotEmpty) ? code.trim() : inviteCode;
      });

      // Fetch real team UUIDs for pre-populating match players.
      final teamIds = await _matchService.getMatchTeamIds(id);
      final teamAId = teamIds['A']!;
      final teamBId = teamIds['B']!;

      // Pre-populate match with selected squad players (no stats yet).
      if (_teamASquad != null) {
        for (final name in _teamASquad!.players) {
          await _matchService.addPlayerStat(
            matchId: id,
            teamId: teamAId,
            playerName: name,
          );
        }
      }
      if (_teamBSquad != null) {
        for (final name in _teamBSquad!.players) {
          await _matchService.addPlayerStat(
            matchId: id,
            teamId: teamBId,
            playerName: name,
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Match saved. Proceed to toss.'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return id;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save match: $e\nAPI: ${AppConfig.apiBaseUrl}'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _openPlayerStatsSheet() {
    if (matchId == null) return;
    final _playerName = TextEditingController();
    final _runs = TextEditingController();
    final _balls = TextEditingController();
    final _fours = TextEditingController();
    final _sixes = TextEditingController();
    final _wickets = TextEditingController();
    final _overs = TextEditingController();
    String team = 'A';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ADD PLAYER STATS', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, letterSpacing: 1, color: AppColors.textPrimary)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _teamChoice('TEAM A', team == 'A', () => setModalState(() => team = 'A')),
                        const SizedBox(width: 12),
                        _teamChoice('TEAM B', team == 'B', () => setModalState(() => team = 'B')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _modernField(_playerName, 'Player Name', Icons.person_outline),
                    Row(
                      children: [
                        Expanded(child: _modernField(_runs, 'Runs', Icons.star_border, keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _modernField(_balls, 'Balls', Icons.timer_outlined, keyboard: TextInputType.number)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _modernField(_fours, '4s', null, keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _modernField(_sixes, '6s', null, keyboard: TextInputType.number)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _modernField(_wickets, 'Wkts', Icons.sports_cricket_outlined, keyboard: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _modernField(_overs, 'Overs', Icons.speed_outlined, keyboard: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryElectric, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        onPressed: () async {
                          try {
                            await _matchService.addPlayerStat(
                              matchId: matchId!,
                              teamId: team == 'A' ? (teamAName ?? '') : (teamBName ?? ''),
                              playerName: _playerName.text.trim(),
                              runs: int.tryParse(_runs.text) ?? 0,
                              balls: int.tryParse(_balls.text) ?? 0,
                              fours: int.tryParse(_fours.text) ?? 0,
                              sixes: int.tryParse(_sixes.text) ?? 0,
                              wickets: int.tryParse(_wickets.text) ?? 0,
                              overs: double.tryParse(_overs.text) ?? 0.0,
                            );
                            if (mounted) Navigator.pop(ctx);
                          } catch (e) {
                             // handled in MatchService
                          }
                        },
                        child: const Text('SAVE PERFORMANCE', style: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 1.2)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _teamChoice(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryElectric : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.normal, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _modernField(TextEditingController controller, String label, IconData? icon, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}


class _OfficialIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final int? count;
  final VoidCallback? onTap;

  const _OfficialIcon({required this.label, required this.icon, this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (count != null && count! > 0)
                    ? AppColors.primaryTeal.withOpacity(0.12)
                    : AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: (count != null && count! > 0) ? AppColors.primaryTeal : AppColors.textSecondary,
              ),
            ),
            if (count != null && count! > 0)
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: content,
      ),
    );
  }
}


