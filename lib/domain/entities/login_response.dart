import 'user.dart';
import 'tokens.dart';
import 'user_preferences.dart';
class LoginResponse {
  final String message;
  final User user;
  final Tokens tokens;
  final UserPreferences? preferences;

  LoginResponse({
    required this.message,
    required this.user,
    required this.tokens,
    this.preferences,
  });


  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
      tokens: Tokens.fromJson(json['tokens']),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': (user as User).toJson(),
      'tokens': (tokens as Tokens).toJson(),
      if (preferences != null)
        'preferences': (preferences as UserPreferences).toJson(),
    };
  }

}