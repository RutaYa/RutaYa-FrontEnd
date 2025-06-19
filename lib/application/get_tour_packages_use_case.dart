import '../domain/repositories/tour_repository.dart';
import '../domain/entities/tour_package.dart';

class GetTourPackagesUseCase {
  final TourRepository tourRepository;

  GetTourPackagesUseCase(this.tourRepository);

  Future<List<TourPackage>> getTourPackages() async {
    try {
      final List<TourPackage> response = await tourRepository.getTourPackages();
      return response;
    } catch (e) {
      return [];
    }
  }
}