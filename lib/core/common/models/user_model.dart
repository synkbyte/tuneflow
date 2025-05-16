import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/auth/domain/entites/login_entity.dart';

class UserModel {
  int id;
  String name;
  String? phone;
  String? email;
  String? userName;
  String? userNameF;
  String? avatar;
  int followers;
  int following;
  UserStep step;
  List<LanguageModel> languages;
  bool hasBatch;
  bool isPremium;
  String planName;
  String planExpireDate;
  int leftRoomCredits;
  String? batchName;
  String? batchColor;
  String bio;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.userName,
    required this.userNameF,
    this.avatar,
    required this.followers,
    required this.following,
    required this.step,
    required this.languages,
    required this.hasBatch,
    required this.isPremium,
    required this.planName,
    required this.planExpireDate,
    required this.leftRoomCredits,
    required this.batchName,
    required this.batchColor,
    required this.bio,
  });

  factory UserModel.fromJson(Map json) {
    List languages = json['languages'] ?? [];
    String userName = json['userName'] ?? '';

    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      userName: userName,
      userNameF: userName.replaceAll('@', ''),
      avatar: json['avatar'] == null ? null : formatePath(json['avatar']),
      followers: json['followers'],
      following: json['following'],
      step:
          json['step'] == 'Home'
              ? UserStep.home
              : json['step'] == 'Artist Selection'
              ? UserStep.artist
              : UserStep.language,
      languages: languages.map((e) => LanguageModel.fromJson(e)).toList(),
      hasBatch: json['hasBatch'] ?? false,
      isPremium: json['isPremium'] ?? false,
      planName: json['planName'] ?? '',
      planExpireDate: json['planExpireDate'] ?? '',
      leftRoomCredits: json['leftRoomCredits'] ?? 0,
      batchName: json['batchName'],
      batchColor: json['batchColor'] ?? '',
      bio: json['bio'] ?? '',
    );
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'userName': userName,
      'avatar': avatar?.substring(imageBaseUrl.length),
      'followers': followers,
      'following': following,
      'step': 'Home',
      'languages': languages.map((e) => e.toMap()).toList(),
      'hasBatch': hasBatch,
      'isPremium': isPremium,
      'planName': planName,
      'planExpireDate': planExpireDate,
      'leftRoomCredits': leftRoomCredits,
      'batchName': batchName,
      'batchColor': batchColor,
      'bio': bio,
    };
  }

  Map getBatch() {
    return {
      'hasBatch': hasBatch,
      'batchName': batchName,
      'batchColor': batchColor,
    };
  }

  bool isItsMe(int userId) {
    return id == userId;
  }
}
