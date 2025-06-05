import '../domain/repositories/user_repository.dart';

class RegisterUseCase {
  final UserRepository userRepository;

  RegisterUseCase(this.userRepository);

  Future<bool> register(String name, String lastname, String phone, String email, String password) async {
    try {
      return await userRepository.register(name, lastname, phone, email, password);
    } catch (e) {
      return false;
    }
  }
}