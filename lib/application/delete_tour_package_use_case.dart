import '../domain/repositories/tour_repository.dart';
import '../../domain/entities/tour_package.dart';

class DeleteTourPackageUseCase {
  final TourRepository tourRepository;

  DeleteTourPackageUseCase(this.tourRepository);

  Future<bool> deleteTourPackage(int tourId) async {
    try {
      final bool response = await tourRepository.deleteTourPackage(tourId);
      return response; // Devuelve el objeto User
    } catch (e) {
      return false; // Devuelve null en caso de error
    }
  }
}