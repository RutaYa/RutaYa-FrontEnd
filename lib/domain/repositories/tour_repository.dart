import '../entities/tour_package.dart';

abstract class TourRepository {
  Future<List<TourPackage>> getTourPackages();
  Future<bool> saveTourPackage(TourPackage tourPackage);
  Future<bool> payTourPackage(int tourId);
  Future<bool> deleteTourPackage(int tourId);
}