import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user_preferences.dart';
import '../../data/repositories/local_storage_service.dart';
import 'common/api_constants.dart';

class PreferenceApi {
  final String baseUrl = ApiConstants.baseUrl;
  final localStorageService = LocalStorageService();

  Future<UserPreferences?> getUserPreferences() async {
    final int userId = await localStorageService.getCurrentUserId();

    final response = await http.get(
      Uri.parse('$baseUrl/preferences/$userId/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final prefs = responseData['preferences'] ?? responseData;

      return UserPreferences(
        birthDate: prefs['birth_date'],
        gender: prefs['gender'],
        travelInterests: List<String>.from(prefs['travel_interests']),
        preferredEnvironment: prefs['preferred_environment'],
        travelStyle: prefs['travel_style'],
        budgetRange: prefs['budget_range'],
        adrenalineLevel: prefs['adrenaline_level'],
        wantsHiddenPlaces: prefs['wants_hidden_places'],
        userId: prefs['user_id'],
      );
    } else {
      print('Error al obtener preferencias: ${response.body}');
      return null;
    }
  }

  Future<bool> saveUserPreferences(UserPreferences preferences) async {
    try {
      final int userId = await localStorageService.getCurrentUserId();
      final String fullUrl = '$baseUrl/preferences/';

      final requestBody = {
        'user_id': userId,
        'birth_date': preferences.birthDate?.toIso8601String().split('T')[0],
        'gender': preferences.gender,
        'travel_interests': preferences.travelInterests,
        'preferred_environment': preferences.preferredEnvironment,
        'travel_style': preferences.travelStyle,
        'budget_range': preferences.budgetRange,
        'adrenaline_level': preferences.adrenalineLevel,
        'wants_hidden_places': preferences.wantsHiddenPlaces,
      };

      print("=== DEBUG INFO ===");
      print("URL: $fullUrl");
      print("User ID: $userId (${userId.runtimeType})");
      print("Request Body: ${jsonEncode(requestBody)}");
      print("==================");

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Exception en saveUserPreferences: $e');
      return false;
    }
  }


}
