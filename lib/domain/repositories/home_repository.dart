import '../entities/home_response.dart';

abstract class HomeRepository {
  Future<HomeResponse?> getHomeData();
}