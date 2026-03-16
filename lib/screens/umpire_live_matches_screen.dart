import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'umpire_match_detail_screen.dart';
import 'umpire_match_management_screen.dart';

class UmpireLiveMatchesScreen extends StatefulWidget {
  const UmpireLiveMatchesScreen({super.key});

  @override
  State<UmpireLiveMatchesScreen> createState() => _UmpireLiveMatchesScreenState();
}

class _UmpireLiveMatchesScreenState extends State<UmpireLiveMatchesScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listUmpireMatches(token);
      setState(() {
        _matches = List<Map<String, dynamic>>.from(response['matches'] ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load matches: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: const Text(
          'My Matches',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMatches,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : _matches.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _loadMatches,
                  color: AppColors.primaryPurple,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryPurple.withOpacity(0.2),
                                AppColors.backgroundWhite,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryPurple.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.sports_cricket_rounded,
                                  color: AppColors.primaryPurple,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Matches',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_matches.length}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Matches List
                        ...List.generate(_matches.length, (index) {
                          return _matchCard(_matches[index], index);
                        }),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.sports_cricket_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Matches Yet',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first match to get started',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UmpireMatchManagementScreen()),
              ).then((_) => _loadMatches());
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Create Match'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchCard(Map<String, dynamic> match, int index) {
    final teamA = match['team_a'] is Map ? match['team_a']['name'] : 'Team A';
    final teamB = match['team_b'] is Map ? match['team_b']['name'] : 'Team B';
    final status = match['status'] ?? 'live';
    final location = match['location'];
    final locationName = location is Map ? location['name'] : null;
    final overs = match['overs'] ?? 20;
    
    final statusColor = status == 'live'
        ? AppColors.accentRed
        : status == 'completed'
            ? AppColors.accentGreen
            : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.backgroundWhiteAlt),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UmpireMatchDetailScreen(matchId: match['id'].toString()),
            ),
          ).then((_) => _loadMatches());
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Badge and Overs
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == 'live')
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 14,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$overs overs',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Team Names
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'A',
                                  style: TextStyle(
                                    color: AppColors.primaryPurple,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                teamA,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                teamB,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.accentRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'B',
                                  style: TextStyle(
                                    color: AppColors.accentRed,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (locationName != null) ...[
                const SizedBox(height: 16),
                Divider(color: AppColors.backgroundWhiteAlt),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
