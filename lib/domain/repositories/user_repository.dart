import '../entities/login_response.dart';

abstract class UserRepository {
  Future<LoginResponse?> login(String email, String password);
  Future<bool> register(String firstname, String lastname, String phone, String email, String password);
}