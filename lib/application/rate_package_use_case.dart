import '../domain/repositories/rate_repository.dart';
import '../../domain/entities/request_response.dart';

class RatePackageUseCase {
  final RateRepository rateRepository;

  RatePackageUseCase(this.rateRepository);

  Future<RequestResponse> ratePackage(
      int packageId,
      int stars,
      String comment,
      String createdAt,
      ) async {
    try {
      final RequestResponse rateResponse = await rateRepository.ratePackage(tourPackageId: packageId, stars: stars, comment: comment, createdAt: createdAt);
      return rateResponse;
    } catch (e) {
      return RequestResponse(
        success: false,
        message: 'Error inesperado al calificar el paquete',
      );
    }
  }
}