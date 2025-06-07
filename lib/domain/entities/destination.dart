class Destination {
  final int id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  bool isFavorite;
  final int? favoritesCount; // Opcional, solo aparece en popular

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.isFavorite,
    this.favoritesCount,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      favoritesCount: json['favorites_count'], // Puede ser null
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image_url': imageUrl,
      'isFavorite': isFavorite,
    };

    if (favoritesCount != null) {
      data['favorites_count'] = favoritesCount;
    }

    return data;
  }
}