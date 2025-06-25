import '../domain/repositories/rate_repository.dart';
import '../domain/entities/community_response.dart';

class GetCommunityRateUseCase {
  final RateRepository rateRepository;

  GetCommunityRateUseCase(this.rateRepository);

  Future<CommunityResponse?> getCommunityRate() async {
    try {
      final CommunityResponse? response = await rateRepository.getCommunityRate();
      return response;
    } catch (e) {
      print('Error en GetCommunityRateUseCase: $e');
      return null;
    }
  }
}
