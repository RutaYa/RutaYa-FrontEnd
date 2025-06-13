import '../entities/user_preferences.dart';

abstract class PreferencesRepository {
  Future<UserPreferences?> getUserPreferences();
  Future<bool> saveUserPreferences(UserPreferences userPreferences);
}