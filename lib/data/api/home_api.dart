import 'dart:convert';
import 'package:http/http.dart' as http;
import 'common/api_constants.dart';
import '../../domain/entities/home_response.dart';

class HomeApi {
  final String baseUrl = ApiConstants.baseUrl;

  Future<HomeResponse?> getHomeData() async {
    final userId = 2;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/home/$userId/'), // Corregido: usar interpolación en lugar de {userId}
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return HomeResponse.fromJson(data);
      } else {
        // Para debug, imprime el error
        print('Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception en HomeApi.getHomeData: $e');
      return null;
    }
  }
}