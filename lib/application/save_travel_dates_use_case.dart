import '../domain/entities/travel_calendar.dart';
import '../domain/repositories/travels_repository.dart';

class SaveTravelDatesUseCase {
  final TravelsRepository travelsRepository;

  SaveTravelDatesUseCase(this.travelsRepository);

  Future<bool> saveTravelDates(List<String> dates) async {
    try {
      final bool response = await travelsRepository.saveTravelDates(dates);
      return response; // Devuelve el objeto User
    } catch (e) {
      return false; // Devuelve null en caso de error
    }
  }
}