import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/login_response.dart';
import 'common/api_constants.dart';
import '../repositories/local_storage_service.dart';

class TravelApi {
  final localStorageService = LocalStorageService();
  final String baseUrl = ApiConstants.baseUrl;

  Future<bool> saveTravelDates(List<String> dates) async {
    final userId = await localStorageService.getCurrentUserId();

    if (userId == null) {
      print('Error: No se encontró el userId');
      return false;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/travels/add/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'dates': dates,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      return false;
    }
  }

  Future<List<String>> getTravelDates() async {
    final userId = await localStorageService.getCurrentUserId();

    if (userId == null) {
      print('Error: No se encontró el userId');
      return [];
    }

    final response = await http.get(
      Uri.parse('$baseUrl/travels/user/$userId/'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> dates = jsonData['dates'] ?? [];
      return dates.cast<String>();
    } else {
      print('Error ${response.statusCode}: ${response.body}');
      return [];
    }
  }



}