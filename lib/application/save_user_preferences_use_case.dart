import '../domain/entities/user_preferences.dart';
import '../domain/repositories/preferences_repository.dart';

class SaveUserPreferencesUseCase {
  final PreferencesRepository preferencesRepository;

  SaveUserPreferencesUseCase(this.preferencesRepository);

  Future<bool> saveUserPreferences(UserPreferences userPreferences) async {
    try {
      final bool response = await preferencesRepository.saveUserPreferences(userPreferences);
      return response; // Devuelve el objeto User
    } catch (e) {
      return false; // Devuelve null en caso de error
    }
  }
}