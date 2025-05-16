import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/explore/domain/entites/for_you_entiry.dart';

class ForYouModel extends ForYouEntity {
  const ForYouModel({
    super.id,
    super.title,
    super.type,
    super.image,
  });

  factory ForYouModel.fromJson(Map<String, dynamic> json) {
    return ForYouModel(
      id: json['id'],
      title: filteredText(json['title']),
      type: json['type'],
      image: createImageLinks(json['image']),
    );
  }
}
