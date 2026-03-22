import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static Future<bool> connectionTest() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      developer.log('❌ [API] Connection test failed: $e');
      return false;
    }
  }

  static Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    developer.log('🔵 [API] Response: ${response.statusCode} for ${response.request?.url}');
    try {
      if (response.statusCode >= 200 && response.statusCode < 400) {
        if (response.statusCode == 304) {
          developer.log('⚠️ [API] 304 Not Modified');
          if (response.body.isEmpty) return {};
        }
        return json.decode(response.body);
      } else {
        final body = json.decode(response.body);
        var errorMsg = body['message'] ?? body['error'] ?? 'Request failed';
        if (errorMsg is Map) {
          errorMsg = errorMsg['message'] ?? errorMsg.toString();
        }

        developer.log('❌ [API] HTTP Error ${response.statusCode}: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      developer.log('❌ [API] Error parsing response: $e');
      if (e is FormatException) {
        final raw = response.body;
        final snippet = raw.length > 300 ? '${raw.substring(0, 300)}...' : raw;
        throw Exception('Server returned an invalid response (${response.statusCode}). ${snippet.isEmpty ? 'Empty body' : snippet}');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> signup({
    String? fullName,
    String? email,
    String? phone,
    required String password,
    String role = 'user',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: await _getHeaders(),
      body: json.encode({
        if (fullName != null) 'fullName': fullName,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
        'role': role,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    String? phone,
    String? email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: json.encode({
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updatePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-password'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? fullName,
    String? phone,
    String? email,
    String? profilePictureUrl,
    String? teamName,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (email != null) body['email'] = email;
    if (profilePictureUrl != null) body['profilePictureUrl'] = profilePictureUrl;
    if (teamName != null) body['teamName'] = teamName;
    
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _getHeaders(token: token),
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10));
    
    return await _handleResponse(response);
  }

  // Location endpoints
  static Future<Map<String, dynamic>> listLocations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/locations'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createOrGetLocation({
    required String token,
    required String name,
    String? address,
    String? city,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/locations'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'name': name,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  // Team endpoints
  static Future<Map<String, dynamic>> listTeams(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  // Player endpoints
  static Future<Map<String, dynamic>> listPlayers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getPlayerStats({
    required String token,
    required String playerId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/players/$playerId/stats'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updatePlayerStatus({
    required String token,
    String? fullName,
    String? phone,
    String? email,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/players/status'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  // Umpire endpoints
  static Future<Map<String, dynamic>> addCommentary({
    required String token,
    required String matchId,
    required int overNumber,
    required int ballNumber,
    required String eventType,
    required String commentaryText,
    int runs = 0,
    bool isWicket = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/umpire/matches/$matchId/commentary'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'over_number': overNumber,
        'ball_number': ballNumber,
        'event_type': eventType,
        'commentary_text': commentaryText,
        'runs': runs,
        'is_wicket': isWicket,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }
  static Future<Map<String, dynamic>> createMatch({
    required String token,
    required String teamAName,
    required String teamBName,
    String? locationId,
    String? locationName,
    int overs = 20,
    String? date,
    bool? isPublic,
    String? status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/umpire/matches'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'teamAName': teamAName,
        'teamBName': teamBName,
        if (locationId != null) 'locationId': locationId,
        if (locationName != null) 'locationName': locationName,
        'overs': overs,
        if (date != null) 'date': date,
        if (isPublic != null) 'isPublic': isPublic,
        if (status != null) 'status': status,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> listUmpireMatches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/umpire/matches'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMatchDetails({
    required String token,
    required String matchId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/umpire/matches/$matchId'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateMatchScore({
    required String token,
    required String matchId,
    int? teamAScore,
    int? teamAWkts,
    double? teamAOvers,
    int? teamBScore,
    int? teamBWkts,
    double? teamBOvers,
    int? target,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/score'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (teamAScore != null) 'teamAScore': teamAScore,
        if (teamAWkts != null) 'teamAWkts': teamAWkts,
        if (teamAOvers != null) 'teamAOvers': teamAOvers,
        if (teamBScore != null) 'teamBScore': teamBScore,
        if (teamBWkts != null) 'teamBWkts': teamBWkts,
        if (teamBOvers != null) 'teamBOvers': teamBOvers,
        if (target != null) 'target': target,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateMatchStatus({
    required String token,
    required String matchId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/status'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'status': status,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateMatchToss({
    required String token,
    required String matchId,
    required String tossWinnerSide,
    required String tossDecision,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/toss'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        'tossWinnerSide': tossWinnerSide,
        'tossDecision': tossDecision,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateMatchConfig({
    required String token,
    required String matchId,
    int? overs,
    bool? wwDotBall,
    bool? ww1s2s3s,
    bool? wwForMatch,
    bool? wwShotSelection,
    bool? wideLegal,
    int? wideRuns,
    bool? noballLegal,
    int? noballRuns,
    String? ignoreRules,
    String? ignoreOvers,
    String? bonusTeam,
    String? penaltyTeam,
  }) async {
    final body = <String, dynamic>{};
    if (overs != null) body['overs'] = overs;
    if (wwDotBall != null) body['wwDotBall'] = wwDotBall;
    if (ww1s2s3s != null) body['ww1s2s3s'] = ww1s2s3s;
    if (wwForMatch != null) body['wwForMatch'] = wwForMatch;
    if (wwShotSelection != null) body['wwShotSelection'] = wwShotSelection;
    if (wideLegal != null) body['wideLegal'] = wideLegal;
    if (wideRuns != null) body['wideRuns'] = wideRuns;
    if (noballLegal != null) body['noballLegal'] = noballLegal;
    if (noballRuns != null) body['noballRuns'] = noballRuns;
    if (ignoreRules != null) body['ignoreRules'] = ignoreRules;
    if (ignoreOvers != null) body['ignoreOvers'] = ignoreOvers;
    if (bonusTeam != null) body['bonusTeam'] = bonusTeam;
    if (penaltyTeam != null) body['penaltyTeam'] = penaltyTeam;

    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/config'),
      headers: await _getHeaders(token: token),
      body: json.encode(body),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> addPlayerToMatch({
    required String token,
    required String matchId,
    String? playerId,
    required String teamId,
    String? playerName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/umpire/matches/$matchId/players'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (playerId != null) 'playerId': playerId,
        'teamId': teamId,
        if (playerName != null) 'playerName': playerName,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> deletePlayerFromMatch({
    required String token,
    required String matchId,
    required String playerStatId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/umpire/matches/$matchId/players/$playerStatId'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updatePlayerStats({
    required String token,
    required String matchId,
    required String playerStatId,
    int? runs,
    int? balls,
    int? fours,
    int? sixes,
    int? wickets,
    double? overs,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/umpire/matches/$matchId/player-stats/$playerStatId'),
      headers: await _getHeaders(token: token),
      body: json.encode({
        if (runs != null) 'runs': runs,
        if (balls != null) 'balls': balls,
        if (fours != null) 'fours': fours,
        if (sixes != null) 'sixes': sixes,
        if (wickets != null) 'wickets': wickets,
        if (overs != null) 'overs': overs,
      }),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  // User endpoints
  static Future<Map<String, dynamic>> listMatches({
    String? token,
    String? status,
    int limit = 50,
  }) async {
    final uri = Uri.parse('$baseUrl/user/matches').replace(queryParameters: {
      if (status != null) 'status': status,
      'limit': limit.toString(),
    });
    final response = await http.get(
      uri,
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getMatchScoreboard({
    String? token,
    required String matchId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/matches/$matchId/scoreboard'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 30));
    return await _handleResponse(response);
  }

  /// GET /api/umpire/community - list umpires for assign/invite
  static Future<Map<String, dynamic>> listUmpires(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/umpire/community'),
      headers: await _getHeaders(token: token),
    ).timeout(const Duration(seconds: 10));
    return await _handleResponse(response);
  }
}
