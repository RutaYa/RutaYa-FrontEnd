import 'destination.dart';

class Category {
  final int id;
  final String name;
  final List<Destination> destinations;

  Category({
    required this.id,
    required this.name,
    required this.destinations,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      destinations: (json['destinations'] as List<dynamic>?)
          ?.map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'destinations': destinations.map((item) => item.toJson()).toList(),
    };
  }
}