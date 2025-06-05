import '../domain/repositories/user_repository.dart';

class RegisterUseCase {
  final UserRepository userRepository;

  RegisterUseCase(this.userRepository);

  Future<bool> register(String firstname, String lastname, String phone, String email, String password) async {
    try {
      return await userRepository.register(firstname, lastname, phone, email, password);
    } catch (e) {
      return false;
    }
  }
}