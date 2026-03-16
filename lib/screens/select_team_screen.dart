import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SelectTeamScreen extends StatefulWidget {
  final String title;
  final String? currentSelection;

  const SelectTeamScreen({
    super.key,
    required this.title,
    this.currentSelection,
  });

  @override
  State<SelectTeamScreen> createState() => _SelectTeamScreenState();
}

class _SelectTeamScreenState extends State<SelectTeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  // Create-your-team form (Add tab)
  final _teamNameController = TextEditingController();
  final _cityController = TextEditingController(text: 'Hyderabad (Telangana)');
  final _captainNumberController = TextEditingController();
  final _captainNameController = TextEditingController();
  bool _addMyself = false;
  static const _location = 'Hyderabad (Telangana)';

  final List<Map<String, dynamic>> _yourTeams = [
    {'name': 'Nidish P', 'location': _location, 'captain': 'Akshay Reddy', 'verified': true, 'avatarColor': null},
    {'name': 'Hi', 'location': _location, 'captain': 'Broo', 'verified': false, 'avatarColor': 0xFF3B82F6},
    {'name': 'Icb', 'location': _location, 'captain': null, 'verified': false, 'avatarColor': 0xFFF43F5E},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _teamNameController.dispose();
    _cityController.dispose();
    _captainNumberController.dispose();
    _captainNameController.dispose();
    super.dispose();
  }

  void _onAddTeamFromForm() {
    final name = _teamNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter team name'), backgroundColor: AppColors.accentSunset),
      );
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.primaryElectric,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: AppColors.backgroundWhite,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryElectric,
              indicatorWeight: 3,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Your Teams'),
                Tab(text: 'Opponents'),
                Tab(text: 'Add'),
              ],
            ),
          ),
          if (_tabController.index != 2)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Quick search',
                        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        prefixIcon: Icon(Icons.search, size: 22, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.backgroundWhite,
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
                      onTap: () => _tabController.animateTo(2),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text('Add team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamList(_yourTeams),
                _buildTeamList([]),
                _buildAddTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList(List<Map<String, dynamic>> teams) {
    if (teams.isEmpty) {
      return Center(
        child: Text('No teams', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final t = teams[index];
        return _buildTeamTile(
          name: t['name'] as String,
          location: t['location'] as String,
          captain: t['captain'] as String?,
          verified: t['verified'] as bool,
          avatarColor: t['avatarColor'] as int?,
          onTap: () => Navigator.pop(context, t['name'] as String),
        );
      },
    );
  }

  Widget _buildTeamTile({
    required String name,
    required String location,
    required String? captain,
    required bool verified,
    required int? avatarColor,
    required VoidCallback onTap,
  }) {
    final color = avatarColor != null ? Color(avatarColor) : AppColors.primaryElectric;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                  ),
                ),
                if (verified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.primaryTeal, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(location, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                  if (captain != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.backgroundCardAlt,
                          child: const Text('C', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        ),
                        const SizedBox(width: 6),
                        Text(captain, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.grid_view_rounded, color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primaryElectric.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports_cricket_rounded, size: 40, color: AppColors.primaryElectric.withOpacity(0.7)),
                            const SizedBox(height: 4),
                            Text(
                              'Team logo',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: AppColors.textPrimary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Team logo', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _teamNameController,
                  decoration: InputDecoration(
                    hintText: 'Team name *',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'City / town *',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _captainNumberController,
                  decoration: InputDecoration(
                    hintText: '+91 Team captain/coordinator number (optional)',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    suffixIcon: Icon(Icons.contact_phone_outlined, size: 22, color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _captainNameController,
                  decoration: InputDecoration(
                    hintText: 'Team captain name (optional)',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _addMyself,
                        onChanged: (v) => setState(() => _addMyself = v ?? false),
                        activeColor: AppColors.primaryElectric,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Add myself in team', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Material(
              color: AppColors.primaryTeal,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: _onAddTeamFromForm,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: const Text('Add team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
