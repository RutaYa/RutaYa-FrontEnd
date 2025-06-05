import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/login_response.dart';
import 'common/api_constants.dart';

class UserApi {
  final String baseUrl = ApiConstants.baseUrl;

  Future<LoginResponse?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return LoginResponse.fromJson(data);
    } else {
      // Para debug, imprime el error
      print('Error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  Future<bool> register(String firstname, String lastname, String phone, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      body: {
        'email': email,
        'password': password,
        'first_name': firstname,
        'last_name': lastname,
        'phone': phone,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

}