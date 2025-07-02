class RequestResponse {
  final bool success;
  final String message;

  RequestResponse({
    required this.success,
    required this.message,
  });

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    return RequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
