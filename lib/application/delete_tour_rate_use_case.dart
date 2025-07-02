import '../../domain/entities/request_response.dart';
import '../../domain/repositories/rate_repository.dart';

class DeleteTourRateUseCase {
  final RateRepository rateRepository;

  DeleteTourRateUseCase(this.rateRepository);

  Future<bool> deleteTourRatedPackage(int tourRatedId) async {
    try {
      final response = await rateRepository.deleteRatedPackage(tourRatedId);
      return response;
    } catch (e) {
      return false;
    }
  }
}
