import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'dart:developer' as developer;

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _matches = [];

  @override
  void initState() {
    super.initState();
    _loadAllMatches();
  }

  Future<void> _loadAllMatches() async {
    setState(() => _isLoading = true);
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      final response = await ApiService.listMatches(token: token);
      setState(() {
        _matches = List<Map<String, dynamic>>.from(response['matches'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading matches for admin: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: const Text('Are you sure you want to delete this match? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('matches').delete().eq('id', matchId);
        _loadAllMatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete match: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('ADMIN PANEL'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryElectric, Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryElectric))
          : RefreshIndicator(
              onRefresh: _loadAllMatches,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _matches.length,
                itemBuilder: (context, index) {
                  final match = _matches[index];
                  final teamA = match['team_a_details']?['name'] ?? 'Team A';
                  final teamB = match['team_b_details']?['name'] ?? 'Team B';
                  final status = (match['status'] ?? 'scheduled').toString().toUpperCase();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        '$teamA vs $teamB',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Status: $status', style: TextStyle(color: _getStatusColor(status.toLowerCase()))),
                          Text('Match ID: ${match['id']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteMatch(match['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'live':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
