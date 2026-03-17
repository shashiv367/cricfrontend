import 'supabase_client.dart';
import 'api_service.dart';
import 'dart:developer' as developer;

class MatchService {
  Future<String> _createOrGetTeam(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) throw Exception('Team name required');
    final existing = await supabase
        .from('teams')
        .select('id')
        .eq('name', normalized)
        .limit(1);
    if (existing.isNotEmpty) return existing.first['id'] as String;
    final insert = await supabase
        .from('teams')
        .insert({'name': normalized})
        .select('id')
        .single();
    return insert['id'] as String;
  }

  Future<Map<String, dynamic>> createMatch({
    required String teamAName,
    required String teamBName,
    String? venue,
    int overs = 20,
    bool isPublic = true,
    DateTime? startDate,
    int? oversPerBowler,
  }) async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No active session. Please log in.');

      developer.log('🔵 [MATCH_SERVICE] Creating match via API: $teamAName vs $teamBName');
      
      final response = await ApiService.createMatch(
        token: token,
        teamAName: teamAName,
        teamBName: teamBName,
        locationName: venue,
        overs: overs,
        oversPerBowler: oversPerBowler,
        date: startDate?.toIso8601String(),
        isPublic: isPublic,
        status: 'live',
      );

      final matchId = response['matchId'] as String;
      developer.log('✅ [MATCH_SERVICE] Match created successfully: $matchId');

      return response;
    } catch (e) {
      developer.log('❌ [MATCH_SERVICE] Failed to create match: $e');
      rethrow;
    }
  }

  Future<String?> getInviteCode(String matchId) async {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No active session. Please log in.');

    // Use backend match details (bypasses client RLS issues).
    final res = await ApiService.getMatchDetails(token: token, matchId: matchId);
    final match = res['match'] as Map<String, dynamic>?;
    return match?['invite_code']?.toString();
  }

  Future<Map<String, String>> getMatchTeamIds(String matchId) async {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No active session. Please log in.');

    final res = await ApiService.getMatchDetails(token: token, matchId: matchId);
    final match = res['match'] as Map<String, dynamic>?;
    if (match == null) throw Exception('Match not found');

    final teamA = match['team_a'] as Map<String, dynamic>?;
    final teamB = match['team_b'] as Map<String, dynamic>?;
    final teamAId = teamA?['id']?.toString();
    final teamBId = teamB?['id']?.toString();

    if (teamAId == null || teamAId.isEmpty || teamBId == null || teamBId.isEmpty) {
      throw Exception('Match teams not available');
    }

    return {'A': teamAId, 'B': teamBId};
  }

  Future<void> updateScore({
    required String matchId,
    required int teamAScore,
    required int teamAWkts,
    required double teamAOvers,
    required int teamBScore,
    required int teamBWkts,
    required double teamBOvers,
    int? target,
  }) async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      if (token == null) return; // Silent fail or throw? MatchService seems to prefer silent fail for pushScore

      await ApiService.updateMatchScore(
        token: token,
        matchId: matchId,
        teamAScore: teamAScore,
        teamAWkts: teamAWkts,
        teamAOvers: teamAOvers,
        teamBScore: teamBScore,
        teamBWkts: teamBWkts,
        teamBOvers: teamBOvers,
        target: target,
      );
    } catch (e) {
      developer.log('❌ [MATCH_SERVICE] Failed to update score: $e');
      // No rethrow here to match original silent-fail-on-push behavior if desired
    }
  }

  Future<void> addPlayerStat({
    required String matchId,
    required String teamId,
    required String playerName,
    int runs = 0,
    int balls = 0,
    int fours = 0,
    int sixes = 0,
    int wickets = 0,
    double overs = 0.0,
  }) async {
    try {
      final token = supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No active session.');

      developer.log('🔵 [MATCH_SERVICE] Adding player to match via API: $playerName');
      
      // First add the player to the match
      final addResp = await ApiService.addPlayerToMatch(
        token: token,
        matchId: matchId,
        teamId: teamId,
        playerName: playerName,
      );
      
      final playerStatId = addResp['playerStat']['id'] as String;
      
      // Then update their stats if they are non-zero (though usually they are zero initially)
      if (runs > 0 || balls > 0 || fours > 0 || sixes > 0 || wickets > 0 || overs > 0) {
        await ApiService.updatePlayerStats(
          token: token,
          matchId: matchId,
          playerStatId: playerStatId,
          runs: runs,
          balls: balls,
          fours: fours,
          sixes: sixes,
          wickets: wickets,
          overs: overs,
        );
      }
      
      developer.log('✅ [MATCH_SERVICE] Player stat added/updated successfully');
    } catch (e) {
      developer.log('❌ [MATCH_SERVICE] Failed to add player stat: $e');
      rethrow;
    }
  }
}


