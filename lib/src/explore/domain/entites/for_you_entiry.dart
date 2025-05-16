import 'package:equatable/equatable.dart';
import 'package:new_tuneflow/core/common/models/models.dart';

class ForYouEntity extends Equatable {
  final String? id;
  final String? title;
  final String? type;
  final MediaFormat? image;
  const ForYouEntity({
    this.id,
    this.title,
    this.type,
    this.image,
  });

  @override
  List<Object?> get props {
    return [
      id,
      title,
      type,
      image,
    ];
  }
}
