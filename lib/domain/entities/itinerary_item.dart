class ItineraryItem {
  final String datetime;
  final String description;
  final int? order; // Añadido para manejar el campo 'order' del backend

  ItineraryItem({
    required this.datetime,
    required this.description,
    this.order,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      datetime: json['datetime'] ?? '',
      description: json['description'] ?? '',
      order: json['order'], // El backend incluye este campo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime,
      'description': description,
      if (order != null) 'order': order,
    };
  }
}