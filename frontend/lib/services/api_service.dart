import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL', 
    defaultValue: 'http://127.0.0.1:3000'
  );

  static Future<List<dynamic>> getSports() async {
    final response = await http.get(Uri.parse('$baseUrl/sports'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load sports');
  }

  static Future<List<dynamic>> getTeams() async {
    // Return mock teams if backend endpoint is missing, but try to fetch
    try {
      final response = await http.get(Uri.parse('$baseUrl/teams'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Mocking teams for UI');
    }
    return [
      {'team_id': 1, 'team_name': 'India National Team', 'sport_id': 1},
      {'team_id': 2, 'team_name': 'Real Madrid', 'sport_id': 2},
    ];
  }

  static Future<dynamic> getPlayers({int? sportId, int? playerId}) async {
    final url = playerId != null 
        ? '$baseUrl/players?id=$playerId' 
        : (sportId != null ? '$baseUrl/players?sport_id=$sportId' : '$baseUrl/players');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return playerId != null ? (data is List ? data.first : data) : data;
    }
    throw Exception('Failed to load players');
  }

  static Future<List<dynamic>> getEligiblePlayers({int? sportId}) async {
    final url = sportId != null ? '$baseUrl/eligible-players?sport_id=$sportId' : '$baseUrl/eligible-players';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load eligible players');
  }

  static Future<Map<String, dynamic>> getPlayerFullStats(int playerId) async {
    final response = await http.get(Uri.parse('$baseUrl/players/$playerId/full-stats'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load player full stats');
  }

  static Future<Map<String, dynamic>> getPlayerPerformance(int playerId) async {
    return getPlayerFullStats(playerId); 
  }

  static Future<List<dynamic>> getTopPerformers(String sportName, {String type = 'players'}) async {
    final response = await http.get(Uri.parse('$baseUrl/analysis/$sportName/top?type=$type'));
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load top performers for $sportName');
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (e) {
      print('Login connection error');
    }
    return {'success': false, 'message': 'Invalid credentials'};
  }

  static Future<dynamic> addPlayer(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/players'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }

  static Future<dynamic> addSport(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sports'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    return json.decode(response.body);
  }
}
