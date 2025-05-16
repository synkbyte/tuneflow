import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/data/data_source/signup_data_source.dart';
import 'package:new_tuneflow/src/auth/domain/entites/signup_entity.dart';
import 'package:new_tuneflow/src/auth/domain/repository/signup_repository.dart';

class SignupRepositoryImp implements SignupRepository {
  final SignupApiService _signupApiService;
  SignupRepositoryImp(this._signupApiService);

  @override
  Future<DataState<SignupEntity>> signupRequest(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    return await _signupApiService.signupRequest(name, phone, email, password);
  }

  @override
  Future<DataState<SignupEntity>> googleLogin(
    String name,
    String email,
  ) async {
    return await _signupApiService.googleLogin(name, email);
  }
}
