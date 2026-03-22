import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SelectInningsPlayerScreen extends StatefulWidget {
  final String teamName;
  final List<String> squad;
  final String roleLabel; // e.g. Striker, Non-striker, Bowler
  final Set<String> exclude;

  const SelectInningsPlayerScreen({
    super.key,
    required this.teamName,
    required this.squad,
    required this.roleLabel,
    this.exclude = const <String>{},
  });

  @override
  State<SelectInningsPlayerScreen> createState() => _SelectInningsPlayerScreenState();
}

class _SelectInningsPlayerScreenState extends State<SelectInningsPlayerScreen> {
  late List<String> _players;
  int _tabIndex = 0; // 0=select, 1=add new
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

  List<String> get _eligiblePlayers {
    final exclude = widget.exclude;
    return _players.where((p) => p.trim().isNotEmpty && !exclude.contains(p)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Select ${widget.roleLabel} for ${widget.teamName}';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Column(
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

  Widget _tabChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
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
    final players = _eligiblePlayers;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: players.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Playing squad',
              style: TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        }

        final name = players[index - 1];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.person, color: AppColors.textSecondary),
            title: Text(name),
            trailing: _selectedName == name ? const Icon(Icons.check, color: AppColors.primaryTeal) : null,
            onTap: () {
              setState(() => _selectedName = name);
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
                if (_players.contains(name)) {
                  setState(() => _selectedName = name);
                  return;
                }
                setState(() {
                  _players.add(name);
                  _selectedName = name;
                  _tabIndex = 0;
                });
                _newPlayerController.clear();
              },
              child: const Text('Add to squad'),
            ),
          ),
        ],
      ),
    );
  }
}

