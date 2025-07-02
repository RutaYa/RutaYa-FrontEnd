import '../../domain/entities/request_response.dart';
import '../../domain/repositories/rate_repository.dart';

class DeleteDestinationRateUseCase {
  final RateRepository rateRepository;

  DeleteDestinationRateUseCase(this.rateRepository);

  Future<bool> deleteDestinationRated(int destinationRatedId) async {
    try {
      final response = await rateRepository.deleteRatedDestination(destinationRatedId);
      return response;
    } catch (e) {
      return false;
    }
  }
}
