import '../../domain/entities/home_response.dart';
import '../../domain/repositories/home_repository.dart';
import '../api/home_api.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeApi homeApi;

  HomeRepositoryImpl(this.homeApi);

  @override
  Future<HomeResponse?> getHomeData() async {
    return await homeApi.getHomeData();
  }
  @override
  Future<bool> alterFavorite(int destinationId, bool isFavorite) async {
    return await homeApi.alterFavorite(destinationId, isFavorite);
  }
}