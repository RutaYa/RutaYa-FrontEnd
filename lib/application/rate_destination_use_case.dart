import '../domain/repositories/rate_repository.dart';

class RateDestinationUseCase {
  final RateRepository rateRepository;

  RateDestinationUseCase(this.rateRepository);

  Future<bool> rateDestination(
      int destinationId,
      int stars,
      String comment,
      String createdAt,
      ) async {
    try {
      final bool rateResponse = await rateRepository.rateDestination(destinationId: destinationId, stars: stars, comment: comment, createdAt: createdAt);
      return rateResponse;
    } catch (e) {
      return false;
    }
  }
}