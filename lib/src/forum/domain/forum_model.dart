import 'package:new_tuneflow/core/constants/constants.dart';

class ForumModel {
  int id;
  String title;
  String content;
  int likeCount;
  int repliedCount;
  int userId;
  String userName;
  String userAvatar;
  Map batch;
  String date;
  bool isMinePost;
  bool likedStatus;
  List<PostReplyModel> postReplies;
  ForumModel({
    required this.id,
    required this.title,
    required this.content,
    required this.likeCount,
    required this.repliedCount,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.batch,
    required this.date,
    required this.isMinePost,
    required this.likedStatus,
    required this.postReplies,
  });

  factory ForumModel.fromJson(Map json) {
    List postReplies = json['postReplies'] ?? [];
    List updated = postReplies.reversed.toList();
    return ForumModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      likeCount: json['likeCount'],
      repliedCount: json['repliedCount'],
      userId: json['user']['id'],
      userName: json['user']['name'],
      userAvatar: '$imageBaseUrl${json['user']['avatar']}',
      batch: json['user'],
      date: json['date'],
      isMinePost: json['isMinePost'],
      likedStatus: json['likedStatus'],
      postReplies: updated.map((e) => PostReplyModel.fromJson(e)).toList(),
    );
  }
}

class PostReplyModel {
  int id;
  String content;
  int userId;
  String userName;
  String userAvatar;
  Map batch;
  String date;
  bool likedStatus;
  bool isMineComment;
  int likeCount;
  PostReplyModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.batch,
    required this.date,
    required this.likedStatus,
    required this.isMineComment,
    required this.likeCount,
  });

  factory PostReplyModel.fromJson(Map json) {
    return PostReplyModel(
      id: json['id'],
      content: json['content'],
      userId: json['user']['id'],
      userName: json['user']['name'],
      userAvatar: '$imageBaseUrl${json['user']['avatar']}',
      batch: json['user'],
      date: json['date'],
      likedStatus: json['likedStatus'],
      isMineComment: json['isMineComment'],
      likeCount: json['likeCount'],
    );
  }
}
