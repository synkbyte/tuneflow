import 'dart:convert';

import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';

class SignupModel extends SignupEntity {
  const SignupModel({
    required super.status,
    required super.message,
    required super.id,
    required super.isDeleted,
  });

  factory SignupModel.fromString(String response) {
    final data = json.decode(response);
    return SignupModel(
      status: data['status'],
      message: data['message'] ?? '',
      id: data['id'] ?? 0,
      isDeleted: data['isDeleted'],
    );
  }
}
