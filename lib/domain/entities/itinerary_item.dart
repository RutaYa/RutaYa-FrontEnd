class ItineraryItem {
  final String datetime;
  final String description;

  ItineraryItem({
    required this.datetime,
    required this.description,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      datetime: json['datetime'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime,
      'description': description,
    };
  }
}