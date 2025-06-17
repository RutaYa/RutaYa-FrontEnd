import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/login_response.dart';
import '../../domain/entities/user.dart';
import 'common/api_constants.dart';
import '../../data/repositories/local_storage_service.dart';

class UserApi {
  final localStorageService = LocalStorageService();
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

  Future<bool> changePassword(String newPassword) async {
    final int userId = await localStorageService.getCurrentUserId();

    final response = await http.put(
      Uri.parse('$baseUrl/user/change-password/$userId'),
      body: {
        'new_password': newPassword,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }


  Future<bool> editProfile(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update/${user.id}'),
      body: {
        'first_name': user.firstName,
        'last_name': user.lastName,
        'phone': user.phone,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

}