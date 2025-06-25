import '../domain/repositories/rate_repository.dart';
import '../domain/entities/destination_rate.dart';

class GetRatedDestinationsUseCase {
  final RateRepository rateRepository;

  GetRatedDestinationsUseCase(this.rateRepository);

  Future<List<DestinationRate>?> getRatedDestinations() async {
    try {
      final List<DestinationRate>? response = await rateRepository.getRatedDestinations();
      return response;
    } catch (e) {
      return [];
    }
  }
}