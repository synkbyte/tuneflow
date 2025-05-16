import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/data/data_source/login_data_source.dart';
import 'package:new_tuneflow/src/auth/domain/entites/login_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/login_repository.dart';

class LoginRepositoryImp implements LoginRepository {
  final LoginApiService _loginApiService;
  LoginRepositoryImp(this._loginApiService);

  @override
  Future<DataState<LoginEntity>> loginRequest(
    String identifier,
    String password,
  ) async {
    return await _loginApiService.loginRequest(identifier, password);
  }
}
