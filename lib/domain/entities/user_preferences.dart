class UserPreferences {
  final int userId;
  final DateTime? birthDate;
  final String? gender;
  final List<String> travelInterests;
  final String? preferredEnvironment;
  final String? travelStyle;
  final String? budgetRange;
  final int adrenalineLevel;
  final bool? wantsHiddenPlaces;

  UserPreferences({
    required this.userId,
    this.birthDate,
    this.gender,
    required this.travelInterests,
    this.preferredEnvironment,
    this.travelStyle,
    this.budgetRange,
    required this.adrenalineLevel,
    this.wantsHiddenPlaces,
  });

  // Método para crear una instancia de UserPreferences desde un JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] ?? 0,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      gender: json['gender'],
      travelInterests: json['travel_interests'] != null
          ? List<String>.from(json['travel_interests'])
          : [],
      preferredEnvironment: json['preferred_environment'],
      travelStyle: json['travel_style'],
      budgetRange: json['budget_range'],
      adrenalineLevel: json['adrenaline_level'] ?? 5,
      wantsHiddenPlaces: json['wants_hidden_places']
    );
  }

  // Método para crear una instancia desde la base de datos
  factory UserPreferences.fromDatabase(Map<String, dynamic> dbMap) {
    return UserPreferences(
      userId: int.parse(dbMap['user_id'].toString()),
      birthDate: dbMap['birth_date'] != null
          ? DateTime.parse(dbMap['birth_date'])
          : null,
      gender: dbMap['gender'] as String?,
      travelInterests: dbMap['travel_interests'] != null
          ? (dbMap['travel_interests'] as String).split(',')
          : [],
      preferredEnvironment: dbMap['preferred_environment'] as String?,
      travelStyle: dbMap['travel_style'] as String?,
      budgetRange: dbMap['budget_range'] as String?,
      adrenalineLevel: dbMap['adrenaline_level'] as int? ?? 5,
      wantsHiddenPlaces: dbMap['wants_hidden_places'] != null
          ? (dbMap['wants_hidden_places'] as int) == 1
          : null,
    );
  }

  // Método para convertir una instancia de UserPreferences a un JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'travel_interests': travelInterests,
      'preferred_environment': preferredEnvironment,
      'travel_style': travelStyle,
      'budget_range': budgetRange,
      'adrenaline_level': adrenalineLevel,
      'wants_hidden_places': wantsHiddenPlaces
    };
  }

  // Método para convertir a formato de base de datos
  Map<String, dynamic> toDatabaseMap() {
    return {
      'user_id': userId,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'travel_interests': travelInterests.join(','),
      'preferred_environment': preferredEnvironment,
      'travel_style': travelStyle,
      'budget_range': budgetRange,
      'adrenaline_level': adrenalineLevel,
      'wants_hidden_places': wantsHiddenPlaces != null
          ? (wantsHiddenPlaces! ? 1 : 0)
          : null,
    };
  }

}