import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fgtp_app_model.dart';

class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = 'No internet connection']);
}

class FgtpGamesService {
  static const String _apiUrl = 'https://api.freegametoplay.com/apps';
  static const String _currentGameName = 'Color Sudoku';

  Future<List<FgtpApp>> fetchMobileGames({bool forceRefresh = false}) async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw NoInternetException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonData['data'] as List<dynamic>;
        
        final games = data
            .map((item) => FgtpApp.fromJson(item as Map<String, dynamic>))
            .where((app) => app.name != _currentGameName)
            .toList();

        return games;
      } else {
        throw Exception('Failed to load games: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw NoInternetException('Network error: ${e.message}');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      if (e is NoInternetException) {
        rethrow;
      }
      throw Exception('Error loading games: $e');
    }
  }
}

