import 'package:equatable/equatable.dart';

class SignupEntity extends Equatable {
  final bool status;
  final String message;
  final int id;
  final Map? isDeleted;
  const SignupEntity({
    required this.status,
    required this.message,
    required this.id,
    required this.isDeleted,
  });

  @override
  List<Object?> get props => [status, message, id, isDeleted];
}
