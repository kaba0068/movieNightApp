import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// In http_helper.dart
class MovieApiException implements Exception {
  final String message;
  final int? statusCode;

  MovieApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'MovieApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class HttpHelper {
  static const String _baseUrl = 'https://movie-night-api.onrender.com';
  static final String? _apiKey = dotenv.env['TMDB_API_KEY'];


  // Reusable HTTP GET method with error handling
  static Future<Map<String, dynamic>> _get(String url) async {
    try {
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));  // Add timeout

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw MovieApiException(
        'Failed to load data', 
        response.statusCode
      );
    } on http.ClientException catch (e) {
      throw MovieApiException('Network error: ${e.message}');
    } on FormatException {
      throw MovieApiException('Invalid response format');
    } catch (e) {
      throw MovieApiException('Unexpected error: $e');
    }
  }

  // Session management methods
  static Future<Map<String, dynamic>> startSession(String? deviceId) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw MovieApiException('Device ID is required');
    }

    return _get('$_baseUrl/start-session?device_id=$deviceId');
  }

  static Future<Map<String, dynamic>> joinSession(String? deviceId, int code) async {
    if (deviceId == null || deviceId.isEmpty) {
      throw MovieApiException('Device ID is required');
    }
    if (code <= 0) {
      throw MovieApiException('Invalid session code');
    }

    return _get('$_baseUrl/join-session?device_id=$deviceId&code=$code');
  }

  // Movie fetching method
  static Future<Map<String, dynamic>> fetchMovies(String baseUrl) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw MovieApiException('TMDB API key not found');
    }

    final url = '$baseUrl?api_key=$_apiKey';
    return _get(url);
  }

  // Movie voting method
  static Future<Map<String, dynamic>> voteMovie({
    required String sessionId,
    required int movieId,
    required bool vote,
  }) async {
    if (sessionId.isEmpty) {
      throw MovieApiException('Session ID is required');
    }
    if (movieId <= 0) {
      throw MovieApiException('Invalid movie ID');
    }

    final url = '$_baseUrl/vote-movie?session_id=$sessionId&movie_id=$movieId&vote=$vote';
    return _get(url);
  }
}