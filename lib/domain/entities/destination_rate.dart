import 'destination.dart';
import 'user.dart';

class DestinationRate {
  final int id;
  final int stars;
  final String comment;
  final String createdAt;
  final Destination destination;
  final User user;

  DestinationRate({
    required this.id,
    required this.stars,
    required this.comment,
    required this.createdAt,
    required this.destination,
    required this.user
  });

  factory DestinationRate.fromJson(Map<String, dynamic> json) {
    return DestinationRate(
      id: json['id'] as int,
      stars: json['stars'] as int, // El backend usa 'stars'
      comment: json['comment'] as String? ?? '', // Manejar valores null
      createdAt: json['created_at'] as String,
      destination: Destination.fromJson(json['destination'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'stars': stars,
      'comment': comment,
      'created_at': createdAt,
      'destination': destination.toJson(),
      'user': user.toJson(),
    };

    return data;
  }
}