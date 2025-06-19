import 'itinerary_item.dart';

class TourPackage {
  final int userId;
  final String title;
  final String description;
  final String startDate;
  final int days;
  final int quantity;
  final double price;
  final bool isPaid;
  final List<ItineraryItem> itinerary;

  TourPackage({
    required this.userId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.days,
    required this.quantity,
    required this.price,
    required this.isPaid,
    required this.itinerary,
  });

  factory TourPackage.fromJson(Map<String, dynamic> json) {
    List<ItineraryItem> itineraryList = [];

    if (json['itinerary'] != null) {
      itineraryList = (json['itinerary'] as List)
          .map((item) => ItineraryItem.fromJson(item))
          .toList();
    }

    return TourPackage(
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] ?? '',
      days: json['days'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: _parsePrice(json['price']),
      isPaid: json['is_paid'] ?? false,
      itinerary: itineraryList,
    );
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;

    if (price is double) {
      return price;
    } else if (price is int) {
      return price.toDouble();
    } else if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        print('Error parseando precio: $price -> $e');
        return 0.0;
      }
    }

    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate,
      'days': days,
      'quantity': quantity,
      'price': price,
      'is_paid': isPaid,
      'itinerary': itinerary.map((item) => item.toJson()).toList(),
    };
  }

}