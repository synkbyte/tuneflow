import 'package:new_tuneflow/src/explore/domain/entites/explore_entiry.dart';

class ExploreModel extends ExploreEntiry {
  const ExploreModel({
    super.id,
    super.title,
    super.subtitle,
    super.type,
    super.image,
    super.permaUrl,
    super.moreInfo,
    super.explicitContent,
    super.miniObj,
    super.isGotSongs,
    super.songs,
  });

  factory ExploreModel.fromJson(Map json) {
    return ExploreModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      image: json['image'],
      permaUrl: json['perma_url'],
      moreInfo: MoreInformationModel.fromJson(json['more_info']),
      explicitContent: json['explicit_content'],
      miniObj: json['mini_obj'],
      isGotSongs: false,
    );
  }

  @override
  Map toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'image': image,
      'permaUrl': permaUrl,
      'moreInfo': moreInfo!.toMap(),
      'explicitContent': explicitContent,
      'miniObj': miniObj,
      'isGotSongs': isGotSongs,
      'songs': songs?.map((e) => e.toJson()).toList() ?? [],
    };
  }
}

class MoreInformationModel extends MoreInformationEntity {
  const MoreInformationModel({
    super.songCount,
    super.firstname,
    super.followerCount,
    super.lastUpdated,
    super.uid,
  });

  factory MoreInformationModel.fromJson(Map json) {
    return MoreInformationModel(
      songCount: json['song_count'],
      firstname: json['firstname'],
      followerCount: json['follower_count'],
      lastUpdated: json['last_updated'],
      uid: json['uid'],
    );
  }
}
