import '../domain/repositories/preferences_repository.dart';
import '../domain/entities/user_preferences.dart';

class GetUserPreferences {
  final PreferencesRepository preferencesRepository;

  GetUserPreferences(this.preferencesRepository);

  Future<UserPreferences?> getUserPreferences() async {
    try {
      final UserPreferences? preferencesResponse = await preferencesRepository.getUserPreferences();
      return preferencesResponse;
    } catch (e) {
      return null;
    }
  }
}