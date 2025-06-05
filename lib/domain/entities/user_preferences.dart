class UserPreferences {
  final String theme;
  final String language;
  final bool notifications;

  UserPreferences({
    required this.theme,
    required this.language,
    required this.notifications,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'light',
      language: json['language'] ?? 'es',
      notifications: json['notifications'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'language': language,
      'notifications': notifications,
    };
  }
}