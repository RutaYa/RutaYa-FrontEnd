import 'package_rate.dart';
import 'destination_rate.dart';

class CommunityResponse {
  final List<DestinationRate> destinationRates;
  final List<PackageRate> packageRates;

  CommunityResponse({
    required this.destinationRates,
    required this.packageRates,
  });

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      destinationRates: (json['destination_rates'] as List<dynamic>)
          .map((item) => DestinationRate.fromJson(item as Map<String, dynamic>))
          .toList(),
      packageRates: (json['package_rates'] as List<dynamic>)
          .map((item) => PackageRate.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
