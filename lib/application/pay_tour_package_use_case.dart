import '../domain/repositories/tour_repository.dart';
import '../../domain/entities/tour_package.dart';

class PayTourPackageUseCase {
  final TourRepository tourRepository;

  PayTourPackageUseCase(this.tourRepository);

  Future<bool> payTourPackage(int tourId) async {
    try {
      final bool response = await tourRepository.payTourPackage(tourId);
      return response; // Devuelve el objeto User
    } catch (e) {
      return false; // Devuelve null en caso de error
    }
  }
}