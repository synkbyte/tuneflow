part of 'models.dart';

class UserPlaylistModel extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String image;
  final List<SongModel> songs;
  final bool isMine;
  final String playlistId;
  final String type;
  final bool isPublic;
  const UserPlaylistModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.image,
    required this.songs,
    required this.isMine,
    required this.playlistId,
    required this.type,
    required this.isPublic,
  });

  factory UserPlaylistModel.fromJson(Map json) {
    List songs = json['songs'] ?? [];

    return UserPlaylistModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      image: json['isMine'] ? formatePath(json['image']) : json['image'],
      songs: songs.map((e) => SongModel.fromJson(e)).toList(),
      isMine: json['isMine'],
      playlistId: json['playlistId'],
      type: json['type'],
      isPublic: json['isPublic'] ?? false,
    );
  }

  toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'image': image.replaceAll(imageBaseUrl, ''),
      'songs': songs.map((e) => e.toJson()).toList(),
      'isMine': isMine,
      'playlistId': playlistId,
      'type': type,
    };
  }

  @override
  List<Object> get props => [
        userId,
        name,
        image,
        songs,
        isMine,
        playlistId,
        type,
      ];
}
