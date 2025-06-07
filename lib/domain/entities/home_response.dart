import 'category.dart';
import 'destination.dart';

class HomeResponse {
  final String message;
  final List<Destination> suggestions;
  final List<Destination> popular;
  final List<Category> categories;

  HomeResponse({
    required this.message,
    required this.suggestions,
    required this.popular,
    required this.categories,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      message: json['message'] ?? '',
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      popular: (json['popular'] as List<dynamic>?)
          ?.map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'suggestions': suggestions.map((item) => item.toJson()).toList(),
      'popular': popular.map((item) => item.toJson()).toList(),
      'categories': categories.map((item) => item.toJson()).toList(),
    };
  }
}