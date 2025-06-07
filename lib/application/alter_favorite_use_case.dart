import '../domain/repositories/home_repository.dart';

class AlterFavoriteUseCase {
  final HomeRepository homeRepository;

  AlterFavoriteUseCase(this.homeRepository);

  Future<bool> alterFavorite(int destinationId, bool isFavorite) async {
    try {
      final bool homeResponse = await homeRepository.alterFavorite(destinationId, isFavorite);
      return homeResponse;
    } catch (e) {
      return false;
    }
  }
}