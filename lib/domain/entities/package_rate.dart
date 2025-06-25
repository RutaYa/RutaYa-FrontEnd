import 'tour_package.dart';
import 'user.dart';

class PackageRate {
  final int id;
  final int stars;
  final String comment;
  final String createdAt;
  final TourPackage tourPackage;
  final User user;

  PackageRate({
    required this.id,
    required this.stars,
    required this.comment,
    required this.createdAt,
    required this.tourPackage,
    required this.user
  });

  factory PackageRate.fromJson(Map<String, dynamic> json) {
    return PackageRate(
      id: json['id'] as int,
      stars: json['stars'] as int,
      comment: json['comment'] as String? ?? '', // Manejar valores null
      createdAt: json['created_at'] as String,
      tourPackage: TourPackage.fromJson(json['tour_package'] as Map<String, dynamic>),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'stars': stars,
      'comment': comment,
      'created_at': createdAt,
      'tour_package': tourPackage.toJson(),
      'user': user.toJson(),
    };

    return data;
  }
}