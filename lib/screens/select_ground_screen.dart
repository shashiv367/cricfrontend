import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class SelectGroundScreen extends StatefulWidget {
  const SelectGroundScreen({super.key});

  @override
  State<SelectGroundScreen> createState() => _SelectGroundScreenState();
}

class _SelectGroundScreenState extends State<SelectGroundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _currentCity = 'Hyderabad (Telangana)';

  List<Map<String, dynamic>> _grounds = [];
  bool _loading = true;
  String? _loadError;
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _fallbackGrounds = [
    {'name': 'Stadium Ground', 'area': 'Kukatpally', 'city': 'Hyderabad'},
    {'name': 'Dudekonda Cricket Arena', 'area': 'Miyapur', 'city': 'Hyderabad'},
    {'name': 'Greenfield Turf', 'area': 'Gachibowli', 'city': 'Hyderabad'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGrounds();
  }

  Future<void> _loadGrounds() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final token = supabase.auth.currentSession?.accessToken;
      if (token == null) {
        setState(() {
          _grounds = List.from(_fallbackGrounds);
          _loading = false;
        });
        return;
      }
      final res = await ApiService.listLocations(token);
      final list = res['locations'] as List<dynamic>?;
      final items = list != null
          ? list.map((e) => _locationToGround(e as Map<String, dynamic>)).toList()
          : <Map<String, dynamic>>[];
      if (mounted) {
        setState(() {
          _grounds = items.isNotEmpty ? items : List.from(_fallbackGrounds);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _grounds = List.from(_fallbackGrounds);
          _loadError = e.toString();
          _loading = false;
        });
      }
    }
  }

  Map<String, dynamic> _locationToGround(Map<String, dynamic> loc) {
    return {
      'name': loc['name']?.toString() ?? 'Unknown',
      'area': loc['address']?.toString() ?? loc['city']?.toString() ?? '—',
      'city': loc['city']?.toString() ?? '—',
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        title: const Text('Select ground'),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.backgroundWhite,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryElectric,
              indicatorWeight: 3,
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Nearby'),
                Tab(text: 'Favorites'),
                Tab(text: 'Search'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryElectric))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNearbyTab(),
                      _buildFavoritesTab(),
                      _buildSearchTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        Row(
          children: [
            const Text(
              'Nearby ',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                _currentCity,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              '  (change)',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loadError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Using cached list. Pull to retry.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ..._grounds.map(_buildGroundCard),
      ],
    );
  }

  Widget _buildGroundCard(Map<String, dynamic> ground) {
    final name = ground['name'] as String;
    final area = ground['area'] as String? ?? '—';
    final city = ground['city'] as String? ?? '—';
    final rating = ground['rating'] as double?;
    final reviews = ground['reviews'];

    return InkWell(
      onTap: () => Navigator.pop(context, name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryElectric.withOpacity(0.08),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
              child: const Icon(Icons.stadium_rounded, size: 36, color: AppColors.primaryElectric),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$area · $city',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            if (rating != null && reviews != null)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${rating.toStringAsFixed(1)}/5 · $reviews',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'No favourite grounds yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Mark grounds as favourite from match setup to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredGrounds {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _grounds;
    return _grounds.where((g) {
      final name = (g['name'] as String?)?.toLowerCase() ?? '';
      final area = (g['area'] as String?)?.toLowerCase() ?? '';
      final city = (g['city'] as String?)?.toLowerCase() ?? '';
      return name.contains(q) || area.contains(q) || city.contains(q);
    }).toList();
  }

  Widget _buildSearchResults() {
    final list = _filteredGrounds;
    if (list.isEmpty) {
      return const Center(child: Text('No grounds match your search.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final g = list[index];
        final name = g['name'] as String? ?? '';
        final area = g['area'] as String? ?? '—';
        final city = g['city'] as String? ?? '—';
        return ListTile(
          onTap: () => Navigator.pop(context, name),
          title: Text(name),
          subtitle: Text('$area · $city'),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search grounds',
                    prefixIcon: const Icon(Icons.search),
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
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }
}