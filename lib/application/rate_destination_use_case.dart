import '../domain/repositories/rate_repository.dart';
import '../../domain/entities/request_response.dart';

class RateDestinationUseCase {
  final RateRepository rateRepository;

  RateDestinationUseCase(this.rateRepository);

  Future<RequestResponse> rateDestination(
      int destinationId,
      int stars,
      String comment,
      String createdAt,
      ) async {
    try {
      final RequestResponse rateResponse = await rateRepository.rateDestination(destinationId: destinationId, stars: stars, comment: comment, createdAt: createdAt);
      return rateResponse;
    } catch (e) {
      return RequestResponse(
        success: false,
        message: 'Error inesperado al calificar el paquete',
      );
    }
  }
}