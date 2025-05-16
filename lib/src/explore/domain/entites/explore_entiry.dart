import 'package:equatable/equatable.dart';
import 'package:new_tuneflow/core/common/models/models.dart';

class ExploreEntiry extends Equatable {
  final String? id;
  final String? title;
  final String? subtitle;
  final String? type;
  final String? image;
  final String? permaUrl;
  final MoreInformationEntity? moreInfo;
  final String? explicitContent;
  final bool? miniObj;
  final bool? isGotSongs;
  final List<SongModel>? songs;
  const ExploreEntiry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.image,
    required this.permaUrl,
    required this.moreInfo,
    required this.explicitContent,
    required this.miniObj,
    required this.isGotSongs,
    required this.songs,
  });

  factory ExploreEntiry.fromJson(Map json) {
    List songs = json['songs'];
    return ExploreEntiry(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      image: json['image'],
      permaUrl: json['permaUrl'],
      moreInfo: MoreInformationEntity.fromJson(json['moreInfo']),
      explicitContent: json['explicitContent'],
      miniObj: json['miniObj'],
      isGotSongs: json['isGotSongs'],
      songs: songs.map((e) => SongModel.fromJson(e)).toList(),
    );
  }

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

  @override
  List<Object?> get props {
    return [
      id,
      title,
      subtitle,
      type,
      image,
      permaUrl,
      moreInfo,
      explicitContent,
      miniObj,
      isGotSongs,
      songs,
    ];
  }
}

class MoreInformationEntity extends Equatable {
  final String? songCount;
  final String? firstname;
  final String? followerCount;
  final String? lastUpdated;
  final String? uid;
  const MoreInformationEntity({
    required this.songCount,
    required this.firstname,
    required this.followerCount,
    required this.lastUpdated,
    required this.uid,
  });

  factory MoreInformationEntity.fromJson(Map json) {
    return MoreInformationEntity(
      songCount: json['song_count'],
      firstname: json['firstname'],
      followerCount: json['follower_count'],
      lastUpdated: json['last_updated'],
      uid: json['uid'],
    );
  }

  Map toMap() {
    return {
      'song_count': songCount,
      'firstname': firstname,
      'follower_count': followerCount,
      'last_updated': lastUpdated,
      'uid': uid,
    };
  }

  @override
  List<Object?> get props {
    return [
      songCount,
      firstname,
      followerCount,
      lastUpdated,
      uid,
    ];
  }
}
