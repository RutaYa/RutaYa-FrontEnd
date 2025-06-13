class TravelCalendar {
  final int userId;
  final List<String> dates;

  TravelCalendar({
    required this.userId,
    required this.dates,
  });

  factory TravelCalendar.fromJson(Map<String, dynamic> json) {
    return TravelCalendar(
      userId: json['userId'] ?? 0,
      dates: (json['dates'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'dates': dates,
    };
  }
}
