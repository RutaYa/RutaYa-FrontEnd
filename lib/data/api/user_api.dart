import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/user.dart';
import 'common/api_constants.dart';

class UserApi {
  final String baseUrl = ApiConstants.baseUrl;

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      body: {
        'email': email,
        'contraseña': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return User.fromJson(data);
    } else {
      return null;
    }
  }

  Future<bool> register(String name, String lastname, String phone, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      body: {
        'email': email,
        'contraseña': password,
        'nombres': name,
        'apellidos': lastname,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

}