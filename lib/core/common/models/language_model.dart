part of 'models.dart';

class LanguageModel {
  int id;
  String name;
  String key;
  LanguageModel({
    required this.id,
    required this.name,
    required this.key,
  });

  factory LanguageModel.fromJson(Map json) {
    return LanguageModel(
      id: json['id'],
      name: json['name'],
      key: json['key'],
    );
  }

  toMap() {
    return {
      'id': id,
      'name': name,
      'key': key,
    };
  }
}
