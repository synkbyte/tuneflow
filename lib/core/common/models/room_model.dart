part of 'models.dart';

class RoomModel extends Equatable {
  final String roomId;
  final String creator;
  final String creatorUserName;
  final String creatorAvatar;
  final int usersCount;
  final Map batch;
  const RoomModel({
    required this.roomId,
    required this.creator,
    required this.creatorUserName,
    required this.creatorAvatar,
    required this.usersCount,
    required this.batch,
  });

  factory RoomModel.fromJson(Map json) {
    return RoomModel(
      roomId: json['roomId'],
      creator: json['creator'],
      creatorUserName: json['creatorUserName'],
      creatorAvatar: '$imageBaseUrl${json['creatorAvatar']}',
      usersCount: json['usersCount'],
      batch: json['batch'] ?? {'hasBatch': false},
    );
  }

  @override
  List<Object> get props =>
      [roomId, creator, creatorUserName, creatorAvatar, usersCount];
}
