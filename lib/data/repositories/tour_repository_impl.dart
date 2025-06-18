import '../../domain/entities/tour_package.dart';
import '../../domain/repositories/tour_repository.dart';
import '../api/tour_api.dart';

class TourRepositoryImpl implements TourRepository {
  final TourApi tourApi;

  TourRepositoryImpl(this.tourApi);

  @override
  Future<List<TourPackage>> getTourPackages() async {
    return await tourApi.getTourPackages();
  }

  @override
  Future<bool> saveTourPackage(TourPackage tourPackage) async {
    return await tourApi.saveTourPackage(tourPackage);
  }

  @override
  Future<bool> payTourPackage(int tourId) async {
    return await tourApi.payTourPackage(tourId);
  }

  @override
  Future<bool> deleteTourPackage(int tourId) async {
    return await tourApi.deleteTourPackage(tourId);
  }
}