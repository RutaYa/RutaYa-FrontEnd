abstract class TravelsRepository {
  Future<bool> saveTravelDates(List<String> dates);
  Future<List<String>> getTravelDates();
}