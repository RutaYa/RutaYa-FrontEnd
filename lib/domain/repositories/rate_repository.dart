import '../../domain/entities/package_rate.dart';
import '../../domain/entities/destination_rate.dart';
import '../../domain/entities/community_response.dart';

abstract class RateRepository {
  Future<bool> rateDestination({
    required int destinationId,
    required int stars,
    required String comment,
    required String createdAt,
  });

  Future<bool> ratePackage({
    required int tourPackageId,
    required int stars,
    required String comment,
    required String createdAt,
  });

  Future<List<PackageRate>?> getRatedPackages();
  Future<List<DestinationRate>?> getRatedDestinations();
  Future<CommunityResponse?> getCommunityRate();
}
