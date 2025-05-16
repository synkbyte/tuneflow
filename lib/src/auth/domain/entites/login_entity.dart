import 'package:equatable/equatable.dart';

enum UserStep { home, language, artist }

class LoginEntity extends Equatable {
  final bool status;
  final String message;
  final int? id;
  final UserStep? step;
  final Map? isDeleted;
  const LoginEntity({
    required this.status,
    required this.message,
    required this.id,
    required this.step,
    required this.isDeleted,
  });

  @override
  List<Object?> get props {
    return [status, message, id, step, isDeleted];
  }
}
