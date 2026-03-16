import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Change playing squad: team tabs, quick search, add player, squad list with
/// avatars and badges (checkmark = in squad, C = captain). Synced + Continue scoring at bottom.
class ChangePlayingSquadScreen extends StatefulWidget {
  final String? matchId;
  final String? teamAName;
  final String? teamBName;
  final List<String>? teamASquad;
  final List<String>? teamBSquad;
  final String? teamACaptain;
  final String? teamBCaptain;

  const ChangePlayingSquadScreen({
    super.key,
    this.matchId,
    this.teamAName,
    this.teamBName,
    this.teamASquad,
    this.teamBSquad,
    this.teamACaptain,
    this.teamBCaptain,
  });

  @override
  State<ChangePlayingSquadScreen> createState() => _ChangePlayingSquadScreenState();
}

class _ChangePlayingSquadScreenState extends State<ChangePlayingSquadScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _squadA = [];
  List<String> _squadB = [];
  String? _captainA;
  String? _captainB;
  bool _synced = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _squadA = List<String>.from(widget.teamASquad ?? ['Broo', 'Hehe']);
    _squadB = List<String>.from(widget.teamBSquad ?? []);
    _captainA = widget.teamACaptain ?? ( _squadA.isNotEmpty ? _squadA.first : null );
    _captainB = widget.teamBCaptain ?? ( _squadB.isNotEmpty ? _squadB.first : null );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _currentSquad => _tabController.index == 0 ? _squadA : _squadB;
  String? get _currentCaptain => _tabController.index == 0 ? _captainA : _captainB;

  List<String> get _filteredSquad {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _currentSquad;
    return _currentSquad.where((p) => p.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final teamA = widget.teamAName ?? 'Icb';
    final teamB = widget.teamBName ?? 'Hi';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        title: const Text('Change playing squad'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentRed,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          onTap: (_) => setState(() {}),
          tabs: [
            Tab(text: teamA),
            Tab(text: teamB),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Quick search',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add player – coming soon')),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text('Add player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Playing squad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredSquad.length,
              itemBuilder: (context, index) {
                final name = _filteredSquad[index];
                final isCaptain = _currentCaptain == name;
                return _squadPlayerTile(name: name, isCaptain: isCaptain);
              },
            ),
          ),
          if (_synced)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Synced', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    setState(() => _synced = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Squad synced'), backgroundColor: AppColors.accentGreen),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Continue scoring', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _squadPlayerTile({required String name, required bool isCaptain}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryTeal.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: isCaptain ? Colors.blue : AppColors.accentGreen,
                child: Text(
                  isCaptain ? 'C' : '✓',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
