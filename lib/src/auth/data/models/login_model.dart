import 'package:new_tuneflow/src/auth/domain/entites/login_entity.dart';

class LoginModel extends LoginEntity {
  const LoginModel({
    required super.status,
    required super.message,
    required super.id,
    required super.step,
    required super.isDeleted,
  });

  factory LoginModel.fromJson(Map json) {
    return LoginModel(
      isDeleted: json['isDeleted'],
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
      step:
          json['step'] == 'Home'
              ? UserStep.home
              : json['step'] == 'Language Selection'
              ? UserStep.language
              : UserStep.artist,
    );
  }
}
