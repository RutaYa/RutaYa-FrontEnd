import '../../domain/entities/login_response.dart';
import '../../domain/repositories/user_repository.dart';
import '../api/user_api.dart';

class UserRepositoryImpl implements UserRepository {
  final UserApi userApi;

  UserRepositoryImpl(this.userApi);

  @override
  Future<LoginResponse?> login(String email, String password) async {
    return await userApi.login(email, password);
  }

  @override
  Future<bool> register(String firstname, String lastname, String phone, String email, String password) async {
    return await userApi.register(firstname, lastname, phone, email, password);
  }
}