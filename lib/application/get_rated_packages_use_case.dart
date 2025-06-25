import '../domain/repositories/rate_repository.dart';
import '../domain/entities/package_rate.dart';

class GetRatedPackagesUseCase {
  final RateRepository rateRepository;

  GetRatedPackagesUseCase(this.rateRepository);

  Future<List<PackageRate>?> getRatedPackages() async {
    try {
      final List<PackageRate>? response = await rateRepository.getRatedPackages();
      return response;
    } catch (e) {
      return [];
    }
  }
}