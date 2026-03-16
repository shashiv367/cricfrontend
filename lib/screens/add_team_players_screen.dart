import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';
import 'dart:developer' as developer;

class AddTeamPlayersScreen extends StatefulWidget {
  final String matchId;
  final String teamName;
  final String? teamId;
  final bool isTeamA;

  const AddTeamPlayersScreen({
    super.key,
    required this.matchId,
    required this.teamName,
    this.teamId,
    required this.isTeamA,
  });

  @override
  State<AddTeamPlayersScreen> createState() => _AddTeamPlayersScreenState();
}

class _AddTeamPlayersScreenState extends State<AddTeamPlayersScreen> {
  final _playerNameController = TextEditingController();
  final List<Map<String, dynamic>> _players = [];
  List<Map<String, dynamic>> _registeredPlayers = [];
  List<Map<String, dynamic>> _filteredPlayers = [];
  String? _selectedPlayerId;
  String? _actualTeamId;
  bool _loading = false;
  bool _loadingTeamId = true;
  bool _addingPlayer = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.teamId != null) {
      _actualTeamId = widget.teamId;
      _loadingTeamId = false;
      _loadExistingPlayers();
    } else {
      _fetchTeamIdAndPlayers();
    }
    _fetchRegisteredPlayers();
  }

  Future<void> _fetchRegisteredPlayers() async {
    try {
      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listPlayers(token);
      if (mounted) {
        setState(() {
          _registeredPlayers = List<Map<String, dynamic>>.from(response['players'] ?? []);
        });
      }
    } catch (e) {
      developer.log('Error fetching registered players: $e');
    }
  }

  void _onPlayerNameChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _filteredPlayers = [];
        _showSuggestions = false;
        _selectedPlayerId = null;
      });
      return;
    }

    final filtered = _registeredPlayers.where((player) {
      final name = (player['full_name'] ?? '').toString().toLowerCase();
      return name.contains(value.toLowerCase());
    }).toList();

    setState(() {
      _filteredPlayers = filtered;
      _showSuggestions = filtered.isNotEmpty;
    });
  }

  void _selectPlayer(Map<String, dynamic> player) {
    setState(() {
      _playerNameController.text = player['full_name'] ?? '';
      _selectedPlayerId = player['id'];
      _showSuggestions = false;
    });
  }

  Future<void> _fetchTeamIdAndPlayers() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getMatchDetails(token: token, matchId: widget.matchId);
      final match = response['match'] as Map<String, dynamic>?;
      
      if (match != null) {
        if (widget.isTeamA) {
          final teamA = match['team_a'] as Map<String, dynamic>?;
          _actualTeamId = teamA?['id'] as String?;
        } else {
          final teamB = match['team_b'] as Map<String, dynamic>?;
          _actualTeamId = teamB?['id'] as String?;
        }
        
        // Load existing players for this team
        _loadPlayersFromMatchData(match);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load match details: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingTeamId = false);
      }
    }
  }

  Future<void> _loadExistingPlayers() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getMatchDetails(token: token, matchId: widget.matchId);
      final match = response['match'] as Map<String, dynamic>?;
      
      if (match != null) {
        _loadPlayersFromMatchData(match);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load players: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  void _loadPlayersFromMatchData(Map<String, dynamic> match) {
    final playerStats = match['playerStats'] as List<dynamic>? ?? [];
    final currentTeamId = _actualTeamId;
    
    if (currentTeamId == null) return;

    // Filter players for the current team
    final teamPlayers = playerStats.where((stat) {
      final statMap = stat as Map<String, dynamic>;
      return statMap['team_id'] == currentTeamId;
    }).map((stat) {
      final statMap = stat as Map<String, dynamic>;
      return {
        'id': statMap['id'],
        'name': statMap['player_name'] ?? 'Unknown Player',
      };
    }).toList();

    setState(() {
      _players.clear();
      _players.addAll(teamPlayers);
    });
  }

  Future<void> _addPlayer() async {
    final playerName = _playerNameController.text.trim();
    if (playerName.isEmpty || _actualTeamId == null) return;

    setState(() => _addingPlayer = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      final response = await ApiService.addPlayerToMatch(
        token: token,
        matchId: widget.matchId,
        teamId: _actualTeamId!,
        playerName: playerName,
        playerId: _selectedPlayerId,
      );

      final playerStat = response['playerStat'] as Map<String, dynamic>?;
      if (playerStat != null) {
        setState(() {
          _players.add({
            'id': playerStat['id'],
            'name': playerName,
          });
          _playerNameController.clear();
          _selectedPlayerId = null;
          _showSuggestions = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$playerName added successfully'),
            backgroundColor: AppColors.accentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add player: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _addingPlayer = false);
      }
    }
  }

  Future<void> _removePlayer(int index) async {
    final player = _players[index];
    final playerStatId = player['id'] as String?;

    if (playerStatId == null) {
      // If no ID, just remove from local list (player was never saved)
      setState(() {
        _players.removeAt(index);
      });
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      await ApiService.deletePlayerFromMatch(
        token: token,
        matchId: widget.matchId,
        playerStatId: playerStatId,
      );

      setState(() {
        _players.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${player['name']} removed successfully'),
            backgroundColor: AppColors.accentGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove player: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _continueToNextTeam() async {
    // Fetch match details to get the other team info
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.getMatchDetails(token: token, matchId: widget.matchId);
      final match = response['match'] as Map<String, dynamic>?;

      if (match != null) {
        Map<String, dynamic>? nextTeam;
        if (widget.isTeamA) {
          // Move to Team B
          final teamB = match['team_b'] as Map<String, dynamic>?;
          nextTeam = teamB;
        } else {
          // Team B is done, navigate back to umpire dashboard or match screen
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/umpire-dashboard');
          }
          return;
        }

        if (nextTeam != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AddTeamPlayersScreen(
                matchId: widget.matchId,
                teamName: nextTeam!['name'] ?? 'Team B',
                teamId: nextTeam['id'],
                isTeamA: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to continue: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingTeamId) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        title: Text(
          '${widget.teamName} Players',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.2),
                    AppColors.backgroundCard,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      size: 48,
                      color: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.teamName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add players to this team',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCardAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_players.length} ${_players.length == 1 ? 'player' : 'players'} added',
                      style: TextStyle(
                        color: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Add Player Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add Player Input
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.15),
                          (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.person_add_rounded,
                                color: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Add Player',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: _playerNameController,
                                    style: const TextStyle(color: AppColors.textPrimary),
                                    decoration: InputDecoration(
                                      hintText: 'Enter player name',
                                      hintStyle: TextStyle(color: AppColors.textMuted),
                                      filled: true,
                                      fillColor: AppColors.backgroundCardAlt,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.backgroundCardAlt,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    onSubmitted: (_) => _addPlayer(),
                                    onChanged: _onPlayerNameChanged,
                                  ),
                                  if (_showSuggestions)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      constraints: const BoxConstraints(maxHeight: 200),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundCard,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.backgroundCardAlt),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: _filteredPlayers.length,
                                        itemBuilder: (context, index) {
                                          final player = _filteredPlayers[index];
                                          return ListTile(
                                            leading: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                              child: const Icon(Icons.person, size: 16, color: AppColors.primaryBlue),
                                            ),
                                            title: Text(
                                              player['full_name'] ?? 'Unknown',
                                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              player['email'] ?? '',
                                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                            ),
                                            onTap: () => _selectPlayer(player),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _addingPlayer ? null : _addPlayer,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: _addingPlayer
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Players List
                  if (_players.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.list_rounded,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Players (${_players.length})',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(_players.length, (index) {
                      final player = _players[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.backgroundCardAlt,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  (index + 1).toString(),
                                  style: TextStyle(
                                    color: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                player['name'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                              onPressed: () => _removePlayer(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.backgroundCardAlt),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            color: AppColors.textMuted,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No players added yet',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start adding players to build your team',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isTeamA ? AppColors.primaryBlue : AppColors.accentRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _loading ? null : _continueToNextTeam,
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.isTeamA ? 'Continue to Team B' : 'Finish',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  widget.isTeamA ? Icons.arrow_forward_rounded : Icons.check_rounded,
                                  size: 24,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

