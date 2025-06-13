import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../api/preference_api.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferenceApi preferenceApi;

  PreferencesRepositoryImpl(this.preferenceApi);

  @override
  Future<UserPreferences?> getUserPreferences() async {
    return await preferenceApi.getUserPreferences();
  }

  @override
  Future<bool> saveUserPreferences(UserPreferences userPreferences) async {
    return await preferenceApi.saveUserPreferences(userPreferences);
  }
}