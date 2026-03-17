import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StartInningsScreen extends StatefulWidget {
  const StartInningsScreen({super.key});

  @override
  State<StartInningsScreen> createState() => _StartInningsScreenState();
}

class _StartInningsScreenState extends State<StartInningsScreen> {
  String? _matchId;
  String? _battingTeamName;
  String? _bowlingTeamName;
  List<String> _battingSquad = [];
  List<String> _bowlingSquad = [];

  String? _striker;
  String? _nonStriker;
  String? _bowler;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    _matchId ??= args['matchId'] as String?;
    final teamA = args['teamA'] as String? ?? 'Team A';
    final teamB = args['teamB'] as String? ?? 'Team B';
    final teamASquad = (args['teamASquad'] as List?)?.cast<String>() ?? <String>[];
    final teamBSquad = (args['teamBSquad'] as List?)?.cast<String>() ?? <String>[];
    final battingSide = args['battingSide'] as String? ?? 'A'; // 'A' or 'B'

    final bool isTeamABatting = battingSide == 'A';

    _battingTeamName ??= isTeamABatting ? teamA : teamB;
    _bowlingTeamName ??= isTeamABatting ? teamB : teamA;
    if (_battingSquad.isEmpty) {
      _battingSquad = List<String>.from(isTeamABatting ? teamASquad : teamBSquad);
    }
    if (_bowlingSquad.isEmpty) {
      _bowlingSquad = List<String>.from(isTeamABatting ? teamBSquad : teamASquad);
    }
  }

  @override
  Widget build(BuildContext context) {
    final battingTeam = _battingTeamName ?? 'Batting team';
    final bowlingTeam = _bowlingTeamName ?? 'Bowling team';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: const Text('Start innings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentRed,
        onPressed: _showCaptureMomentSheet,
        child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Batting - $battingTeam',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _roleCard(
                    icon: Icons.sports_cricket,
                    label: _striker ?? 'Select striker',
                    onTap: () => _selectPlayer(role: 'Striker', isBatter: true, isForStriker: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _roleCard(
                    icon: Icons.sports_cricket_outlined,
                    label: _nonStriker ?? 'Select non-striker',
                    onTap: () => _selectPlayer(role: 'Non-striker', isBatter: true, isForStriker: false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Bowling - $bowlingTeam',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _roleCard(
              icon: Icons.sports_baseball_outlined,
              label: _bowler ?? 'Select bowler',
              onTap: () => _selectPlayer(role: 'Bowler', isBatter: false, isForBowler: true),
            ),
          ),
          const Spacer(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _roleCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              color: AppColors.backgroundLight,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final canStart = _striker != null && _nonStriker != null && _bowler != null && _matchId != null;
    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  'Match rules',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: canStart ? _startScoring : null,
                child: Container(
                  color: canStart ? AppColors.primaryTeal : AppColors.primaryTeal.withOpacity(0.4),
                  alignment: Alignment.center,
                  child: const Text(
                    'Start scoring',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPlayer({
    required String role,
    required bool isBatter,
    bool isForStriker = false,
    bool isForBowler = false,
  }) async {
    final squad = isForBowler ? _bowlingSquad : _battingSquad;
    if (squad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No players found in ${isForBowler ? 'bowling' : 'batting'} squad')),
      );
      return;
    }

    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _SelectInningsPlayerScreen(
          teamName: isForBowler ? (_bowlingTeamName ?? '') : (_battingTeamName ?? ''),
          squad: squad,
          roleLabel: role,
          isBatter: isBatter,
        ),
      ),
    );

    if (selected == null) return;

    setState(() {
      if (isForBowler) {
        _bowler = selected;
      } else if (isForStriker) {
        _striker = selected;
      } else {
        _nonStriker = selected;
      }
    });
  }

  void _startScoring() {
    if (_matchId == null) return;
    Navigator.pushReplacementNamed(
      context,
      '/live-detail',
      arguments: {
        'matchId': _matchId,
        'initialTabIndex': 1,
        'initialStrikerName': _striker,
        'initialNonStrikerName': _nonStriker,
        'initialBowlerName': _bowler,
      },
    );
  }

  void _showCaptureMomentSheet() {
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
            children: [
              const Text(
                'Capture moment of the match',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _captureOption(icon: Icons.photo_camera_outlined, label: 'Photo'),
                  _captureOption(icon: Icons.videocam_outlined, label: 'Video'),
                  _captureOption(icon: Icons.photo_library_outlined, label: 'Gallery'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _captureOption({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SelectInningsPlayerScreen extends StatefulWidget {
  final String teamName;
  final List<String> squad;
  final String roleLabel;
  final bool isBatter;

  const _SelectInningsPlayerScreen({
    super.key,
    required this.teamName,
    required this.squad,
    required this.roleLabel,
    required this.isBatter,
  });

  @override
  State<_SelectInningsPlayerScreen> createState() => _SelectInningsPlayerScreenState();
}

class _SelectInningsPlayerScreenState extends State<_SelectInningsPlayerScreen> {
  late List<String> _players;
  int _tabIndex = 0; // 0 = select, 1 = add new
  String? _selectedName;
  final TextEditingController _newPlayerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _players = List<String>.from(widget.squad);
  }

  @override
  void dispose() {
    _newPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Select ${widget.roleLabel} for ${widget.teamName}';
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _tabChip(
                    label: 'Select from below',
                    active: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _tabChip(
                    label: 'Add new',
                    active: _tabIndex == 1,
                    onTap: () => setState(() => _tabIndex = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _tabIndex == 0 ? _buildSelectList() : _buildAddNew(),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _selectedName == null
                      ? null
                      : () {
                          Navigator.pop(context, _selectedName);
                        },
                  child: const Text(
                    'Continue scoring',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip({required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primaryTeal : AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _players.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Playing squad',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }
        final name = _players[index - 1];
        final selected = _selectedName == name;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: selected ? AppColors.primaryTeal : AppColors.divider,
              ),
            ),
            tileColor: Colors.white,
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.backgroundCardAlt,
              child: Icon(Icons.person, color: AppColors.textSecondary),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            onTap: () async {
              setState(() {
                _selectedName = name;
              });
              await _showStyleDialog(name);
            },
          ),
        );
      },
    );
  }

  Widget _buildAddNew() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a new player',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _newPlayerController,
            decoration: InputDecoration(
              hintText: 'Enter player name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.divider),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final name = _newPlayerController.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  _players.add(name);
                  _selectedName = name;
                  _tabIndex = 0;
                });
                _newPlayerController.clear();
                _showStyleDialog(name);
              },
              child: const Text('Add to squad'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showStyleDialog(String name) async {
    final title = widget.isBatter ? 'Batting style' : 'Bowling style';
    final question = "What's the style of $name?";

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Batting: 2 options, Bowling: 8 options like CricHeroes
        final List<String> options = widget.isBatter
            ? ['Left hand bat', 'Right hand bat']
            : [
                'Right-arm fast',
                'Right-arm medium',
                'Left-arm fast',
                'Left-arm medium',
                'Slow left-arm orthodox',
                'Slow left-arm chinaman',
                'Right-arm Off Break',
                'Right-arm Leg Break',
              ];
        int selectedIndex = 0;

        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              title: Text(
                title,
                style: const TextStyle(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.normal,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.isBatter)
                    Row(
                      children: [
                        Expanded(
                          child: _styleOption(
                            label: options[0],
                            selected: selectedIndex == 0,
                            onTap: () => setDialogState(() => selectedIndex = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _styleOption(
                            label: options[1],
                            selected: selectedIndex == 1,
                            onTap: () => setDialogState(() => selectedIndex = 1),
                          ),
                        ),
                      ],
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.7,
                      ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return _styleOption(
                          label: options[index],
                          selected: selectedIndex == index,
                          onTap: () => setDialogState(() => selectedIndex = index),
                        );
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // In future we could persist style info; for now it's UI-only.
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _styleOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryTeal : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppColors.primaryTeal : AppColors.divider,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 18, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

