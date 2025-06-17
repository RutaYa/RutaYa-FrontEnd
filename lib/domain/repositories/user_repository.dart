import '../entities/login_response.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<LoginResponse?> login(String email, String password);
  Future<bool> register(String firstname, String lastname, String phone, String email, String password);
  Future<bool> editProfile(User user);
  Future<bool> changePassword(String newPassword);
}