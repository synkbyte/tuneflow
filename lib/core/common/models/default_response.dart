part of 'models.dart';

class DefaultResponse {
  final bool status;
  final String message;
  final String? value;
  DefaultResponse({
    required this.status,
    required this.message,
    this.value,
  });

  factory DefaultResponse.fromJson(Map json) {
    return DefaultResponse(
      status: json['status'],
      message: json['message'],
      value: json['value'],
    );
  }
}
