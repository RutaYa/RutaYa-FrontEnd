import '../../domain/repositories/travels_repository.dart';
import '../api/travel_api.dart';

class TravelsRepositoryImpl implements TravelsRepository {
  final TravelApi travelApi;

  TravelsRepositoryImpl(this.travelApi);

  @override
  Future<bool> saveTravelDates(List<String> dates) async {
    return await travelApi.saveTravelDates(dates);
  }

  @override
  Future<List<String>> getTravelDates() async {
    return await travelApi.getTravelDates();
  }
}