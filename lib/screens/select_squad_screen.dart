import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SelectSquadScreen extends StatefulWidget {
  final String teamName;

  const SelectSquadScreen({super.key, required this.teamName});

  @override
  State<SelectSquadScreen> createState() => _SelectSquadScreenState();
}

class _SelectSquadScreenState extends State<SelectSquadScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _allPlayers = ['Broo', 'Hehe', 'Rohit', 'Virat', 'Rahul', 'Yuvi'];
  final Set<String> _selected = {'Broo', 'Hehe'};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredPlayers {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _allPlayers;
    return _allPlayers.where((p) => p.toLowerCase().contains(q)).toList();
  }

  void _goToAssignRoles() {
    Navigator.push<SquadSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => AssignRolesScreen(
          teamName: widget.teamName,
          players: _selected.toList(),
        ),
      ),
    ).then((result) {
      if (result != null) {
        Navigator.pop(context, result);
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
        title: Text(widget.teamName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Select squad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selected
                        ..clear()
                        ..addAll(_allPlayers);
                    });
                  },
                  child: const Text(
                    'Select all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Quick search',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.divider),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPlayersScreen(teamName: widget.teamName),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Add player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPlayers.length,
              itemBuilder: (context, index) {
                final name = _filteredPlayers[index];
                final selected = _selected.contains(name);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.backgroundCardAlt,
                      child: Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                      'Tap to select or deselect',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Checkbox(
                      value: selected,
                      activeColor: AppColors.primaryTeal,
                      onChanged: (v) {
                        setState(() {
                          if (v ?? false) {
                            _selected.add(name);
                          } else {
                            _selected.remove(name);
                          }
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selected.remove(name);
                        } else {
                          _selected.add(name);
                        }
                      });
                    },
                  ),
                );
              },
            ),
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
                  onPressed: _selected.isEmpty ? null : _goToAssignRoles,
                  child: const Text(
                    'Next',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddPlayersScreen extends StatelessWidget {
  final String teamName;

  const AddPlayersScreen({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text('Add players to $teamName'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _methodCard(
            title: 'Team link',
            subtitle: 'Easiest way to add players.\nShare this link with captain and let them add their players.',
            leadingIcon: Icons.link,
            primaryAction: 'Share',
            secondaryAction: 'WhatsApp',
          ),
          _methodCard(
            title: 'Add via phone number',
            subtitle: 'Best for adding 1 or 2 players quickly.',
            leadingIcon: Icons.phone_android,
          ),
          _methodCard(
            title: 'Add from contacts',
            subtitle: 'Best if players are already in your contacts.',
            leadingIcon: Icons.contacts_outlined,
          ),
          _methodCard(
            title: 'Team QR code',
            subtitle: 'Scan and add players directly via QR code.',
            leadingIcon: Icons.qr_code_2_outlined,
          ),
        ],
      ),
    );
  }

  Widget _methodCard({
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    String? primaryAction,
    String? secondaryAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.backgroundCardAlt,
                child: Icon(leadingIcon, color: AppColors.primaryElectric),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (primaryAction != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryElectric,
                    side: BorderSide(color: AppColors.primaryElectric),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(primaryAction),
                ),
                if (secondaryAction != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(secondaryAction),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class AssignRolesScreen extends StatefulWidget {
  final String teamName;
  final List<String> players;

  const AssignRolesScreen({
    super.key,
    required this.teamName,
    required this.players,
  });

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _captain;
  String? _keeper;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.players.isNotEmpty) {
      _captain = widget.players.first;
      _keeper = widget.players.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: Text('${widget.teamName} - captain, keeper, substitute'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Captain'),
            Tab(text: 'Wicket keeper'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRoleList(
                  title: 'Select captain',
                  selected: _captain,
                  onSelected: (name) => setState(() => _captain = name),
                ),
                _buildRoleList(
                  title: 'Select wicket keeper',
                  selected: _keeper,
                  onSelected: (name) => setState(() => _keeper = name),
                ),
              ],
            ),
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
                  onPressed: () {
                    Navigator.pop(
                      context,
                      SquadSelectionResult(
                        players: widget.players,
                        captain: _captain,
                        keeper: _keeper,
                      ),
                    );
                  },
                  child: const Text(
                    'Next – Match settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleList({
    required String title,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.players.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        final name = widget.players[index - 1];
        final isSelected = name == selected;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppColors.primaryTeal : AppColors.divider,
              ),
            ),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.backgroundCardAlt,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primaryTeal)
                : const Icon(Icons.radio_button_unchecked, color: AppColors.textSecondary),
            onTap: () => onSelected(name),
          ),
        );
      },
    );
  }
}

class SquadSelectionResult {
  final List<String> players;
  final String? captain;
  final String? keeper;

  const SquadSelectionResult({
    required this.players,
    this.captain,
    this.keeper,
  });
}

