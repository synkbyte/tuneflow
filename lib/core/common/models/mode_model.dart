part of 'models.dart';

class ModeModel {
  final String id;
  final String title;
  final String type;
  ModeModel({
    required this.id,
    required this.title,
    required this.type,
  });

  factory ModeModel.fromMap(Map map) {
    return ModeModel(
      id: map['id'],
      title: map['title'],
      type: map['type'],
    );
  }
}
