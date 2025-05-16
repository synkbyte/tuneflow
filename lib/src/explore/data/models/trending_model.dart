import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/explore/domain/entites/trending_entity.dart';

class TrendingModel extends TrendingEntity {
  const TrendingModel({
    super.id,
    super.title,
    super.type,
    super.image,
  });

  factory TrendingModel.fromJson(Map<String, dynamic> json) {
    return TrendingModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      image: createImageLinks(json['image']),
    );
  }
}
