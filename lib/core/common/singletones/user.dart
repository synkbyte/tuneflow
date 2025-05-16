import 'package:new_tuneflow/core/common/models/user_model.dart';

class User {
  User._internal();

  static final User instance = User._internal();

  UserModel? _user;

  UserModel? get user => _user;

  void setUserModel(UserModel user) {
    _user = user;
  }
}
