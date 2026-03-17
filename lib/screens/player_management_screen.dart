import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/supabase_client.dart';

class PlayerManagementScreen extends StatefulWidget {
  const PlayerManagementScreen({super.key});

  @override
  State<PlayerManagementScreen> createState() => _PlayerManagementScreenState();
}

class _PlayerManagementScreenState extends State<PlayerManagementScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _players = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.from('players').select('*, teams(name)');
      setState(() {
        _players = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading players: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('PLAYER ROSTER'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryElectric, Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryElectric))
                : _buildPlayerList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add logic for new player
        backgroundColor: AppColors.primaryElectric,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search elite players...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryElectric),
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) {
          // Add search filter logic if needed
        },
      ),
    );
  }

  Widget _buildPlayerList() {
    if (_players.isEmpty) {
      return const Center(child: Text('No players registered yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        final teamName = player['teams']?['name'] ?? 'Free Agent';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryElectric.withOpacity(0.1),
              child: Text(
                player['name']?.substring(0, 1).toUpperCase() ?? 'P',
                style: const TextStyle(color: AppColors.primaryElectric, fontWeight: FontWeight.normal),
              ),
            ),
            title: Text(player['name'] ?? 'Elite Player', style: const TextStyle(fontWeight: FontWeight.normal)),
            subtitle: Text('Team: $teamName', style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: () {}, // Profile view
          ),
        );
      },
    );
  }
}
