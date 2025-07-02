import '../../domain/entities/package_rate.dart';
import '../../domain/entities/destination_rate.dart';
import '../../domain/entities/community_response.dart';
import '../../domain/entities/request_response.dart';
import '../../domain/repositories/rate_repository.dart';
import '../api/rate_api.dart';

class RateRepositoryImpl implements RateRepository {
  final RateApi rateApi;

  RateRepositoryImpl(this.rateApi);

  @override
  Future<RequestResponse> rateDestination({
    required int destinationId,
    required int stars,
    required String comment,
    required String createdAt,
  }) async {
    return await rateApi.createRatedDestination(
      destinationId: destinationId,
      stars: stars,
      comment: comment,
      createdAt: createdAt,
    );
  }

  @override
  Future<RequestResponse> ratePackage({
    required int tourPackageId,
    required int stars,
    required String comment,
    required String createdAt,
  }) async {
    return await rateApi.createRatedPackage(
      tourPackageId: tourPackageId,
      stars: stars,
      comment: comment,
      createdAt: createdAt,
    );
  }

  @override
  Future<List<PackageRate>?> getRatedPackages() async {
    return await rateApi.getRatedPackages();
  }

  @override
  Future<List<DestinationRate>?> getRatedDestinations() async {
    return await rateApi.getRatedDestinations();
  }

  @override
  Future<CommunityResponse?> getCommunityRate() async {
    return await rateApi.getCommunityRate();
  }

  @override
  Future<bool> deleteRatedDestination(int rateId) async {
    return await rateApi.deleteRatedDestination(rateId);
  }

  @override
  Future<bool> deleteRatedPackage(int rateId) async {
    return await rateApi.deleteRatedPackage(rateId);
  }
}