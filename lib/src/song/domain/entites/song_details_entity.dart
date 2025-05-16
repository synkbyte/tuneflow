import 'package:equatable/equatable.dart';
import 'package:new_tuneflow/core/common/models/models.dart';

class SongDetailsEntity extends Equatable {
  final List<SongModel> songs;
  const SongDetailsEntity({required this.songs});

  @override
  List<Object?> get props => [songs];
}
