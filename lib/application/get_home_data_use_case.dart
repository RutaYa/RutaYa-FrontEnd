import '../domain/entities/home_response.dart';
import '../domain/repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository homeRepository;

  GetHomeDataUseCase(this.homeRepository);

  Future<HomeResponse?> getHomeData() async {
    try {
      final HomeResponse? homeResponse = await homeRepository.getHomeData();
      return homeResponse; // Devuelve el objeto User
    } catch (e) {
      return null; // Devuelve null en caso de error
    }
  }
}