import '../domain/entities/user.dart';
import '../domain/entities/login_response.dart';
import '../domain/repositories/user_repository.dart';

class LoginUseCase {
  final UserRepository userRepository;

  LoginUseCase(this.userRepository);

  Future<LoginResponse?> login(String email, String password) async {
    try {
      final LoginResponse? loginResponse = await userRepository.login(email, password);
      return loginResponse; // Devuelve el objeto User
    } catch (e) {
      return null; // Devuelve null en caso de error
    }
  }
}