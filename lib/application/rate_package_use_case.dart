import '../domain/repositories/rate_repository.dart';

class RatePackageUseCase {
  final RateRepository rateRepository;

  RatePackageUseCase(this.rateRepository);

  Future<bool> ratePackage(
      int packageId,
      int stars,
      String comment,
      String createdAt,
      ) async {
    try {
      final bool rateResponse = await rateRepository.ratePackage(tourPackageId: packageId, stars: stars, comment: comment, createdAt: createdAt);
      return rateResponse;
    } catch (e) {
      return false;
    }
  }
}