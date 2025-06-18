import '../domain/repositories/tour_repository.dart';
import '../../domain/entities/tour_package.dart';

class SaveTourPackageUseCase {
  final TourRepository tourRepository;

  SaveTourPackageUseCase(this.tourRepository);

  Future<bool> saveTourPackage(TourPackage tourPackage) async {
    try {
      final bool response = await tourRepository.saveTourPackage(tourPackage);
      return response; // Devuelve el objeto User
    } catch (e) {
      return false; // Devuelve null en caso de error
    }
  }
}