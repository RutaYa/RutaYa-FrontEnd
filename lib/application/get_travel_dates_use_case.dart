import '../domain/repositories/travels_repository.dart';

class GetTravelDatesUseCase {
  final TravelsRepository travelsRepository;

  GetTravelDatesUseCase(this.travelsRepository);

  Future<List<String>> getTravelDates() async {
    try {
      final List<String> response = await travelsRepository.getTravelDates();
      return response;
    } catch (e) {
      return [];
    }
  }
}

